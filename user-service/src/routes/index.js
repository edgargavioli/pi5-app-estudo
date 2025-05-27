const express = require('express');
const router = express.Router();

const authRoutes = require('./auth');
const userRoutes = require('./users');
const gamificationRoutes = require('./gamification');
const wrappedRoutes = require('./wrapped');

// Mount routes
router.use('/auth', authRoutes);
router.use('/users', userRoutes);
router.use('/gamification', gamificationRoutes);
router.use('/wrapped', wrappedRoutes);

module.exports = router; 