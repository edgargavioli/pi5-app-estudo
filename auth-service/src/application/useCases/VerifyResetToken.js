/**
 * Caso de uso para verificar se um token de redefinição de senha é válido
 */
class VerifyResetToken {
  /**
   * @param {UserRepository} userRepository - Repositório de usuários
   * @param {PasswordResetRepository} passwordResetRepository - Repositório de tokens de recuperação de senha
   */
  constructor(userRepository, passwordResetRepository) {
    this.userRepository = userRepository;
    this.passwordResetRepository = passwordResetRepository;
  }

  /**
   * Executa o caso de uso para verificar um token de redefinição de senha
   * @param {string} token - Token de recuperação a ser verificado
   * @returns {Promise<Object>} - Informações sobre o token (válido e userId)
   */
  async execute(token) {
    if (!token) {
      throw new Error('Token é obrigatório');
    }

    // Buscar todos os tokens ativos do usuário
    const resetData = await this.passwordResetRepository.findByPartialToken(token);
    if (!resetData) {
      return {
        valid: false,
        userId: null
      };
    }

    // Buscar usuário para garantir que ele existe
    const user = await this.userRepository.findById(resetData.user_id);
    if (!user) {
      return {
        valid: false,
        userId: null
      };
    }

    // Token e usuário são válidos
    return {
      valid: true,
      userId: user.id,
      fullToken: resetData.token // Retornar o token completo para uso posterior
    };
  }
}

module.exports = VerifyResetToken; 