import jwt from 'jsonwebtorken';
import axios from 'axios';

const USER_SERVICE_URL = process.env.USER_SERVICE_URL || 'http://localhost:3000';
const JWT_SECRET = process.env.JWT_SECRET || 'your_jwt_secret_key_super_secure_2024';

/**
 * Middleware de Validação JWT
 * Valida tokens JWT com o user-service e mantém validação local como fallback
 */
export const authMiddleware = async (req, res, next) => {
  try {
    // Extrair token do header Authorization
    const authHeader = req.headers.authorization;
    
    if (!authHeader) {
      return res.status(401).json({ 
        error: 'Token JWT requerido',
        code: 'JWT_TOKEN_MISSING'
      });
    }

    // Verificar formato "Bearer TOKEN"
    const [bearer, token] = authHeader.split(' ');
    
    if (bearer !== 'Bearer' || !token) {
      return res.status(401).json({ 
        error: 'Formato de token inválido. Use: Bearer <token>',
        code: 'JWT_TOKEN_INVALID_FORMAT'
      });
    }

    try {
      // Tentar validar com o user-service primeiro
      const response = await axios.get(`${USER_SERVICE_URL}/api/auth/validate`, {
        headers: { Authorization: authHeader },
        timeout: 5000 // 5 segundos de timeout
      });

      if (response.data.valid) {
        // Usar dados do usuário retornados pelo user-service
        req.userId = response.data.data.user.id;
        req.user = response.data.data.user;
        return next();
      }

    } catch (error) {
      console.warn('Falha ao validar token com user-service, usando validação local:', error.message);
      
      // Se o user-service estiver indisponível, fazer validação local
      const decoded = jwt.verify(token, JWT_SECRET);

      // Extrair userId do payload
      const userId = decoded.id || decoded.userId || decoded.sub;
      
      if (!userId) {
        return res.status(401).json({ 
          error: 'Token JWT não contém ID do usuário',
          code: 'JWT_TOKEN_NO_USER_ID'
        });
      }

      // Adicionar dados do usuário ao request
      req.userId = userId;
      req.user = {
        id: userId,
        email: decoded.email || null,
        name: decoded.name || null,
        ...decoded
      };

      // Adicionar flag indicando que foi usado fallback
      req.authFallback = true;

      return next();
    }

  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({ 
        error: 'Token JWT expirado. Faça login novamente.',
        code: 'JWT_TOKEN_EXPIRED'
      });
    }

    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({ 
        error: 'Token JWT inválido',
        code: 'JWT_TOKEN_INVALID'
      });
    }

    return res.status(401).json({ 
      error: 'Falha na validação do token JWT',
      code: 'JWT_VALIDATION_FAILED'
    });
  }
};

/**
 * Middleware OPCIONAL - extrai userId se token presente
 * Para endpoints públicos que podem ter funcionalidades extras se autenticado
 */
export const optionalAuthMiddleware = async (req, res, next) => {
  const authHeader = req.headers.authorization;
  
  if (!authHeader) {
    // Sem token, continua sem userId (acesso público)
    return next();
  }

  // Se tem token, valida normalmente
  return authMiddleware(req, res, next);
};

/**
 * Middleware para verificar ownership de recursos
 * Garante que usuário só acesse seus próprios dados
 */
export const resourceOwnershipMiddleware = (req, res, next) => {
  // Este middleware deve ser usado APÓS authMiddleware
  if (!req.userId) {
    return res.status(500).json({ 
      error: 'Erro interno: authMiddleware deve ser usado antes',
      code: 'MIDDLEWARE_ORDER_ERROR'
    });
  }

  // Flag para use cases saberem que devem filtrar por userId
  req.requireOwnership = true;
  next();
}; 