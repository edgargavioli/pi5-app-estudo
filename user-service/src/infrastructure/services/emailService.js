// // src/infrastructure/services/emailService.js

// const nodemailer = require('nodemailer');

// class EmailService {
//   constructor() {
//     this.transporter = nodemailer.createTransport({
//       host: process.env.SMTP_HOST || 'smtp.example.com',
//       port: process.env.SMTP_PORT || 587,
//       secure: false,
//       auth: {
//         user: process.env.SMTP_USER,
//         pass: process.env.SMTP_PASS
//       }
//     });
//   }

//   async sendEmail(to, subject, text, html) {
//     try {
//       // For development, just log the email instead of sending
//       if (process.env.NODE_ENV === 'development') {
//         console.log('Email would be sent:', { to, subject, text });
//         return { messageId: 'dev-' + Date.now() };
//       }

//       const info = await this.transporter.sendMail({
//         from: process.env.FROM_EMAIL || 'noreply@example.com',
//         to,
//         subject,
//         text,
//         html
//       });

//       return info;
//     } catch (error) {
//       console.error('Error sending email:', error);
//       throw error;
//     }
//   }

//   async sendVerificationEmail(email, token) {
//     const subject = 'Verify your email address';
//     const text = `Please verify your email by clicking this link: ${process.env.FRONTEND_URL}/verify-email?token=${token}`;
//     const html = `<p>Please verify your email by clicking <a href="${process.env.FRONTEND_URL}/verify-email?token=${token}">this link</a></p>`;
    
//     return this.sendEmail(email, subject, text, html);
//   }

//   async sendPasswordResetEmail(email, token) {
//     const subject = 'Reset your password';
//     const text = `Reset your password by clicking this link: ${process.env.FRONTEND_URL}/reset-password?token=${token}`;
//     const html = `<p>Reset your password by clicking <a href="${process.env.FRONTEND_URL}/reset-password?token=${token}">this link</a></p>`;
    
//     return this.sendEmail(email, subject, text, html);
//   }
// }

// module.exports = new EmailService(); 