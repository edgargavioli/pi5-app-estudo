const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { PrismaClient } = require('@prisma/client');
const { AppError } = require('../../middleware/errorHandler');
const EmailService = require('./EmailService');

const prisma = new PrismaClient();

/**
 * Authentication Service - Infrastructure Layer
 * Handles JWT operations and authentication logic
 */
class AuthService {
  async register(userData) {
    try {
      const { email, password, name } = userData;

      // Check if user already exists
      const existingUser = await prisma.user.findUnique({
        where: { email }
      });

      if (existingUser) {
        throw new AppError('User already exists with this email', 400);
      }

      // Hash password
      const hashedPassword = await bcrypt.hash(password, 10);

      // Create user
      const user = await prisma.user.create({
        data: {
          email,
          password: hashedPassword,
          name,
          isEmailVerified: false
        }
      });

      // Generate verification token
      const verificationToken = this.generateToken({ userId: user.id, type: 'verification' }, '24h');

      // Send verification email
      await EmailService.sendVerificationEmail(email, verificationToken);

      // Generate auth tokens
      const accessToken = this.generateToken({ userId: user.id });
      const refreshToken = this.generateToken({ userId: user.id, type: 'refresh' }, '7d');

      return {
        user: {
          id: user.id,
          email: user.email,
          name: user.name,
          isEmailVerified: user.isEmailVerified
        },
        accessToken,
        refreshToken
      };
    } catch (error) {
      throw error;
    }
  }

  async login(email, password) {
    try {
      // Find user
      const user = await prisma.user.findUnique({
        where: { email }
      });

      if (!user) {
        throw new AppError('Invalid credentials', 401);
      }

      // Verify password
      const isValidPassword = await bcrypt.compare(password, user.password);
      if (!isValidPassword) {
        throw new AppError('Invalid credentials', 401);
      }

      // Update last login
      await prisma.user.update({
        where: { id: user.id },
        data: { lastLogin: new Date() }
      });

      // Generate tokens
      const accessToken = this.generateToken({ userId: user.id });
      const refreshToken = this.generateToken({ userId: user.id, type: 'refresh' }, '7d');

      return {
        user: {
          id: user.id,
          email: user.email,
          name: user.name,
          isEmailVerified: user.isEmailVerified,
          lastLogin: new Date()
        },
        accessToken,
        refreshToken
      };
    } catch (error) {
      throw error;
    }
  }

  async refreshToken(refreshToken) {
    try {
      const decoded = this.verifyToken(refreshToken);
      
      if (decoded.type !== 'refresh') {
        throw new AppError('Invalid refresh token', 401);
      }

      const user = await prisma.user.findUnique({
        where: { id: decoded.userId }
      });

      if (!user) {
        throw new AppError('User not found', 404);
      }

      // Generate new access token
      const accessToken = this.generateToken({ userId: user.id });

      return { accessToken };
    } catch (error) {
      throw new AppError('Invalid refresh token', 401);
    }
  }

  generateToken(payload, expiresIn = process.env.JWT_EXPIRES_IN || '24h') {
    return jwt.sign(payload, process.env.JWT_SECRET, { expiresIn });
  }

  verifyToken(token) {
    try {
      return jwt.verify(token, process.env.JWT_SECRET);
    } catch (error) {
      throw new AppError('Invalid token', 401);
    }
  }

  async verifyEmail(token) {
    try {
      const decoded = this.verifyToken(token);
      
      if (decoded.type !== 'verification') {
        throw new AppError('Invalid verification token', 400);
      }

      const user = await prisma.user.update({
        where: { id: decoded.userId },
        data: { isEmailVerified: true }
      });

      return {
        message: 'Email verified successfully',
        user: {
          id: user.id,
          email: user.email,
          name: user.name,
          isEmailVerified: user.isEmailVerified
        }
      };
    } catch (error) {
      throw error;
    }
  }

  async resetPassword(token, newPassword) {
    try {
      const decoded = this.verifyToken(token);
      
      if (decoded.type !== 'password-reset') {
        throw new AppError('Invalid password reset token', 400);
      }

      // Hash new password
      const hashedPassword = await bcrypt.hash(newPassword, 10);

      // Find user by email and update password
      const user = await prisma.user.update({
        where: { email: decoded.email },
        data: { password: hashedPassword }
      });

      return {
        message: 'Password reset successfully',
        user: {
          id: user.id,
          email: user.email,
          name: user.name
        }
      };
    } catch (error) {
      throw error;
    }
  }
}

module.exports = new AuthService(); 