const gamificationService = require('../services/GamificationService');
const { handleError } = require('../utils/errorHandler');

class GamificationController {
  // Points
  async getPoints(req, res) {
    try {
      const points = await gamificationService.getUserPoints(req.params.id);
      res.json({ points });
    } catch (error) {
      handleError(error, res);
    }
  }

  async updatePoints(req, res) {
    try {
      const user = await gamificationService.updateUserPoints(req.params.id, req.body.points);
      res.json(user);
    } catch (error) {
      handleError(error, res);
    }
  }

  async addPoints(req, res) {
    try {
      const user = await gamificationService.addPoints(req.params.id, req.body.points, req.body.reason);
      res.json(user);
    } catch (error) {
      handleError(error, res);
    }
  }

  // Achievements
  async getAchievements(req, res) {
    try {
      const achievements = await gamificationService.getUserAchievements(req.params.id);
      res.json(achievements);
    } catch (error) {
      handleError(error, res);
    }
  }

  async addAchievement(req, res) {
    try {
      const achievement = await gamificationService.addAchievement(req.params.id, req.body);
      res.json(achievement);
    } catch (error) {
      handleError(error, res);
    }
  }

  // Leaderboard
  async getLeaderboard(req, res) {
    try {
      const leaderboard = await gamificationService.getLeaderboard();
      res.json(leaderboard);
    } catch (error) {
      handleError(error, res);
    }
  }

  async getLeaderboardByCategory(req, res) {
    try {
      const leaderboard = await gamificationService.getLeaderboardByCategory(req.params.category);
      res.json(leaderboard);
    } catch (error) {
      handleError(error, res);
    }
  }
}

module.exports = new GamificationController(); 