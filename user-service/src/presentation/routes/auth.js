const express = require('express');
const router = express.Router();
const authController = require('../controllers/AuthController');
const healthController = require('../controllers/HealthController');
const { authenticate } = require('../../middleware/auth');
const { authLimiter, passwordResetLimiter, registerLimiter, apiLimiter } = require('../../middleware/rateLimiter');
const {
  registerValidation,
  loginValidation,
  passwordResetRequestValidation,
  passwordResetValidation,
  refreshTokenValidation
} = require('../../middleware/validation');

// Health Check
router.get('/health', healthController.check);

// Authentication Routes
router.post('/register', registerLimiter, registerValidation, authController.register);
router.post('/login', authLimiter, loginValidation, authController.login);
router.post('/refresh-token', apiLimiter, refreshTokenValidation, authController.refreshToken);
//router.post('/request-password-reset', passwordResetLimiter, passwordResetRequestValidation, authController.requestPasswordReset);
router.post('/reset-password', passwordResetLimiter, passwordResetValidation, authController.resetPassword);
router.get('/verify-email', authController.verifyEmail);

module.exports = router; 