const jwtService = require('../../infrastructure/jwt/jwtService');
const rabbitmqService = require('../../infrastructure/rabbitmq/rabbitmqService');

/**
 * Caso de uso para verificar o email do usuário
 */
class VerifyEmail {
  /**
   * @param {UserRepository} userRepository - Repositório de usuários
   */
  constructor(userRepository) {
    this.userRepository = userRepository;
  }

  /**
   * Executa o caso de uso para verificar o email
   * @param {string} token - Token de verificação
   * @returns {Promise<boolean>} - True se o email foi verificado com sucesso
   */
  async execute(token) {
    // Verificar token
    const payload = jwtService.verifyAccessToken(token);
    if (!payload) {
      throw new Error('Token inválido ou expirado');
    }

    // Verificar se o token é para verificação de email
    if (payload.purpose !== 'email_verification') {
      throw new Error('Token inválido para verificação de email');
    }

    // Buscar usuário
    const user = await this.userRepository.findById(payload.id);
    if (!user) {
      throw new Error('Usuário não encontrado');
    }

    // Verificar se o email já foi verificado
    if (user.isVerified()) {
      return true; // Email já verificado
    }

    // Verificar o email
    user.verify();

    // Atualizar usuário no banco de dados
    await this.userRepository.update(user);

    // Publicar evento de email verificado
    try {
      await rabbitmqService.publishEmailVerified(user.id, user.email);
    } catch (error) {
      console.error('Erro ao publicar evento de email verificado:', error);
      // Não falhar o processo por causa do RabbitMQ
    }

    return true;
  }
}

module.exports = VerifyEmail; 