const { AppError } = require('../../middleware/errorHandler');
const wrappedService = require('../../infrastructure/services/WrappedService');
const canvasService = require('../../infrastructure/services/CanvasService');

/**
 * GenerateWrappedImageUseCase
 * Orchestrates fetching user wrapped data and generating an image
 */
class GenerateWrappedImageUseCase {
  /**
   * Execute the use case
   * @param {string} userId - ID of the user to generate for
   * @param {string} requestingUserId - ID of the authenticated user
   * @param {Buffer} backgroundBuffer - Background image buffer
   * @returns {Buffer} PNG image buffer
   */
  async execute(userId, requestingUserId, backgroundBuffer) {
    // Authorization: only users can generate their own image
    if (userId !== requestingUserId) {
      throw new AppError('Unauthorized: You can only generate your own wrapped image', 403);
    }

    // Fetch aggregated wrapped data
    const wrappedData = await wrappedService.getUserWrapped(userId);

    // Generate and return the image buffer
    const imageBuffer = await canvasService.generateWrappedImage(
      backgroundBuffer,
      wrappedData.user,
      wrappedData.stats
    );

    return imageBuffer;
  }
}

module.exports = GenerateWrappedImageUseCase; 