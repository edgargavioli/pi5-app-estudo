const { AppError } = require('../../middleware/errorHandler');
const LoggingService = require('../../infrastructure/services/LoggingService');

/**
 * Update User Use Case
 * Application layer - orchestrates business logic
 */
class UpdateUserUseCase {
  constructor(userRepository) {
    this.userRepository = userRepository;
  }

  async execute(userId, updateData, requestingUserId) {
    try {
      // Authorization check - users can only update their own data
      if (userId !== requestingUserId) {
        throw new AppError('Unauthorized: You can only update your own profile', 403);
      }

      // Validate update data
      if (!updateData || Object.keys(updateData).length === 0) {
        throw new AppError('No update data provided', 400);
      }

      // Check if user exists
      const existingUser = await this.userRepository.findById(userId);
      if (!existingUser) {
        throw new AppError('User not found', 404);
      }

      // Check if email is being updated and is unique
      if (updateData.email && updateData.email !== existingUser.email) {
        const emailExists = await this.userRepository.findByEmail(updateData.email);
        if (emailExists) {
          throw new AppError('Email already in use', 400);
        }
      }

      // Update user
      const updatedUser = await this.userRepository.update(userId, updateData);

      LoggingService.info('User updated successfully', { userId });

      return updatedUser.toPublicJSON();
    } catch (error) {
      LoggingService.error('Error in UpdateUserUseCase', {
        error: error.message,
        userId,
        requestingUserId
      });
      throw error;
    }
  }
}

module.exports = UpdateUserUseCase; 