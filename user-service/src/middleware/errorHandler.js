const LoggingService = require('../infrastructure/services/LoggingService');

class AppError extends Error {
  constructor(message, statusCode, details = null) {
    super(message);
    this.statusCode = statusCode;
    this.status = `${statusCode}`.startsWith('4') ? 'fail' : 'error';
    this.isOperational = true;
    this.details = details;
    this.timestamp = new Date().toISOString();

    Error.captureStackTrace(this, this.constructor);
  }

  // Método para adicionar mais contexto ao erro
  withContext(context) {
    this.context = context;
    return this;
  }

  // Método para adicionar sugestões de solução
  withSuggestions(suggestions) {
    this.suggestions = suggestions;
    return this;
  }
}

const handleError = (error, res, req = null) => {
  // Log the error with more context
  LoggingService.error('Error occurred', {
    error: error.message,
    stack: error.stack,
    statusCode: error.statusCode,
    url: req?.url,
    method: req?.method,
    userAgent: req?.get('User-Agent'),
    ip: req?.ip,
    timestamp: new Date().toISOString()
  });

  // Handle operational errors (expected errors)
  if (error.isOperational) {
    const errorResponse = {
      status: error.status,
      message: error.message,
      timestamp: error.timestamp || new Date().toISOString(),
      requestId: req?.headers['x-request-id'] || 'unknown'
    };

    // Adicionar detalhes se disponíveis
    if (error.details) {
      errorResponse.details = error.details;
    }

    // Adicionar contexto se disponível
    if (error.context) {
      errorResponse.context = error.context;
    }

    // Adicionar sugestões se disponíveis
    if (error.suggestions) {
      errorResponse.suggestions = error.suggestions;
    }

    // Adicionar mensagem específica para Flutter
    errorResponse.userMessage = generateUserFriendlyMessage(error);

    // Em desenvolvimento, incluir stack trace
    if (process.env.NODE_ENV === 'development') {
      errorResponse.stack = error.stack;
    }

    return res.status(error.statusCode).json(errorResponse);
  }

  // Handle programming or unknown errors
  const genericErrorResponse = {
    status: 'error',
    message: 'Internal server error occurred',
    userMessage: 'Ocorreu um erro interno. Tente novamente em alguns instantes.',
    timestamp: new Date().toISOString(),
    requestId: req?.headers['x-request-id'] || 'unknown',
    supportInfo: {
      message: 'Se o erro persistir, entre em contato com o suporte',
      email: 'support@example.com'
    }
  };

  // Em desenvolvimento, incluir mais detalhes
  if (process.env.NODE_ENV === 'development') {
    genericErrorResponse.details = {
      originalMessage: error.message,
      stack: error.stack
    };
  }

  return res.status(500).json(genericErrorResponse);
};

// Função para gerar mensagens amigáveis para o usuário
const generateUserFriendlyMessage = (error) => {
  const { details, message } = error;

  // Mensagens específicas baseadas no tipo de erro
  if (details?.type === 'duplicate_email') {
    return 'Este email já está cadastrado. Tente fazer login ou use outro email.';
  }

  if (details?.type === 'validation_failed' && details?.field === 'password') {
    return 'A senha deve ter pelo menos 8 caracteres, incluindo letra maiúscula, minúscula, número e símbolo especial.';
  }

  if (details?.type === 'authentication_failed') {
    return 'Email ou senha incorretos. Verifique seus dados e tente novamente.';
  }

  if (details?.type === 'user_not_found') {
    return 'Usuário não encontrado. Verifique se os dados estão corretos.';
  }

  if (details?.type === 'email_not_verified') {
    return 'Você precisa verificar seu email antes de fazer login. Verifique sua caixa de entrada.';
  }

  if (details?.type === 'access_denied') {
    return 'Você não tem permissão para acessar esta informação.';
  }

  if (details?.type === 'required_field_missing') {
    return `O campo ${details?.field || 'obrigatório'} é necessário.`;
  }

  // Mensagem padrão se não houver tipo específico
  return message || 'Ocorreu um erro. Tente novamente.';
};

const errorHandler = (err, req, res, next) => {
  // Adicionar ID de requisição se não existir
  if (!req.headers['x-request-id']) {
    req.headers['x-request-id'] = `req_${Date.now()}_${Math.random().toString(36).substring(2, 8)}`;
  }

  handleError(err, res, req);
};

module.exports = {
  AppError,
  handleError,
  errorHandler
}; 