import http from "node:http";
import { app } from "./app.js"
import { logger } from "./application/utils/logger.js";
import rabbitMQService from "./infrastructure/messaging/RabbitMQService.js";

const error = (err) => {
    logger.error(`An error has occurred on start server\n ${err.message}`);
    throw err;
};

const listening = async () => {
    const port = process.env.PORT || 4040;
    logger.info(`🚀 Provas Service running on port ${port}`);
    
    // Inicializar RabbitMQ
    await initializeMessaging();
};

/**
 * Inicializa sistema de mensageria RabbitMQ
 */
async function initializeMessaging() {
    try {
        logger.info('🚀 Inicializando sistema de mensageria...');
        
        const connected = await rabbitMQService.connect();
        if (!connected) {
            throw new Error('Falha ao conectar com RabbitMQ');
        }
        
        logger.info('✅ Sistema de mensageria inicializado com sucesso!');
        
    } catch (error) {
        logger.error('❌ Erro ao inicializar mensageria', { error: error.message });
        
        // Em ambiente de desenvolvimento, continuar sem RabbitMQ
        if (process.env.NODE_ENV === 'development') {
            logger.warn('⚠️ Continuando sem RabbitMQ em modo desenvolvimento');
        } else {
            process.exit(1);
        }
    }
}

/**
 * Graceful shutdown
 */
async function gracefulShutdown(signal) {
    logger.info(`${signal} received. Shutting down gracefully...`);
    
    try {
        // Fechar RabbitMQ
        await rabbitMQService.close();
        
        // Fechar servidor
        server.close(() => {
            logger.info('Server closed');
            process.exit(0);
        });
        
    } catch (error) {
        logger.error('Error during shutdown:', { error: error.message });
        process.exit(1);
    }
}

const server = http.createServer(app);
server.listen(process.env.PORT || 4040);
server.on("error", error);
server.on("listening", listening);

// Handle graceful shutdown
process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
process.on('SIGINT', () => gracefulShutdown('SIGINT'));

// Handle uncaught exceptions
process.on('uncaughtException', async (error) => {
    logger.error('Uncaught Exception:', { error: error.message });
    await rabbitMQService.close();
    process.exit(1);
});

// Handle unhandled promise rejections
process.on('unhandledRejection', async (reason, promise) => {
    logger.error('Unhandled Rejection at:', { promise, reason });
    await rabbitMQService.close();
    process.exit(1);
});