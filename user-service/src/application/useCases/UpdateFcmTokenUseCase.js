const { AppError } = require('../../middleware/errorHandler');
const LoggingService = require('../../infrastructure/services/LoggingService');
const QueueService = require('../../infrastructure/services/QueueService');

/**
 * Update FCM Token Use Case
 * Application layer - orchestrates FCM token update business logic
 */
class UpdateFcmTokenUseCase {
    constructor(userRepository) {
        this.userRepository = userRepository;
    }

    async execute(userId, fcmToken, requestingUserId) {
        try {
            // Authorization check
            if (userId !== requestingUserId) {
                throw new AppError('Unauthorized: You can only update your own FCM token', 403);
            }

            // Find user
            const user = await this.userRepository.findById(userId);

            if (!user) {
                throw new AppError('User not found', 404);
            }

            // Store old FCM token for event publishing
            const oldFcmToken = user.fcmToken;

            // Update FCM token
            user.fcmToken = fcmToken;
            user.updatedAt = new Date();

            // Save to database
            const updatedUser = await this.userRepository.update(user);

            // Publish FCM token updated event to queue
            try {
                await QueueService.publishFcmTokenUpdated(userId, fcmToken, oldFcmToken);
                LoggingService.info('FCM token updated event published successfully', {
                    userId,
                    oldToken: oldFcmToken ? oldFcmToken.substring(0, 10) + '...' : null,
                    newToken: fcmToken.substring(0, 10) + '...'
                });
            } catch (queueError) {
                // Log the error but don't fail the update
                LoggingService.error('Failed to publish FCM token updated event', {
                    error: queueError.message,
                    userId
                });
                // Continue with the response since the database update was successful
            }

            LoggingService.info('FCM token updated successfully', {
                userId,
                tokenUpdated: true
            });

            return {
                fcmToken: updatedUser.fcmToken,
                updatedAt: updatedUser.updatedAt
            };
        } catch (error) {
            LoggingService.error('Error in UpdateFcmTokenUseCase', {
                error: error.message,
                userId,
                requestingUserId
            });
            throw error;
        }
    }
}

module.exports = UpdateFcmTokenUseCase;
