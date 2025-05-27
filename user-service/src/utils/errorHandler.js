const LoggingService = require('../services/LoggingService');

class AppError extends Error {
  constructor(message, statusCode) {
    super(message);
    this.statusCode = statusCode;
    this.status = `${statusCode}`.startsWith('4') ? 'fail' : 'error';
    this.isOperational = true;

    Error.captureStackTrace(this, this.constructor);
  }
}

const handleError = (error, res) => {
  // Log the error
  LoggingService.error('Error occurred', {
    error: error.message,
    stack: error.stack,
    statusCode: error.statusCode
  });

  // Handle operational errors (expected errors)
  if (error.isOperational) {
    return res.status(error.statusCode).json({
      status: error.status,
      message: error.message
    });
  }

  // Handle programming or unknown errors
  return res.status(500).json({
    status: 'error',
    message: 'Something went wrong'
  });
};

module.exports = {
  AppError,
  handleError
}; 