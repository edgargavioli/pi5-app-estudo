const crypto = require('crypto');
const emailService = require('../../infrastructure/email/emailService');

/**
 * Caso de uso para iniciar o processo de recuperação de senha
 */
class RecoverPassword {
  /**
   * @param {UserRepository} userRepository - Repositório de usuários
   * @param {PasswordResetRepository} passwordResetRepository - Repositório de tokens de recuperação de senha
   */
  constructor(userRepository, passwordResetRepository) {
    this.userRepository = userRepository;
    this.passwordResetRepository = passwordResetRepository;
    this.tokenExpiryHours = 1; // Token expira em 1 hora
  }

  /**
   * Executa o caso de uso para iniciar a recuperação de senha
   * @param {string} email - Email do usuário
   * @returns {Promise<boolean>} - True se o processo iniciou com sucesso
   * @throws {Error} - Se o email não for válido ou não estiver registrado
   */
  async execute(email) {
    // Buscar usuário pelo email
    const user = await this.userRepository.findByEmail(email);
    if (!user) {
      // Usamos uma mensagem mais genérica e amigável
      throw new Error('Email inválido ou não registrado');
    }

    // Verificar se a conta está bloqueada
    if (user.status === 'blocked') {
      // Por segurança, não informamos que a conta está bloqueada
      // Mas não enviamos o email de recuperação
      return true;
    }

    // Remover tokens antigos para este usuário
    await this.passwordResetRepository.invalidateAllForUser(user.id);

    // Gerar token de recuperação aleatório
    const resetToken = crypto.randomBytes(32).toString('hex');

    // Definir data de expiração (1 hora a partir de agora)
    const expiresAt = new Date();
    expiresAt.setHours(expiresAt.getHours() + this.tokenExpiryHours);

    // Salvar token no banco de dados
    await this.passwordResetRepository.create(user.id, resetToken, expiresAt);

    // Enviar email com o token
    try {
      await emailService.sendPasswordResetEmail(user.email, resetToken);
    } catch (error) {
      console.error('Erro ao enviar email de recuperação de senha:', error);
      // Não falhar o processo por causa do email, apenas logar o erro
    }

    // Também remover tokens expirados do banco de dados (limpeza)
    try {
      await this.passwordResetRepository.removeExpired();
    } catch (error) {
      console.error('Erro ao remover tokens expirados:', error);
      // Não falhar o processo por causa da limpeza
    }

    return true;
  }
}

module.exports = RecoverPassword; 