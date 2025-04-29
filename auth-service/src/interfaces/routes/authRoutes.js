const express = require('express');
const AuthController = require('../controllers/AuthController');
const { authenticate, requireAdmin } = require('../middlewares/authMiddleware');
const PostgresUserRepository = require('../../infrastructure/database/PostgresUserRepository');
const PostgresPasswordResetRepository = require('../../infrastructure/database/PostgresPasswordResetRepository');

const router = express.Router();

// Inicializar repositórios
const userRepository = new PostgresUserRepository();
const passwordResetRepository = new PostgresPasswordResetRepository();

// Inicializar controller
const authController = new AuthController(userRepository, passwordResetRepository);

// Rotas públicas
router.post('/register', (req, res) => authController.register(req, res));
router.post('/login', (req, res) => authController.login(req, res));
router.post('/refresh-token', (req, res) => authController.refreshToken(req, res));
router.post('/recover-password', (req, res) => authController.recoverPasswordRequest(req, res));
router.post('/reset-password', (req, res) => authController.resetPassword(req, res));
router.post('/verify-reset-token', (req, res) => authController.verifyResetToken(req, res));
router.get('/verify-email', (req, res) => authController.verifyEmail(req, res));

// Rotas protegidas (requerem autenticação)
router.post('/logout', authenticate, (req, res) => authController.logout(req, res));
router.put('/change-password', authenticate, (req, res) => authController.changePassword(req, res));

// Rotas de admin (requerem autenticação e privilégios de admin)
router.put('/block-account', authenticate, requireAdmin, (req, res) => authController.blockAccount(req, res));
router.put('/unblock-account', authenticate, requireAdmin, (req, res) => authController.unblockAccount(req, res));

module.exports = router; 