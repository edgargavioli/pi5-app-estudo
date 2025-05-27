const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { handleError, AppError } = require('../utils/errorHandler');
const tokenService = require('../services/TokenService');
const emailService = require('../services/EmailService');
const { createHateoasLinks } = require('../utils/hateoas');
const authService = require('../services/AuthService');
const passwordResetService = require('../services/PasswordResetService');
const { validateRequest } = require('../middleware/validation');
const { rateLimiter } = require('../middleware/rateLimiter');
const LoggingService = require('../services/LoggingService');
const { validatePassword } = require('../utils/passwordValidator');

const prisma = new PrismaClient();

class AuthController {
  async register(req, res) {
    try {
      const { email, password, name } = req.body;

      // Validate password strength
      validatePassword(password);

      const existingUser = await prisma.user.findUnique({
        where: { email }
      });

      if (existingUser) {
        throw new AppError('Email already registered', 400);
      }

      const hashedPassword = await bcrypt.hash(password, 10);

      const user = await prisma.user.create({
        data: {
        email,
          password: hashedPassword,
          name,
          points: 0,
          isEmailVerified: false
        }
      });

      // Send verification email
      await emailService.sendVerificationEmail(user);
      // Send welcome email
      await emailService.sendWelcomeEmail(user);

      const token = jwt.sign(
        { id: user.id, email: user.email },
        process.env.JWT_SECRET,
        { expiresIn: process.env.JWT_EXPIRES_IN }
      );

      LoggingService.info('User registered successfully', { userId: user.id });

      res.status(201).json({
        token,
          user: {
            id: user.id,
          email: user.email,
          name: user.name,
          points: user.points,
          isEmailVerified: user.isEmailVerified
        }
      });
    } catch (error) {
      handleError(error, res);
    }
  }

  async login(req, res) {
    try {
      const { email, password } = req.body;

      const user = await prisma.user.findUnique({
        where: { email }
      });

      if (!user) {
        LoggingService.warn('Login attempt failed - user not found', { email });
        throw new AppError('Invalid credentials', 401);
      }

      const isValidPassword = await bcrypt.compare(password, user.password);
      if (!isValidPassword) {
        LoggingService.warn('Login attempt failed - invalid password', { userId: user.id });
        throw new AppError('Invalid credentials', 401);
      }

      const token = jwt.sign(
        { id: user.id, email: user.email },
        process.env.JWT_SECRET,
        { expiresIn: process.env.JWT_EXPIRES_IN }
      );

      LoggingService.info('User logged in successfully', { userId: user.id });

      res.json({
        token,
          user: {
            id: user.id,
            email: user.email,
          name: user.name,
          points: user.points,
          isEmailVerified: user.isEmailVerified
        }
      });
    } catch (error) {
      handleError(error, res);
    }
  }

  async refreshToken(req, res) {
    try {
      const { refreshToken } = req.body;

      if (!refreshToken) {
        throw new AppError('Refresh token is required', 400);
      }

      const decoded = jwt.verify(refreshToken, process.env.JWT_SECRET);
      const user = await prisma.user.findUnique({
        where: { id: decoded.id }
      });

      if (!user) {
        throw new AppError('Invalid refresh token', 401);
      }

      const token = jwt.sign(
        { id: user.id, email: user.email },
        process.env.JWT_SECRET,
        { expiresIn: process.env.JWT_EXPIRES_IN }
      );

      LoggingService.info('Token refreshed successfully', { userId: user.id });

      res.json({ token });
    } catch (error) {
      handleError(error, res);
    }
  }

  async verifyEmail(req, res) {
    try {
      const { token } = req.query;

      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      const user = await prisma.user.findUnique({
        where: { id: decoded.id }
      });

      if (!user) {
        throw new AppError('Invalid verification token', 400);
      }

      if (user.isEmailVerified) {
        throw new AppError('Email already verified', 400);
      }

      await prisma.user.update({
        where: { id: user.id },
        data: { isEmailVerified: true }
      });

      LoggingService.info('Email verified successfully', { userId: user.id });

      res.json({ message: 'Email verified successfully' });
    } catch (error) {
      handleError(error, res);
    }
  }

  async requestPasswordReset(req, res) {
    try {
      const { email } = req.body;

      const user = await prisma.user.findUnique({
        where: { email }
      });

      if (!user) {
        throw new AppError('User not found', 404);
      }

      const resetToken = jwt.sign(
        { id: user.id },
        process.env.JWT_SECRET,
        { expiresIn: '1h' }
      );

      await prisma.user.update({
        where: { id: user.id },
        data: {
          resetPasswordToken: resetToken,
          resetPasswordExpires: new Date(Date.now() + 3600000) // 1 hour
        }
      });

      // Send password reset email
      await emailService.sendPasswordResetEmail(user, resetToken);

      LoggingService.info('Password reset email sent', { userId: user.id });

      res.json({ message: 'Password reset email sent' });
    } catch (error) {
      handleError(error, res);
    }
  }

  async resetPassword(req, res) {
    try {
      const { token, password } = req.body;

      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      const user = await prisma.user.findUnique({
        where: { id: decoded.id }
      });

      if (!user) {
        throw new AppError('Invalid reset token', 400);
      }

      if (user.resetPasswordExpires < new Date()) {
        throw new AppError('Reset token has expired', 400);
      }

      const hashedPassword = await bcrypt.hash(password, 10);

      await prisma.user.update({
        where: { id: user.id },
        data: {
          password: hashedPassword,
          resetPasswordToken: null,
          resetPasswordExpires: null
        }
      });

      LoggingService.info('Password reset successfully', { userId: user.id });

      res.json({ message: 'Password reset successfully' });
    } catch (error) {
      handleError(error, res);
    }
  }
}

module.exports = new AuthController(); 