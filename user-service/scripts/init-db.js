const { execSync } = require('child_process');
const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

async function waitForDatabase(retries = 10, delay = 10000) {
  for (let i = 0; i < retries; i++) {
    try {
      await prisma.$connect();
      console.log('Database connection successful');
      return true;
    } catch (error) {
      console.log(`Database connection attempt ${i + 1} failed. Retrying in ${delay/1000} seconds...`);
      await new Promise(resolve => setTimeout(resolve, delay));
    }
  }
  throw new Error('Could not connect to database after multiple attempts');
}

async function initDatabase() {
  try {
    console.log('Waiting for database connection...');
    await waitForDatabase();

    console.log('Running database migrations...');
    try {
      execSync('npx prisma migrate deploy', { stdio: 'inherit' });
    } catch (error) {
      console.log('Migration failed, trying to create initial migration...');
      execSync('npx prisma migrate dev --name init', { stdio: 'inherit' });
    }

    console.log('Generating Prisma Client...');
    execSync('npx prisma generate', { stdio: 'inherit' });

    console.log('Database initialization completed successfully!');
  } catch (error) {
    console.error('Error initializing database:', error);
    process.exit(1);
  } finally {
    await prisma.$disconnect();
  }
}

initDatabase(); 