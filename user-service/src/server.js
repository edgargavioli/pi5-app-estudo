require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const promMid = require('express-prometheus-middleware');
const swaggerJsDoc = require('swagger-jsdoc');
const swaggerUi = require('swagger-ui-express');
const { errorHandler } = require('./middleware/errorHandler');
const loggingService = require('./infrastructure/services/LoggingService');
const QueueService = require('./infrastructure/services/QueueService');
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

// Prometheus metrics middleware
app.use(promMid({
  metricsPath: '/metrics',
  collectDefaultMetrics: true,
  requestDurationBuckets: [0.1, 0.5, 1, 1.5],
  requestLengthBuckets: [515, 1024, 5120, 10240],
  responseLengthBuckets: [515, 1024, 5120, 10240],
}));

// Logging middleware
app.use(logger.logRequest.bind(logger));

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

// API Routes - CORRIGIDO: removidas duplicatas
app.use('/api/auth', require('./presentation/routes/authRoutes'));
app.use('/api/users', require('./presentation/routes/userRoutes'));
app.use('/api/wrapped', require('./presentation/routes/wrapped'));

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    version: '1.0.0'
  });
});

// Health check endpoint alternativo
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date(),
    architecture: 'DDD',
    version: '1.0.0'
  });
});

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

const server = app.listen(PORT, async () => {
  console.log(`User Service is running on port ${PORT}`);
  console.log(`Architecture: Domain-Driven Design (DDD)`);
  console.log(`API Documentation available at http://localhost:${PORT}/api-docs`);
  console.log(`Features: HATEOAS, Swagger, Middleware, Rate Limiting`);

  // Connect to RabbitMQ for notifications (QueueService)
  try {
    await QueueService.connect();
    console.log('✅ Connected to RabbitMQ for notifications');
  } catch (error) {
    console.error('❌ Failed to connect to RabbitMQ for notifications:', error.message);
  }

  // Connect to RabbitMQ for events processing (RabbitMQService + EventHandler)
  try {
    await rabbitMQService.connect();
    console.log('✅ Connected to RabbitMQ for events');

    // Initialize EventHandler to process streak events
    const eventHandler = new EventHandler();
    await eventHandler.startConsumers();
    console.log('✅ Event handlers initialized for streak processing');
  } catch (error) {
    console.error('❌ Failed to connect to RabbitMQ for events:', error.message);
  }
});

// Handle graceful shutdown
process.on('SIGTERM', async () => {
  console.log('SIGTERM received. Shutting down gracefully...');
  await QueueService.disconnect();
  await rabbitMQService.close();
  await prisma.$disconnect();
  server.close(() => {
    console.log('Server closed');
    process.exit(0);
  });
});

process.on('SIGINT', async () => {
  console.log('SIGINT received. Shutting down gracefully...');
  await QueueService.disconnect();
  await rabbitMQService.close();
  await prisma.$disconnect();
  server.close(() => {
    console.log('Server closed');
    process.exit(0);
  });
});

// Handle uncaught exceptions
process.on('uncaughtException', async (error) => {
  console.error('Uncaught Exception:', error);
  await QueueService.disconnect();
  await rabbitMQService.close();
  await prisma.$disconnect();
  process.exit(1);
});

// Handle unhandled promise rejections
process.on('unhandledRejection', async (reason, promise) => {
  console.error('Unhandled Rejection at:', promise, 'reason:', reason);
  await QueueService.disconnect();
  await rabbitMQService.close();
  await prisma.$disconnect();
  process.exit(1);
});