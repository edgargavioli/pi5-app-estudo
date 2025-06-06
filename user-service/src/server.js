require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const swaggerJsDoc = require('swagger-jsdoc');
const swaggerUi = require('swagger-ui-express');
const { errorHandler } = require('./middleware/errorHandler');
const logger = require('./infrastructure/services/LoggingService');
const prisma = require('./infrastructure/database/config');

// RabbitMQ Integration
const rabbitMQService = require('./infrastructure/messaging/RabbitMQService');
const EventHandler = require('./infrastructure/messaging/EventHandler');

const app = express();

// Middleware
app.use(helmet());
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: true
}));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));
app.use(morgan('combined'));

// Logging middleware
app.use(logger.logRequest.bind(logger));

// API Routes
app.use('/api/auth', require('./presentation/routes/authRoutes'));
app.use('/api/users', require('./presentation/routes/userRoutes'));
app.use('/api/wrapped', require('./presentation/routes/wrapped'));

// Health check endpoint simples (em vez de rota separada)
app.get('/api/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    version: '1.0.0'
  });
});

// Swagger Documentation
const swaggerOptions = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'User Service API - DDD Architecture',
      version: '1.0.0',
      description: 'User management microservice with Domain-Driven Design, HATEOAS, and gamification integration',
    },
    servers: [
      {
        url: `http://localhost:${process.env.PORT || 3000}`,
      },
    ],
    components: {
      securitySchemes: {
        bearerAuth: {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT',
        },
      },
    },
  },
  apis: ['./src/presentation/routes/*.js'],
};

const specs = swaggerJsDoc(swaggerOptions);
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(specs));

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    message: 'User Service - Domain-Driven Design Architecture',
    version: '1.0.0',
    architecture: 'DDD (Domain-Driven Design)',
    features: [
      'HATEOAS Implementation',
      'Swagger Documentation', 
      'Rate Limiting',
      'Comprehensive Logging',
      'Gamification Integration',
      'RabbitMQ Messaging'
    ],
    endpoints: {
      documentation: '/api-docs',
      health: '/api/health',
      auth: '/api/auth',
      users: '/api/users',
      wrapped: '/api/wrapped'
    }
  });
});

// Error handling middleware
app.use(logger.logError.bind(logger));
app.use(errorHandler);

// Database connection and server start
const PORT = process.env.PORT || 3000;

/**
 * Inicializa RabbitMQ e Event Handlers
 */
async function initializeMessaging() {
  try {
    logger.info('🚀 Inicializando sistema de mensageria...');
    
    // Conectar ao RabbitMQ
    const connected = await rabbitMQService.connect();
    if (!connected) {
      throw new Error('Falha ao conectar com RabbitMQ');
    }
    
    // Inicializar Event Handlers
    const eventHandler = new EventHandler();
    await eventHandler.startConsumers();
    
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

const server = app.listen(PORT, async () => {
  console.log(`User Service is running on port ${PORT}`);
  console.log(`Architecture: Domain-Driven Design (DDD)`);
  console.log(`API Documentation available at http://localhost:${PORT}/api-docs`);
  console.log(`Features: HATEOAS, Swagger, Middleware, Rate Limiting, RabbitMQ`);
  
  // Inicializar sistema de mensageria
  await initializeMessaging();
});

// Handle graceful shutdown
async function gracefulShutdown(signal) {
  console.log(`${signal} received. Shutting down gracefully...`);
  
  try {
    // Fechar RabbitMQ
    await rabbitMQService.close();
    
    // Fechar conexão com banco
    await prisma.$disconnect();
    
    // Fechar servidor
    server.close(() => {
      console.log('Server closed');
      process.exit(0);
    });
    
  } catch (error) {
    console.error('Error during shutdown:', error);
    process.exit(1);
  }
}

process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
process.on('SIGINT', () => gracefulShutdown('SIGINT'));

// Handle uncaught exceptions
process.on('uncaughtException', async (error) => {
  console.error('Uncaught Exception:', error);
  await rabbitMQService.close();
  await prisma.$disconnect();
  process.exit(1);
});

// Handle unhandled promise rejections
process.on('unhandledRejection', async (reason, promise) => {
  console.error('Unhandled Rejection at:', promise, 'reason:', reason);
  await rabbitMQService.close();
  await prisma.$disconnect();
  process.exit(1);
}); 