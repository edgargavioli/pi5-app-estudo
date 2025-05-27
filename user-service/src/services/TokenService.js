const jwt = require('jsonwebtoken');
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

class TokenService {
  generateTokens(user) {
    const accessToken = jwt.sign(
      { id: user.id, email: user.email },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN || '1h' }
    );

    const refreshToken = jwt.sign(
      { id: user.id },
      process.env.JWT_REFRESH_SECRET || process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '7d' }
    );

    return { accessToken, refreshToken };
  }

  async verifyToken(token, isRefreshToken = false) {
    try {
      const secret = isRefreshToken 
        ? (process.env.JWT_REFRESH_SECRET || process.env.JWT_SECRET)
        : process.env.JWT_SECRET;
      
      const decoded = jwt.verify(token, secret);
      const user = await prisma.user.findUnique({ where: { id: decoded.id } });
      
      if (!user) {
        throw new Error('User not found');
      }

      return user;
    } catch (error) {
      throw new Error('Invalid token');
    }
  }

  async refreshAccessToken(refreshToken) {
    try {
      const user = await this.verifyToken(refreshToken, true);
      const { accessToken } = this.generateTokens(user);
      return { accessToken, user };
    } catch (error) {
      throw new Error('Invalid refresh token');
    }
  }
}

module.exports = new TokenService(); 