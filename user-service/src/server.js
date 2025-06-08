require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const swaggerJsDoc = require('swagger-jsdoc');
const swaggerUi = require('swagger-ui-express');
const { errorHandler } = require('./middleware/errorHandler');
const loggingService = require('./infrastructure/services/LoggingService');
const QueueService = require('./infrastructure/services/QueueService');
const prisma = require('./infrastructure/database/config');

const app = express();

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());

// Logging
app.use(loggingService.logRequest.bind(loggingService));
app.use(morgan('combined'));

// Swagger configuration
const swaggerOptions = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'User Service API',
      version: '1.0.0',
      description: 'API documentation for the User Service (Authentication & User Management) - Following DDD Architecture'
    },
    servers: [
      {
        url: `http://localhost:${process.env.PORT || 3000}`,
        description: 'Development server'
      }
    ],
    components: {
      securitySchemes: {
        bearerAuth: {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT'
        }
      }
    }
  },
  apis: [
    './src/presentation/routes/*.js',
    './src/presentation/controllers/*.js',
    './src/domain/**/*.js'
  ]
};

const swaggerDocs = swaggerJsDoc(swaggerOptions);
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerDocs));

// Routes - DDD Presentation Layer
app.use('/api/auth', require('./presentation/routes/auth'));
app.use('/api/users', require('./presentation/routes/userRoutes'));
app.use('/api/wrapped', require('./presentation/routes/wrapped'));

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date(),
    architecture: 'DDD',
    version: '1.0.0'
  });
});

// Error handling
app.use(errorHandler);

// Database connection and server start
const PORT = process.env.PORT || 3000;

const server = app.listen(PORT, async () => {
  console.log(`User Service is running on port ${PORT}`);
  console.log(`Architecture: Domain-Driven Design (DDD)`);
  console.log(`API Documentation available at http://localhost:${PORT}/api-docs`);
  console.log(`Features: HATEOAS, Swagger, Middleware, Rate Limiting`);

  // Connect to RabbitMQ
  try {
    await QueueService.connect();
    console.log('✅ Connected to RabbitMQ');
  } catch (error) {
    console.error('❌ Failed to connect to RabbitMQ:', error.message);
    // Don't exit the process, just log the error
    // The application can still function without the queue
  }
});

// Handle graceful shutdown
process.on('SIGTERM', async () => {
  console.log('SIGTERM received. Shutting down gracefully...');
  await QueueService.disconnect();
  await prisma.$disconnect();
  server.close(() => {
    console.log('Server closed');
    process.exit(0);
  });
});

process.on('SIGINT', async () => {
  console.log('SIGINT received. Shutting down gracefully...');
  await QueueService.disconnect();
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
  await prisma.$disconnect();
  process.exit(1);
});

// Handle unhandled promise rejections
process.on('unhandledRejection', async (reason, promise) => {
  console.error('Unhandled Rejection at:', promise, 'reason:', reason);
  await QueueService.disconnect();
  await prisma.$disconnect();
  process.exit(1);
});