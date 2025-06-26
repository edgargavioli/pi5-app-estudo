const { AppError } = require('../../middleware/errorHandler');
const LoggingService = require('../../infrastructure/services/LoggingService');
const Password = require('../../domain/valueObjects/Password');
const Email = require('../../domain/valueObjects/Email');

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

      const user = await this.userRepository.findById(userId);

      if (!user) {
        throw new AppError('User not found', 404);
      }

      // Validate and update email if provided
      if (updateData.email) {
        const emailVO = new Email(updateData.email);

        // Check if email is already taken by another user
        const emailExists = await this.userRepository.emailExists(emailVO.toString(), userId);
        if (emailExists) {
          throw new AppError('Email already in use', 400);
        }

        user.email = emailVO.toString();
      }

      // Validate and update password if provided
      if (updateData.password) {
        const passwordVO = new Password(updateData.password);
        user.password = await passwordVO.hash();
      }

      // Update name if provided
      if (updateData.name) {
        user.name = updateData.name.trim();
      }

      // Update imageBase64 if provided
      if (updateData.imageBase64) {
        user.imageBase64 = updateData.imageBase64;
      }

      // Validate the updated user entity
      user.validate();

      // Update timestamps
      user.updatedAt = new Date();

      const updatedUser = await this.userRepository.update(user);

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