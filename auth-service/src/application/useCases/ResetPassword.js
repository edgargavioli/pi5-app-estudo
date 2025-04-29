const bcrypt = require('bcrypt');
const emailService = require('../../infrastructure/email/emailService');
const rabbitmqService = require('../../infrastructure/rabbitmq/rabbitmqService');

/**
 * Caso de uso para resetar a senha usando um token de recuperação
 */
class ResetPassword {
  /**
   * @param {UserRepository} userRepository - Repositório de usuários
   * @param {PasswordResetRepository} passwordResetRepository - Repositório de tokens de recuperação de senha
   */
  constructor(userRepository, passwordResetRepository) {
    this.userRepository = userRepository;
    this.passwordResetRepository = passwordResetRepository;
  }

  /**
   * Executa o caso de uso para resetar a senha
   * @param {string} token - Token de recuperação
   * @param {string} newPassword - Nova senha
   * @returns {Promise<boolean>} - True se a senha foi alterada com sucesso
   */
  async execute(token, newPassword) {
    // Buscar token no banco de dados
    const resetData = await this.passwordResetRepository.findByToken(token);
    if (!resetData) {
      throw new Error('Token inválido ou expirado');
    }

    // Buscar usuário
    const user = await this.userRepository.findById(resetData.user_id);
    if (!user) {
      throw new Error('Usuário não encontrado');
    }

    // Validar formato da senha
    if (!this.isValidPassword(newPassword)) {
      throw new Error('A senha deve ter pelo menos 8 caracteres, incluindo letras maiúsculas, minúsculas e números');
    }

    // Criptografar a nova senha
    const salt = parseInt(process.env.PASSWORD_SALT_ROUNDS) || 10;
    const hashedPassword = await bcrypt.hash(newPassword, salt);

    // Atualizar senha do usuário
    user.password = hashedPassword;
    
    // Resetar tentativas de login e qualquer bloqueio temporário
    user.resetLoginAttempts();
    
    // Atualizar data de atualização
    user.updatedAt = new Date();

    // Salvar usuário
    await this.userRepository.update(user);

    // Invalidar o token usado
    await this.passwordResetRepository.invalidate(token);

    // Invalidar todos os tokens de refresh existentes para o usuário
    // Isso seria feito em um sistema de logout completo

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

    return true;
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

module.exports = ResetPassword; 