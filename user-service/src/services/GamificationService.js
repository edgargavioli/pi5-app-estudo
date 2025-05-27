const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

class GamificationService {
  // Points
  async getUserPoints(userId) {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: { points: true }
    });
    if (!user) {
      throw new Error('User not found');
    }
    return user.points;
  }

  async updateUserPoints(userId, points) {
    return prisma.user.update({
      where: { id: userId },
      data: { points }
    });
  }

  async addPoints(userId, points, reason) {
    const user = await prisma.user.update({
      where: { id: userId },
      data: {
        points: {
          increment: points
        }
      }
    });

    // Log points transaction
    await prisma.pointsTransaction.create({
      data: {
        userId,
        points,
        reason,
        type: 'ADD'
      }
    });

    return user;
  }

  // Achievements
  async getUserAchievements(userId) {
    return prisma.achievement.findMany({
      where: { userId }
    });
  }

  async addAchievement(userId, achievementData) {
    return prisma.achievement.create({
      data: {
        ...achievementData,
        userId
      }
    });
  }

  // Leaderboard
  async getLeaderboard() {
    return prisma.user.findMany({
      select: {
        id: true,
        name: true,
        points: true
      },
      orderBy: {
        points: 'desc'
      },
      take: 10
    });
  }

  async getLeaderboardByCategory(category) {
    // Implement category-based leaderboard logic
    return prisma.user.findMany({
      select: {
        id: true,
        name: true,
        points: true
      },
      orderBy: {
        points: 'desc'
      },
      take: 10
    });
  }
}

module.exports = new GamificationService(); 