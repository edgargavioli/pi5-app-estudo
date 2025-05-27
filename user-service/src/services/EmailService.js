const nodemailer = require('nodemailer');
const jwt = require('jsonwebtoken');

class EmailService {
  constructor() {
    this.transporter = nodemailer.createTransport({
      host: process.env.SMTP_HOST,
      port: process.env.SMTP_PORT,
      secure: process.env.SMTP_PORT === '465',
      auth: {
        user: process.env.SMTP_USER,
        pass: process.env.SMTP_PASS
      }
    });
  }

  async sendVerificationEmail(user) {
    // Mocked for development: skip real email sending
    console.log(`[MOCK] Would send verification email to ${user.email}`);
    return true;
  }

  async sendPasswordResetEmail(user, resetToken) {
    const resetUrl = `${process.env.FRONTEND_URL}/reset-password?token=${resetToken}`;

    await this.transporter.sendMail({
      from: `"Study App" <${process.env.SMTP_USER}>`,
      to: user.email,
      subject: 'Reset your password',
      html: `
        <h1>Password Reset Request</h1>
        <p>You requested to reset your password. Click the link below to proceed:</p>
        <a href="${resetUrl}">Reset Password</a>
        <p>This link will expire in 1 hour.</p>
        <p>If you didn't request this, please ignore this email.</p>
      `
    });
  }

  async sendWelcomeEmail(user) {
    // Mocked for development: skip real email sending
    console.log(`[MOCK] Would send welcome email to ${user.email}`);
    return true;
  }
}

module.exports = new EmailService(); 