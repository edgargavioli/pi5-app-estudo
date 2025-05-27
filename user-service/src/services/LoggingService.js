const winston = require('winston');
const { format } = winston;

class LoggingService {
  constructor() {
    this.logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
      format: format.combine(
        format.timestamp(),
        format.errors({ stack: true }),
        format.json()
  ),
      defaultMeta: { service: 'user-service' },
  transports: [
    new winston.transports.File({
          filename: 'logs/error.log', 
          level: 'error',
          maxsize: 5242880, // 5MB
          maxFiles: 5,
    }),
    new winston.transports.File({
          filename: 'logs/combined.log',
          maxsize: 5242880, // 5MB
          maxFiles: 5,
    })
  ]
});

    // If we're not in production, log to the console as well
if (process.env.NODE_ENV !== 'production') {
      this.logger.add(new winston.transports.Console({
        format: format.combine(
          format.colorize(),
          format.simple()
    )
  }));
}
  }

  info(message, meta = {}) {
    this.logger.info(message, meta);
  }

  error(message, meta = {}) {
    this.logger.error(message, meta);
  }

  warn(message, meta = {}) {
    this.logger.warn(message, meta);
  }

  debug(message, meta = {}) {
    this.logger.debug(message, meta);
  }

  // Log HTTP requests
  logRequest(req, res, next) {
    const start = Date.now();
    res.on('finish', () => {
      const duration = Date.now() - start;
      this.info('HTTP Request', {
        method: req.method,
        url: req.originalUrl,
        status: res.statusCode,
        duration: `${duration}ms`,
        ip: req.ip,
        userAgent: req.get('user-agent')
      });
    });
    next();
  }

  // Log errors
  logError(err, req, res, next) {
    this.error('Error occurred', {
      error: err.message,
      stack: err.stack,
      method: req.method,
      url: req.originalUrl,
      body: req.body,
      params: req.params,
      query: req.query,
      ip: req.ip,
      userAgent: req.get('user-agent')
    });
    next(err);
  }

  logAuthAttempt(userId, success, ip) {
    this.info('Authentication attempt', {
      userId,
      success,
      ip,
      timestamp: new Date()
    });
  }

  logPasswordReset(userId, success) {
    this.info('Password reset attempt', {
      userId,
      success,
      timestamp: new Date()
    });
  }

  logSocialAuth(provider, userId, success) {
    this.info('Social authentication attempt', {
      provider,
      userId,
      success,
      timestamp: new Date()
    });
  }
}

module.exports = new LoggingService(); 