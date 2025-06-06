import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function waitForDatabase(retries = 10, delay = 5000) {
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

// Inicializar a conexão
waitForDatabase()
  .catch((error) => {
    console.error('Failed to connect to database:', error);
    process.exit(1);
  });

export default prisma;
