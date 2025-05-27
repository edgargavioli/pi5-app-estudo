const wrappedService = require('../services/WrappedService');
const { handleError } = require('../utils/errorHandler');

class WrappedController {
  async getUserSummary(req, res) {
    try {
      const summary = await wrappedService.getUserSummary(req.params.id);
      res.json(summary);
    } catch (error) {
      handleError(error, res);
    }
  }

  async getUserStatistics(req, res) {
    try {
      const statistics = await wrappedService.getUserStatistics(req.params.id);
      res.json(statistics);
    } catch (error) {
      handleError(error, res);
    }
  }

  async getUserAchievements(req, res) {
    try {
      const achievements = await wrappedService.getUserAchievements(req.params.id);
      res.json(achievements);
    } catch (error) {
      handleError(error, res);
    }
  }

  async getUserActivity(req, res) {
    try {
      const activity = await wrappedService.getUserActivity(req.params.id);
      res.json(activity);
    } catch (error) {
      handleError(error, res);
    }
  }
}

module.exports = new WrappedController(); 