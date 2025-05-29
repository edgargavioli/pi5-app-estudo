const authService = require('../../infrastructure/services/AuthService');
const emailService = require('../../infrastructure/services/EmailService');
const loggingService = require('../../infrastructure/services/LoggingService');
const { handleError, AppError } = require('../../middleware/errorHandler');

class AuthController {
  async register(req, res) {
    try {
      const result = await authService.register(req.body);
      
      loggingService.info('User registered successfully', { userId: result.user.id });

      res.status(201).json({
        status: 'success',
        data: result,
        _links: {
          login: {
            href: `${req.protocol}://${req.get('host')}/api/auth/login`,
            method: 'POST'
          },
          profile: {
            href: `${req.protocol}://${req.get('host')}/api/users/${result.user.id}`,
            method: 'GET'
          }
        }
      });
    } catch (error) {
      loggingService.error('Registration failed', { error: error.message });
      handleError(error, res);
    }
  }

  async login(req, res) {
    try {
      const { email, password } = req.body;
      const result = await authService.login(email, password);

      loggingService.info('User logged in successfully', { userId: result.user.id });

      res.json({
        status: 'success',
        data: result,
        _links: {
          profile: {
            href: `${req.protocol}://${req.get('host')}/api/users/${result.user.id}`,
            method: 'GET'
          },
          refresh: {
            href: `${req.protocol}://${req.get('host')}/api/auth/refresh`,
            method: 'POST'
          },
          logout: {
            href: `${req.protocol}://${req.get('host')}/api/auth/logout`,
            method: 'POST'
          }
        }
      });
    } catch (error) {
      loggingService.error('Login failed', { error: error.message, email: req.body.email });
      handleError(error, res);
    }
  }

  async refreshToken(req, res) {
    try {
      const { refreshToken } = req.body;
      const result = await authService.refreshToken(refreshToken);

      loggingService.info('Token refreshed successfully');

      res.json({
        status: 'success',
        data: result,
        _links: {
          refresh: {
            href: `${req.protocol}://${req.get('host')}/api/auth/refresh`,
            method: 'POST'
          }
        }
      });
    } catch (error) {
      loggingService.error('Token refresh failed', { error: error.message });
      handleError(error, res);
    }
  }

  async verifyEmail(req, res) {
    try {
      const { token } = req.query;
      const result = await authService.verifyEmail(token);

      loggingService.info('Email verified successfully', { userId: result.user.id });

      res.json({
        status: 'success',
        data: result,
        _links: {
          login: {
            href: `${req.protocol}://${req.get('host')}/api/auth/login`,
            method: 'POST'
          }
        }
      });
    } catch (error) {
      loggingService.error('Email verification failed', { error: error.message });
      handleError(error, res);
    }
  }

  async logout(req, res) {
    try {
      // In a stateless JWT system, logout is handled client-side
      // But we can log the event for security monitoring
      loggingService.info('User logged out', { userId: req.user?.id });

      res.json({
        success: true,
        message: 'Logged out successfully'
      });
    } catch (error) {
      handleError(error, res);
    }
  }

  async requestPasswordReset(req, res) {
    try {
      const { email } = req.body;
      
      // Generate password reset token
      const resetToken = authService.generateToken({ email, type: 'password-reset' }, '1h');
      
      // Send password reset email
      await emailService.sendPasswordResetEmail(email, resetToken);
      
      loggingService.info('Password reset requested', { email });
      
      res.json({
        success: true,
        message: 'Password reset email sent'
      });
    } catch (error) {
      loggingService.error('Password reset request failed', { error: error.message, email: req.body.email });
      handleError(error, res);
    }
  }

  async resetPassword(req, res) {
    try {
      const { token, newPassword } = req.body;
      
      const result = await authService.resetPassword(token, newPassword);
      
      loggingService.info('Password reset successfully', { userId: result.user.id });
      
      res.json({
        success: true,
        message: 'Password reset successfully',
        user: result.user
      });
    } catch (error) {
      loggingService.error('Password reset failed', { error: error.message });
      handleError(error, res);
    }
  }
}

module.exports = new AuthController(); 