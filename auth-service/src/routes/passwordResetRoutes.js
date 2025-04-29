const express = require('express');
const router = express.Router();
const PasswordResetController = require('../controllers/PasswordResetController');
const PasswordResetRepository = require('../repositories/PasswordResetRepository');

const passwordResetRepository = new PasswordResetRepository();
const passwordResetController = new PasswordResetController(passwordResetRepository);

// Rota para verificar token
router.get('/verify/:token', passwordResetController.verifyToken.bind(passwordResetController));

// ... existing code ...

module.exports = router; 