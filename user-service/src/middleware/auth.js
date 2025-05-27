const tokenService = require('../services/TokenService');

const authenticate = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        status: 'error',
        message: 'No token provided'
      });
    }

    const token = authHeader.split(' ')[1];
    const user = await tokenService.verifyToken(token);

    if (!user.isEmailVerified) {
      return res.status(403).json({
        status: 'error',
        message: 'Please verify your email before accessing this resource'
      });
    }

    if (user.status !== 'active') {
      return res.status(403).json({
        status: 'error',
        message: 'Your account is not active'
      });
    }

    req.user = user;
    next();
  } catch (error) {
    res.status(401).json({
      status: 'error',
      message: 'Invalid or expired token'
    });
  }
};

const authorize = (...roles) => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({
        status: 'error',
        message: 'Authentication required'
      });
    }

    if (!roles.includes(req.user.role)) {
      return res.status(403).json({
        status: 'error',
        message: 'You do not have permission to perform this action'
      });
    }

    next();
  };
};

module.exports = {
  authenticate,
  authorize
}; 