const bcrypt = require('bcrypt');
const { v4: uuidv4 } = require('uuid');
const User = require('../../domain/entities/User');
const jwtService = require('../../infrastructure/jwt/jwtService');
const emailService = require('../../infrastructure/email/emailService');
const rabbitmqService = require('../../infrastructure/rabbitmq/rabbitmqService');

/**
 * Caso de uso para registrar um novo usuário
 */
class RegisterUser {
  /**
   * @param {UserRepository} userRepository - Repositório de usuários
   */
  constructor(userRepository) {
    this.userRepository = userRepository;
  }

  /**
   * Executa o caso de uso para registrar um novo usuário
   * @param {string} email - Email do usuário
   * @param {string} password - Senha do usuário
   * @param {string} name - Nome do usuário
   * @returns {Promise<Object>} - Objeto com usuário e tokens
   */
  async execute(email, password, name = '') {
    // Verificar se o email já está em uso
    const existingUser = await this.userRepository.findByEmail(email);
    if (existingUser) {
      throw new Error('Email já está em uso');
    }

    // Validar formato do email
    if (!this.isValidEmail(email)) {
      throw new Error('Formato de email inválido');
    }

    // Validar formato da senha
    if (!this.isValidPassword(password)) {
      throw new Error('A senha deve ter pelo menos 8 caracteres, incluindo letras maiúsculas, minúsculas e números');
    }

    // Validar nome (opcional)
    if (name && name.length > 100) {
      throw new Error('O nome não pode exceder 100 caracteres');
    }

    // Criptografar a senha
    const salt = parseInt(process.env.PASSWORD_SALT_ROUNDS) || 10;
    const hashedPassword = await bcrypt.hash(password, salt);

    // Criar nova instância de usuário
    const newUser = new User(
      uuidv4(),
      email,
      hashedPassword,
      name,
      'pending',  // status inicial (pendente de verificação)
      0,          // tentativas de login
      null,       // bloqueio
      new Date(),
      new Date()
    );

    // Salvar usuário no banco de dados
    const savedUser = await this.userRepository.save(newUser);

    // Gerar tokens JWT
    const accessToken = jwtService.generateAccessToken({
      id: savedUser.id,
      email: savedUser.email
    });

    const refreshToken = jwtService.generateRefreshToken({
      id: savedUser.id,
      email: savedUser.email
    });

    // Enviar email de verificação se habilitado
    if (process.env.EMAIL_VERIFICATION_ENABLED === 'true') {
      try {
        // Gerar token para verificação de email (usando JWT para simplificar)
        const verificationToken = jwtService.generateAccessToken({
          id: savedUser.id,
          email: savedUser.email,
          purpose: 'email_verification'
        });
        
        // Enviar email com o token
        await emailService.sendVerificationEmail(email, verificationToken);
      } catch (error) {
        console.error('Erro ao enviar email de verificação:', error);
        // Não falhar o registro por causa do email, apenas logar o erro
      }
    }

    // Publicar evento no RabbitMQ
    try {
      await rabbitmqService.publishUserRegistered(savedUser);
    } catch (error) {
      console.error('Erro ao publicar evento de usuário registrado:', error);
      // Não falhar o registro por causa do RabbitMQ
    }

    // Retornar usuário (sem senha) e tokens
    return {
      user: savedUser.toJSON(),
      tokens: {
        accessToken,
        refreshToken
      }
    };
  }

  /**
   * Valida o formato do email
   * @param {string} email - Email a ser validado
   * @returns {boolean} - True se o email for válido
   */
  isValidEmail(email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  }

  /**
   * Valida o formato da senha
   * @param {string} password - Senha a ser validada
   * @returns {boolean} - True se a senha for válida
   */
  isValidPassword(password) {
    // Pelo menos 8 caracteres, incluindo maiúscula, minúscula e número
    const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$/;
    return passwordRegex.test(password);
  }
}

module.exports = RegisterUser; 