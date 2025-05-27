const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

class WrappedService {
  async getUserSummary(userId) {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      include: {
        achievements: true,
        pointsTransactions: true
      }
    });

    if (!user) {
      throw new Error('User not found');
    }

    return {
      totalPoints: user.points,
      achievementsCount: user.achievements.length,
      totalTransactions: user.pointsTransactions.length,
      lastActivity: user.updatedAt
    };
  }

  async getUserStatistics(userId) {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      include: {
        pointsTransactions: {
          orderBy: {
            createdAt: 'desc'
          },
          take: 10
        }
      }
    });

    if (!user) {
      throw new Error('User not found');
    }

    return {
      pointsHistory: user.pointsTransactions.map(t => ({
        points: t.points,
        reason: t.reason,
        date: t.createdAt
      })),
      averagePointsPerDay: this.calculateAveragePoints(user.pointsTransactions)
    };
  }

  async getUserAchievements(userId) {
    const achievements = await prisma.achievement.findMany({
      where: { userId },
      orderBy: {
        createdAt: 'desc'
      }
    });

    return achievements.map(a => ({
      title: a.title,
      description: a.description,
      points: a.points,
      date: a.createdAt
    }));
  }

  async getUserActivity(userId) {
    const transactions = await prisma.pointsTransaction.findMany({
      where: { userId },
      orderBy: {
        createdAt: 'desc'
      },
      take: 20
    });

    return transactions.map(t => ({
      type: t.type,
      points: t.points,
      reason: t.reason,
      date: t.createdAt
    }));
  }

  calculateAveragePoints(transactions) {
    if (transactions.length === 0) return 0;
    
    const totalPoints = transactions.reduce((sum, t) => sum + t.points, 0);
    const days = this.getDaysBetween(
      transactions[transactions.length - 1].createdAt,
      transactions[0].createdAt
    );
    
    return days > 0 ? totalPoints / days : totalPoints;
  }

  getDaysBetween(startDate, endDate) {
    const diffTime = Math.abs(endDate - startDate);
    return Math.ceil(diffTime / (1000 * 60 * 60 * 24));
  }
}

module.exports = new WrappedService(); 