const jwtService = require('../../infrastructure/jwt/jwtService');

/**
 * Middleware para verificar se o usuário está autenticado
 * @param {Object} req - Requisição
 * @param {Object} res - Resposta
 * @param {Function} next - Próxima função middleware
 */
const authenticate = (req, res, next) => {
  try {
    // Obter o token do header de autorização
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        message: 'Token de autenticação não fornecido'
      });
    }

    // Extrair o token
    const token = authHeader.split(' ')[1];

    // Verificar o token
    const payload = jwtService.verifyAccessToken(token);
    if (!payload) {
      return res.status(401).json({
        success: false,
        message: 'Token de autenticação inválido ou expirado'
      });
    }

    // Adicionar os dados do usuário na requisição
    req.user = payload;

    // Passar para o próximo middleware
    next();
  } catch (error) {
    console.error('Erro no middleware de autenticação:', error);
    return res.status(401).json({
      success: false,
      message: 'Falha na autenticação'
    });
  }
};

/**
 * Middleware para verificar se o usuário tem permissão de administrador
 * Deve ser usado após o middleware authenticate
 * @param {Object} req - Requisição
 * @param {Object} res - Resposta
 * @param {Function} next - Próxima função middleware
 */
const requireAdmin = (req, res, next) => {
  if (!req.user || !req.user.isAdmin) {
    return res.status(403).json({
      success: false,
      message: 'Acesso negado. Permissão de administrador necessária.'
    });
  }
  next();
};

/**
 * Middleware opcional que verifica o token se presente, mas não exige autenticação
 * @param {Object} req - Requisição
 * @param {Object} res - Resposta
 * @param {Function} next - Próxima função middleware
 */
const optionalAuthenticate = (req, res, next) => {
  try {
    // Obter o token do header de autorização
    const authHeader = req.headers.authorization;
    
    // Se não há token, continua sem usuário autenticado
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      req.user = null;
      return next();
    }

    // Extrair e verificar o token
    const token = authHeader.split(' ')[1];
    const payload = jwtService.verifyAccessToken(token);
    
    // Adicionar os dados do usuário na requisição se o token for válido
    req.user = payload || null;
    
    // Continuar para o próximo middleware
    next();
  } catch (error) {
    // Em caso de erro, continua sem usuário autenticado
    req.user = null;
    next();
  }
};

module.exports = {
  authenticate,
  requireAdmin,
  optionalAuthenticate
}; 