const { body, validationResult } = require('express-validator');
const Joi = require('joi');

const validate = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    // Formatando erros de forma mais detalhada para o usuário
    const formattedErrors = errors.array().map(error => ({
      field: error.path || error.param,
      message: error.msg,
      value: error.value,
      location: error.location
    }));

    // Gerar mensagem amigável baseada nos erros
    const userMessage = generateValidationUserMessage(formattedErrors);

    return res.status(400).json({
      status: 'error',
      message: 'Validation failed',
      userMessage: userMessage,
      errors: formattedErrors,
      details: {
        errorCount: formattedErrors.length,
        timestamp: new Date().toISOString(),
        requestId: req.headers['x-request-id'] || 'unknown'
      }
    });
  }
  next();
};

// Função para gerar mensagens amigáveis de validação
const generateValidationUserMessage = (errors) => {
  if (errors.length === 1) {
    const error = errors[0];

    if (error.field === 'email') {
      return 'Por favor, insira um email válido.';
    }

    if (error.field === 'password') {
      if (error.message.includes('8 characters')) {
        return 'A senha deve ter pelo menos 8 caracteres.';
      }
      if (error.message.includes('uppercase') || error.message.includes('lowercase') || error.message.includes('number') || error.message.includes('special')) {
        return 'A senha deve conter pelo menos: uma letra maiúscula, uma minúscula, um número e um caractere especial.';
      }
      return 'A senha não atende aos requisitos de segurança.';
    }

    if (error.field === 'name') {
      return 'O nome deve ter pelo menos 2 caracteres.';
    }

    if (error.field === 'fcmToken') {
      return 'Token de notificação é obrigatório.';
    }

    return error.message;
  }

  // Múltiplos erros
  const fieldErrors = errors.map(e => e.field).join(', ');
  return `Por favor, corrija os seguintes campos: ${fieldErrors}.`;
};

const validateRequest = (schema) => {
  // If it's a Joi schema
  if (schema && typeof schema.validate === 'function') {
    return (req, res, next) => {
      const { error } = schema.validate(req.body);
      if (error) {
        const formattedError = {
          field: error.details[0].path.join('.'),
          message: error.details[0].message,
          value: error.details[0].context?.value,
          type: error.details[0].type
        };

        return res.status(400).json({
          status: 'error',
          message: 'Schema validation failed',
          error: formattedError,
          details: {
            schema: 'Joi',
            timestamp: new Date().toISOString(),
            requestId: req.headers['x-request-id'] || 'unknown'
          }
        });
      }
      next();
    };
  }

  // If it's an express-validator array
  return [...schema, validate];
};

const registerValidation = [
  body('email')
    .isEmail()
    .withMessage('Please enter a valid email')
    .normalizeEmail(), body('password')
      .isLength({ min: 8 })
      .withMessage('Password must be at least 8 characters long')
      .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>])[A-Za-z\d!@#$%^&*(),.?":{}|<>]{8,}$/)
      .withMessage('Password must contain at least one uppercase letter, one lowercase letter, one number and one special character'),
  body('name')
    .trim()
    .isLength({ min: 2 })
    .withMessage('Name must be at least 2 characters long'),
  body('fcmToken')
    .notEmpty()
    .withMessage('FCM Token is required')
    .isLength({ min: 1 })
    .withMessage('FCM Token cannot be empty'),
  validate
];

const loginValidation = [
  body('email')
    .isEmail()
    .withMessage('Please enter a valid email')
    .normalizeEmail(),
  body('password')
    .notEmpty()
    .withMessage('Password is required'),
  validate
];

const passwordResetRequestValidation = [
  body('email')
    .isEmail()
    .withMessage('Please enter a valid email')
    .normalizeEmail(),
  validate
];

const passwordResetValidation = [
  body('token')
    .notEmpty()
    .withMessage('Token is required'), body('password')
      .isLength({ min: 8 })
      .withMessage('Password must be at least 8 characters long')
      .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>])[A-Za-z\d!@#$%^&*(),.?":{}|<>]{8,}$/)
      .withMessage('Password must contain at least one uppercase letter, one lowercase letter, one number and one special character'),
  validate
];

const refreshTokenValidation = [
  body('refreshToken')
    .notEmpty()
    .withMessage('Refresh token is required'),
  validate
];

const schemas = {
  createUser: [
    body('username').trim().isLength({ min: 2 }).withMessage('Username must be at least 2 characters long'),
    body('email').isEmail().withMessage('Please enter a valid email').normalizeEmail(), body('password')
      .isLength({ min: 8 })
      .withMessage('Password must be at least 8 characters long')
      .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>])[A-Za-z\d!@#$%^&*(),.?":{}|<>]{8,}$/)
      .withMessage('Password must contain at least one uppercase letter, one lowercase letter, one number and one special character')
  ],
  updateUser: [
    body('username').optional().trim().isLength({ min: 2 }).withMessage('Username must be at least 2 characters long'),
    body('email').optional().isEmail().withMessage('Please enter a valid email').normalizeEmail(), body('password')
      .optional()
      .isLength({ min: 8 })
      .withMessage('Password must be at least 8 characters long')
      .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>])[A-Za-z\d!@#$%^&*(),.?":{}|<>]{8,}$/)
      .withMessage('Password must contain at least one uppercase letter, one lowercase letter, one number and one special character')
  ],
  updateProfile: [
    body('username').optional().trim().isLength({ min: 2 }).withMessage('Username must be at least 2 characters long'),
    body('email').optional().isEmail().withMessage('Please enter a valid email').normalizeEmail()
  ]
};

module.exports = {
  registerValidation,
  loginValidation,
  passwordResetRequestValidation,
  passwordResetValidation,
  refreshTokenValidation,
  validateRequest,
  schemas
};