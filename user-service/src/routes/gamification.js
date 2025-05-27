const express = require('express');
const router = express.Router();
const gamificationController = require('../controllers/GamificationController');
const { authenticate } = require('../middleware/auth');
const { validateRequest, schemas } = require('../middleware/validation');
const { rateLimiter } = require('../middleware/rateLimiter');

// Points Routes
router.get('/:id/points', authenticate, gamificationController.getPoints);
router.put('/:id/points', authenticate, validateRequest(schemas.updatePoints), gamificationController.updatePoints);
router.post('/:id/points/add', authenticate, validateRequest(schemas.addPoints), gamificationController.addPoints);

// Achievements Routes
router.get('/:id/achievements', authenticate, gamificationController.getAchievements);
router.post('/:id/achievements', authenticate, validateRequest(schemas.addAchievement), gamificationController.addAchievement);

// Leaderboard Routes
router.get('/leaderboard', authenticate, gamificationController.getLeaderboard);
router.get('/leaderboard/:category', authenticate, gamificationController.getLeaderboardByCategory);

module.exports = router; 