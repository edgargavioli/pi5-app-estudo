import { PrismaClient } from "./client/index.js";

const prisma = new PrismaClient({
    log: ['query', 'info', 'warn', 'error'],
});

prisma.$connect()
    .then(() => {
        console.log('✅ Conectado ao banco de dados via Prisma');
    })
    .catch((error) => {
        console.error('❌ Erro ao conectar ao banco de dados:', error);
    });

// Graceful shutdown
process.on('beforeExit', async () => {
    await prisma.$disconnect();
});

export default prisma;
