const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcrypt');
const prisma = new PrismaClient();

async function main() {
  try {
    // Check if we already have users
  const userCount = await prisma.user.count();
    if (userCount > 0) {
      console.log('Database already seeded');
      return;
    }

    // Create admin user
    const adminPassword = await bcrypt.hash('admin123', 10);
    const admin = await prisma.user.create({
      data: {
        email: 'admin@example.com',
        password: adminPassword,
        name: 'Admin User',
        points: 1000
      }
    });

    // Create some achievements
    await prisma.achievement.create({
      data: {
        userId: admin.id,
        title: 'First Login',
        description: 'Successfully logged in for the first time',
        points: 100
      }
    });

    // Create some points transactions
    await prisma.pointsTransaction.create({
      data: {
        userId: admin.id,
        points: 100,
        reason: 'Initial points',
        type: 'ADD'
  }
    });

    console.log('Database seeded successfully');
  } catch (error) {
    console.error('Error seeding database:', error);
    process.exit(1);
  } finally {
    await prisma.$disconnect();
  }
}

main(); 