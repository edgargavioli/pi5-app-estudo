const bcrypt = require('bcrypt');
const emailService = require('../../infrastructure/email/emailService');
const rabbitmqService = require('../../infrastructure/rabbitmq/rabbitmqService');
const jwtService = require('../../infrastructure/jwt/jwtService');

/**
 * Caso de uso para alterar a senha do usuário autenticado
 */
class ChangePassword {
  /**
   * @param {UserRepository} userRepository - Repositório de usuários
   */
  constructor(userRepository) {
    this.userRepository = userRepository;
  }

  /**
   * Executa o caso de uso para alterar a senha
   * @param {string} userId - ID do usuário
   * @param {string} currentPassword - Senha atual
   * @param {string} newPassword - Nova senha
   * @returns {Promise<Object>} - Objeto com novo token de acesso
   */
  async execute(userId, currentPassword, newPassword) {
    // Buscar usuário
    const user = await this.userRepository.findById(userId);
    if (!user) {
      throw new Error('Usuário não encontrado');
    }

    // Verificar senha atual
    const isPasswordValid = await bcrypt.compare(currentPassword, user.password);
    if (!isPasswordValid) {
      throw new Error('Senha atual incorreta');
    }

    // Validar formato da nova senha
    if (!this.isValidPassword(newPassword)) {
      throw new Error('A nova senha deve ter pelo menos 8 caracteres, incluindo letras maiúsculas, minúsculas e números');
    }

    // Verificar se a nova senha é diferente da atual
    if (currentPassword === newPassword) {
      throw new Error('A nova senha deve ser diferente da senha atual');
    }

    // Criptografar a nova senha
    const salt = parseInt(process.env.PASSWORD_SALT_ROUNDS) || 10;
    const hashedPassword = await bcrypt.hash(newPassword, salt);

    // Atualizar senha do usuário
    user.password = hashedPassword;
    user.updatedAt = new Date();

    // Salvar usuário
    await this.userRepository.update(user);

    // Gerar novo token de acesso
    const accessToken = jwtService.generateAccessToken({
      id: user.id,
      email: user.email
    });

    // Enviar notificação por email
    try {
      await emailService.sendPasswordChangeNotification(user.email);
    } catch (error) {
      console.error('Erro ao enviar notificação de alteração de senha:', error);
      // Não falhar o processo por causa do email
    }

    // Publicar evento de alteração de senha
    try {
      await rabbitmqService.publishPasswordChanged(user.id);
    } catch (error) {
      console.error('Erro ao publicar evento de alteração de senha:', error);
      // Não falhar o processo por causa do RabbitMQ
    }

    return {
      accessToken
    };
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

module.exports = ChangePassword; 