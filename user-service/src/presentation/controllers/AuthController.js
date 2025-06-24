const authService = require('../../infrastructure/services/AuthService');
// const emailService = require('../../infrastructure/services/EmailService');
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
      loggingService.error('Registration failed', {
        error: error.message,
        email: req.body.email,
        name: req.body.name
      });

      // Melhorar mensagens de erro específicas para registro
      if (error.message && error.message.includes('already exists')) {
        const enhancedError = new AppError(
          'A user with this email address already exists',
          400,
          {
            field: 'email',
            value: req.body.email,
            type: 'duplicate_email'
          }
        ).withContext({
          action: 'user_registration',
          attemptedEmail: req.body.email
        }).withSuggestions([
          'Try logging in instead of registering',
          'Use a different email address',
          'Reset your password if you forgot it'
        ]);

        return handleError(enhancedError, res, req);
      }

      if (error.message && error.message.includes('Password validation failed')) {
        const enhancedError = new AppError(
          'Password does not meet security requirements',
          400,
          {
            field: 'password',
            type: 'validation_error',
            requirements: {
              minLength: 8,
              requireUppercase: true,
              requireLowercase: true,
              requireNumbers: true,
              requireSpecialChars: true,
              allowedSpecialChars: '!@#$%^&*(),.?":{}|<>'
            }
          }
        ).withContext({
          action: 'user_registration'
        }).withSuggestions([
          'Use at least 8 characters',
          'Include uppercase and lowercase letters',
          'Add at least one number',
          'Include at least one special character'
        ]);

        return handleError(enhancedError, res, req);
      }

      handleError(error, res, req);
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
      loggingService.error('Login failed', {
        error: error.message,
        email: req.body.email,
        timestamp: new Date().toISOString()
      });

      // Melhorar mensagens de erro específicas para login
      if (error.message && error.message.includes('Invalid credentials')) {
        const enhancedError = new AppError(
          'Email or password is incorrect',
          401,
          {
            field: 'credentials',
            type: 'authentication_failed'
          }
        ).withContext({
          action: 'user_login',
          attemptedEmail: req.body.email,
          timestamp: new Date().toISOString()
        }).withSuggestions([
          'Check if your email is spelled correctly',
          'Verify your password',
          'Try resetting your password if you forgot it',
          'Make sure your account is not locked'
        ]);

        return handleError(enhancedError, res, req);
      }

      if (error.message && error.message.includes('not verified')) {
        const enhancedError = new AppError(
          'Please verify your email address before logging in',
          403,
          {
            field: 'email_verification',
            type: 'email_not_verified',
            email: req.body.email
          }
        ).withContext({
          action: 'user_login',
          requiresEmailVerification: true
        }).withSuggestions([
          'Check your email inbox for verification link',
          'Check your spam/junk folder',
          'Request a new verification email'
        ]);

        return handleError(enhancedError, res, req);
      }

      handleError(error, res, req);
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
      await authService.verifyEmail(token);

      loggingService.info('Email verified successfully', { token: token.substring(0, 10) + '...' });

      res.json({
        status: 'success',
        message: 'Email verified successfully',
        _links: {
          login: {
            href: `${req.protocol}://${req.get('host')}/api/auth/login`,
            method: 'POST'
          }
        }
      });
    } catch (error) {
      loggingService.error('Email verification failed', { error: error.message, token: req.query.token?.substring(0, 10) + '...' });
      handleError(error, res);
    }
  }

  /**
   * 🔍 VALIDAR TOKEN JWT
   */
  async validateToken(req, res) {
    try {
      // Se chegou até aqui, é porque o middleware validou o token
      const user = req.user;

      loggingService.info('Token validated successfully', { userId: user.id });

      res.json({
        status: 'success',
        valid: true,
        data: {
          user: {
            id: user.id,
            email: user.email,
            name: user.name,
            isEmailVerified: user.isEmailVerified
          }
        }
      });
    } catch (error) {
      loggingService.error('Token validation failed', { error: error.message });
      handleError(error, res);
    }
  }

  /**
   * 🚪 LOGOUT (invalidar token)
   */
  async logout(req, res) {
    try {
      const user = req.user;

      loggingService.info('User logged out', { userId: user.id });

      res.json({
        status: 'success',
        message: 'Logout realizado com sucesso',
        _links: {
          login: {
            href: `${req.protocol}://${req.get('host')}/api/auth/login`,
            method: 'POST'
          }
        }
      });
    } catch (error) {
      loggingService.error('Logout failed', { error: error.message });
      handleError(error, res);
    }
  }

  /**
   * 🔄 RENOVAR ACCESS TOKEN
   */
  async refreshAccessToken(req, res) {
    try {
      // O token de refresh vem no header Authorization
      const authHeader = req.headers.authorization;

      if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(401).json({
          status: 'error',
          message: 'Refresh token requerido'
        });
      }

      const refreshToken = authHeader.split(' ')[1];
      const result = await authService.refreshAccessToken(refreshToken);

      loggingService.info('Tokens refreshed successfully', { userId: result.user.id });

      res.json({
        status: 'success',
        data: {
          accessToken: result.accessToken,
          refreshToken: result.refreshToken,
          user: result.user
        },
        _links: {
          profile: {
            href: `${req.protocol}://${req.get('host')}/api/users/${result.user.id}`,
            method: 'GET'
          }
        }
      });
    } catch (error) {
      loggingService.error('Token refresh failed', { error: error.message });
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