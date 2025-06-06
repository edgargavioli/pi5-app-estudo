const { AppError } = require('../../middleware/errorHandler');
const LoggingService = require('../../infrastructure/services/LoggingService');

/**
 * Get User Use Case
 * Application layer - orchestrates business logic
 */
class GetUserUseCase {
  constructor(userRepository) {
    this.userRepository = userRepository;
  }

  async execute(userId, requestingUserId) {
    try {
      // Authorization check - users can only access their own data
      if (userId !== requestingUserId) {
        throw new AppError('Unauthorized: You can only access your own profile', 403);
      }

      const user = await this.userRepository.findById(userId);
      
      if (!user) {
        throw new AppError('User not found', 404);
      }

      LoggingService.info('User retrieved successfully', { userId });
      
      // Return public representation of user
      return user.toPublicJSON();
    } catch (error) {
      LoggingService.error('Error in GetUserUseCase', { 
        error: error.message, 
        userId,
        requestingUserId 
      });
      throw error;
    }
  }
}

module.exports = GetUserUseCase; 