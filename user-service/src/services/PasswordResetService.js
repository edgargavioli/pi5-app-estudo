const crypto = require('crypto');
const { PrismaClient } = require('@prisma/client');
const emailService = require('./EmailService');
const prisma = new PrismaClient();

class PasswordResetService {
  async generateResetToken(user) {
    const resetToken = crypto.randomBytes(32).toString('hex');
    const resetExpires = new Date(Date.now() + 3600000); // 1 hour

    await prisma.user.update({
      where: { id: user.id },
      data: {
        resetPasswordToken: resetToken,
        resetPasswordExpires: resetExpires
      }
    });

    return resetToken;
  }

  async requestPasswordReset(email) {
    const user = await prisma.user.findUnique({ where: { email } });
    
    if (!user) {
      throw new Error('User not found');
    }

    const resetToken = await this.generateResetToken(user);
    await emailService.sendPasswordResetEmail(user, resetToken);

    return true;
  }

  async resetPassword(token, newPassword) {
    const user = await prisma.user.findFirst({
      where: {
        resetPasswordToken: token,
        resetPasswordExpires: { gt: new Date() }
      }
    });

    if (!user) {
      throw new Error('Invalid or expired reset token');
    }

    await prisma.user.update({
      where: { id: user.id },
      data: {
        password: newPassword,
        resetPasswordToken: null,
        resetPasswordExpires: null
      }
    });

    return true;
  }
}

module.exports = new PasswordResetService(); 