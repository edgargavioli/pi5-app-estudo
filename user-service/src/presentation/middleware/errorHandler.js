const logger = require('../../infrastructure/utils/logger');

const errorHandler = (err, req, res, next) => {
  logger.error('Error:', {
    message: err.message,
    stack: err.stack,
    path: req.path,
    method: req.method
  });

  // Handle Prisma errors
  if (err.code) {
    switch (err.code) {
      case 'P2002':
        return res.status(409).json({
          status: 'error',
          message: 'A record with this value already exists'
        });
      case 'P2025':
        return res.status(404).json({
          status: 'error',
          message: 'Record not found'
        });
      default:
        return res.status(500).json({
          status: 'error',
          message: 'Database error occurred'
        });
    }
  }

  // Handle JWT errors
  if (err.name === 'JsonWebTokenError') {
    return res.status(401).json({
      status: 'error',
      message: 'Invalid token'
    });
  }

  if (err.name === 'TokenExpiredError') {
    return res.status(401).json({
      status: 'error',
      message: 'Token expired'
    });
  }

  // Handle validation errors
  if (err.isJoi) {
    return res.status(400).json({
      status: 'error',
      message: err.details[0].message
    });
  }

  // Default error
  res.status(err.status || 500).json({
    status: 'error',
    message: err.message || 'Internal server error',
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
  });
};

module.exports = errorHandler; 