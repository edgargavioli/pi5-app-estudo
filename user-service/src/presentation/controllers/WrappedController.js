const wrappedService = require('../../infrastructure/services/WrappedService');
const { AppError } = require('../../middleware/errorHandler');

class WrappedController {
  /**
   * Get wrapped user data (aggregated view)
   */
  async getUserWrapped(req, res) {
    try {
      const wrappedData = await wrappedService.getUserWrapped(req.params.id);
      res.json(wrappedData);
    } catch (error) {
      throw error;
    }
  }

  /**
   * Get user achievements
   */
  async getUserAchievements(req, res) {
    try {
      const achievements = await wrappedService.getUserAchievements(req.params.id);
      res.json({ achievements });
    } catch (error) {
      throw error;
    }
  }

  /**
   * Get user points history
   */
  async getUserPointsHistory(req, res) {
    try {
      const pointsHistory = await wrappedService.getUserPointsHistory(req.params.id);
      res.json({ pointsHistory });
    } catch (error) {
      throw error;
    }
  }
}

module.exports = new WrappedController(); 