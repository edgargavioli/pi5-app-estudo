const { body, validationResult } = require('express-validator');

const validate = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }
  next();
};

const validateRequest = (schema) => {
  return [...schema, validate];
};

const registerValidation = [
  body('email')
    .isEmail()
    .withMessage('Please enter a valid email')
    .normalizeEmail(),
  body('password')
    .isLength({ min: 8 })
    .withMessage('Password must be at least 8 characters long')
    .matches(/^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$/)
    .withMessage('Password must contain at least one letter, one number and one special character'),
  body('name')
    .trim()
    .isLength({ min: 2 })
    .withMessage('Name must be at least 2 characters long'),
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
    .withMessage('Token is required'),
  body('password')
    .isLength({ min: 8 })
    .withMessage('Password must be at least 8 characters long')
    .matches(/^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$/)
    .withMessage('Password must contain at least one letter, one number and one special character'),
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
    body('email').isEmail().withMessage('Please enter a valid email').normalizeEmail(),
    body('password')
      .isLength({ min: 8 })
      .withMessage('Password must be at least 8 characters long')
      .matches(/^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$/)
      .withMessage('Password must contain at least one letter, one number and one special character')
  ],
  updateUser: [
    body('username').optional().trim().isLength({ min: 2 }).withMessage('Username must be at least 2 characters long'),
    body('email').optional().isEmail().withMessage('Please enter a valid email').normalizeEmail(),
    body('password')
      .optional()
      .isLength({ min: 8 })
      .withMessage('Password must be at least 8 characters long')
      .matches(/^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$/)
      .withMessage('Password must contain at least one letter, one number and one special character')
  ],
  updateProfile: [
    body('username').optional().trim().isLength({ min: 2 }).withMessage('Username must be at least 2 characters long'),
    body('email').optional().isEmail().withMessage('Please enter a valid email').normalizeEmail()
  ],
  updatePoints: [
    body('points').isInt({ min: 0 }).withMessage('Points must be a non-negative integer')
  ],
  addPoints: [
    body('points').isInt({ min: 0 }).withMessage('Points must be a non-negative integer'),
    body('reason').optional().trim().isLength({ min: 1 }).withMessage('Reason is required')
  ],
  addAchievement: [
    body('name').trim().isLength({ min: 1 }).withMessage('Achievement name is required'),
    body('description').optional().trim().isLength({ min: 1 }).withMessage('Description is required')
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