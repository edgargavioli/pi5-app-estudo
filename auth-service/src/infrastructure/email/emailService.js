const nodemailer = require('nodemailer');
require('dotenv').config();

/**
 * Configuração do transporter do Nodemailer
 * 
 * Para configurar o Gmail como provedor SMTP:
 * 1. Ative a verificação em duas etapas na sua conta Google
 * 2. Crie uma senha de app em https://myaccount.google.com/apppasswords
 * 3. Use essa senha no arquivo .env (SMTP_PASS)
 */
const transporter = nodemailer.createTransport({
  host: 'smtp.gmail.com',
  port: 465,
  secure: true, // Use SSL
  auth: {
    user: process.env.SMTP_USER,
    pass: process.env.SMTP_PASS
  },
  debug: true // Adiciona logs detalhados
});

/**
 * Inicializa o serviço de email verificando a conexão
 */
const initEmailService = async () => {
  try {
    // Verificar conexão com o servidor SMTP
    console.log('Tentando conectar ao servidor SMTP com as seguintes credenciais:');
    console.log('Host:', 'smtp.gmail.com');
    console.log('Porta:', 465);
    console.log('Usuário:', process.env.SMTP_USER);
    console.log('Senha configurada?', process.env.SMTP_PASS ? 'Sim' : 'Não');
    
    await transporter.verify();
    console.log('Conexão com o servidor SMTP estabelecida com sucesso');
    return true;
  } catch (error) {
    console.error('Erro ao conectar com o servidor SMTP:', error);
    console.log('Verifique se a verificação em duas etapas está ativada e se a senha de app está correta');
    console.log('Acesse: https://myaccount.google.com/security para configurar');
    return false;
  }
};

/**
 * Envia um email
 * @param {Object} options - Opções do email
 * @returns {Promise<Object>} - Resultado do envio
 */
const sendEmail = async (options) => {
  try {
    const message = {
      from: `"Serviço de Autenticação" <${process.env.EMAIL_FROM}>`,
      to: options.to,
      subject: options.subject,
      text: options.text,
      html: options.html
    };

    const info = await transporter.sendMail(message);
    console.log('Email enviado: %s', info.messageId);
    return info;
  } catch (error) {
    console.error('Erro ao enviar email:', error);
    throw error;
  }
};

/**
 * Envia email de verificação
 * @param {string} email - Email do destinatário
 * @param {string} token - Token de verificação
 * @returns {Promise<Object>} - Resultado do envio
 */
const sendVerificationEmail = async (email, token) => {
  const appUrl = process.env.APP_URL || 'http://localhost:3000';
  const verificationUrl = `${appUrl}/api/auth/verify-email?token=${token}`;
  
  return sendEmail({
    to: email,
    subject: 'Verificação de Email',
    text: `Por favor, verifique seu email clicando no link a seguir: ${verificationUrl}`,
    html: `
      <div style="font-family: Arial, sans-serif; padding: 20px; max-width: 600px; margin: 0 auto; border: 1px solid #e4e4e4; border-radius: 5px;">
        <h2 style="color: #333; text-align: center;">Verificação de Email</h2>
        <p>Olá,</p>
        <p>Obrigado por se registrar em nossa plataforma. Por favor, clique no botão abaixo para verificar seu email:</p>
        <div style="text-align: center; margin: 30px 0;">
          <a href="${verificationUrl}" style="display: inline-block; background-color: #4CAF50; color: white; padding: 12px 24px; text-decoration: none; border-radius: 5px; font-weight: bold;">Verificar Email</a>
        </div>
        <p>Se o botão acima não funcionar, você também pode clicar no link abaixo ou copiá-lo para seu navegador:</p>
        <p style="word-break: break-all;"><a href="${verificationUrl}">${verificationUrl}</a></p>
        <p>Se você não solicitou esta verificação, pode ignorar este email.</p>
        <p>Atenciosamente,<br>Equipe de Suporte</p>
      </div>
    `
  });
};

/**
 * Envia email de recuperação de senha
 * @param {string} email - Email do destinatário
 * @param {string} token - Token de recuperação
 * @returns {Promise<Object>} - Resultado do envio
 */
const sendPasswordResetEmail = async (email, token) => {
  // Usar apenas os primeiros 8 caracteres do token como código de verificação
  const verificationCode = token.substring(0, 8);
  
  return sendEmail({
    to: email,
    subject: 'Código de Verificação para Recuperação de Senha',
    text: `Você solicitou a recuperação de senha. Use o código a seguir para redefinir sua senha: ${verificationCode}`,
    html: `
      <div style="font-family: Arial, sans-serif; padding: 20px; max-width: 600px; margin: 0 auto; border: 1px solid #e4e4e4; border-radius: 5px;">
        <h2 style="color: #333; text-align: center;">Recuperação de Senha</h2>
        <p>Olá,</p>
        <p>Recebemos uma solicitação para redefinir a senha da sua conta. Use o código abaixo para criar uma nova senha:</p>
        <div style="text-align: center; margin: 30px 0;">
          <div style="display: inline-block; background-color: #f2f2f2; padding: 15px 30px; border-radius: 5px; font-size: 24px; font-weight: bold; letter-spacing: 5px; color: #333;">${verificationCode}</div>
        </div>
        <p>Digite este código na tela de verificação do aplicativo para continuar o processo de redefinição de senha.</p>
        <p>Se você não solicitou uma redefinição de senha, ignore este e-mail e sua senha permanecerá inalterada.</p>
        <p>Este código de verificação expirará em 1 hora.</p>
        <p>Atenciosamente,<br>Equipe de Suporte</p>
      </div>
    `
  });
};

/**
 * Envia email de notificação de alteração de senha
 * @param {string} email - Email do destinatário
 * @returns {Promise<Object>} - Resultado do envio
 */
const sendPasswordChangeNotification = async (email) => {
  return sendEmail({
    to: email,
    subject: 'Sua senha foi alterada',
    text: 'Sua senha foi alterada com sucesso. Se você não fez essa alteração, entre em contato com nosso suporte imediatamente.',
    html: `
      <div style="font-family: Arial, sans-serif; padding: 20px; max-width: 600px; margin: 0 auto; border: 1px solid #e4e4e4; border-radius: 5px;">
        <h2 style="color: #333; text-align: center;">Alteração de Senha</h2>
        <p>Olá,</p>
        <p>Sua senha foi alterada com sucesso.</p>
        <p style="color: #e74c3c; font-weight: bold;">Se você não fez essa alteração, entre em contato com nosso suporte imediatamente.</p>
        <p>Atenciosamente,<br>Equipe de Suporte</p>
      </div>
    `
  });
};

module.exports = {
  initEmailService,
  sendEmail,
  sendVerificationEmail,
  sendPasswordResetEmail,
  sendPasswordChangeNotification
}; 