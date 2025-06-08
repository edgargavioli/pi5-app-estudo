const { PrismaClient } = require('@prisma/client');
const { AppError } = require('../../middleware/errorHandler');

const prisma = new PrismaClient();

/**
 * Wrapped Service - Infrastructure Layer
 * Handles data aggregation for user analytics and wrapped data
 */
class WrappedService {
  /**
   * Get aggregated user data (wrapped view)
   */
  async getUserWrapped(userId) {
    try {
      const user = await prisma.user.findUnique({
        where: { id: userId },
        include: {
          achievements: true,
          pointsTransactions: true,
          studySessions: true,
          studyMaterials: true,
          studyPreferences: true
        }
      });

      if (!user) {
        throw new AppError('User not found', 404);
      }

      // Calculate aggregated data
      const totalStudyTime = user.studySessions.reduce((total, session) => {
        return total + (session.duration || 0);
      }, 0);

      const totalMaterials = user.studyMaterials.length;
      const totalAchievements = user.achievements.length;
      const totalPoints = user.points;

      return {
        user: {
          id: user.id,
          name: user.name,
          email: user.email,
          points: user.points,
          createdAt: user.createdAt
        },
        stats: {
          totalStudyTime,
          totalMaterials,
          totalAchievements,
          totalPoints,
          studySessionsCount: user.studySessions.length
        },
        recentActivity: {
          recentSessions: user.studySessions.slice(-5),
          recentMaterials: user.studyMaterials.slice(-5)
        }
      };
    } catch (error) {
      throw error;
    }
  }

  /**
   * Get user achievements
   */
  async getUserAchievements(userId) {
    try {
      const achievements = await prisma.achievement.findMany({
        where: { userId },
        orderBy: { createdAt: 'desc' }
      });

      return achievements;
    } catch (error) {
      throw error;
    }
  }

  /**
   * Get user points history
   */
  async getUserPointsHistory(userId) {
    try {
      const pointsHistory = await prisma.pointsTransaction.findMany({
        where: { userId },
        orderBy: { createdAt: 'desc' }
      });

      return pointsHistory;
    } catch (error) {
      throw error;
    }
  }
}

module.exports = new WrappedService(); 