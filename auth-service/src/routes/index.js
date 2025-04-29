const express = require('express');
const router = express.Router();
const authRoutes = require('./authRoutes');
const passwordResetRoutes = require('./passwordResetRoutes');

// Rotas de autenticação
router.use('/auth', authRoutes);

// Rotas de redefinição de senha
router.use('/password-reset', passwordResetRoutes);

module.exports = router; 