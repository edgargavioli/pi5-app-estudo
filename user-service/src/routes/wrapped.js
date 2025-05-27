const express = require('express');
const router = express.Router();
const wrappedController = require('../controllers/WrappedController');
const { authenticate } = require('../middleware/auth');
const { validateRequest, schemas } = require('../middleware/validation');
const { rateLimiter } = require('../middleware/rateLimiter');

// Wrapped Routes
router.get('/:id/summary', authenticate, wrappedController.getUserSummary);
router.get('/:id/statistics', authenticate, wrappedController.getUserStatistics);
router.get('/:id/achievements', authenticate, wrappedController.getUserAchievements);
router.get('/:id/activity', authenticate, wrappedController.getUserActivity);

module.exports = router; 