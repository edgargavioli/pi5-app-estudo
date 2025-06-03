const wrappedService = require('../../infrastructure/services/WrappedService');
const { AppError } = require('../../middleware/errorHandler');
const GenerateWrappedImageUseCase = require('../../application/useCases/GenerateWrappedImageUseCase');
const fs = require('fs');
const path = require('path');

class WrappedController {
  constructor() {
    this.generateWrappedImageUseCase = new GenerateWrappedImageUseCase();
  }

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

  /**
   * Generate wrapped image on provided background
   */
  async getWrappedImage(req, res) {
    try {
      const userId = req.params.id;
      const requestingUserId = req.user.id;

      let backgroundBuffer;
      if (req.file && req.file.buffer) {
        // use uploaded background
        backgroundBuffer = req.file.buffer;
      } else {
        // load default background template
        const templatePath = path.join(__dirname, '../../infrastructure/assets/templates', 'background.png');
        if (!fs.existsSync(templatePath)) {
          throw new AppError('Background template not found', 500);
        }
        backgroundBuffer = fs.readFileSync(templatePath);
      }

      const imageBuffer = await this.generateWrappedImageUseCase.execute(
        userId,
        requestingUserId,
        backgroundBuffer
      );

      res.type('image/png').send(imageBuffer);
    } catch (error) {
      throw error;
    }
  }
}

module.exports = new WrappedController(); 