const rabbitmqService = require('../../infrastructure/rabbitmq/rabbitmqService');

/**
 * Caso de uso para bloquear uma conta de usuário
 */
class BlockAccount {
  /**
   * @param {UserRepository} userRepository - Repositório de usuários
   */
  constructor(userRepository) {
    this.userRepository = userRepository;
  }

  /**
   * Executa o caso de uso para bloquear uma conta
   * @param {string} userId - ID do usuário
   * @param {string} reason - Motivo do bloqueio
   * @param {string} adminId - ID do administrador que está fazendo o bloqueio
   * @returns {Promise<boolean>} - True se a conta foi bloqueada com sucesso
   */
  async execute(userId, reason, adminId) {
    // Buscar usuário
    const user = await this.userRepository.findById(userId);
    if (!user) {
      throw new Error('Usuário não encontrado');
    }

    // Verificar se a conta já está bloqueada
    if (user.status === 'blocked') {
      return true; // Conta já bloqueada
    }

    // Bloquear a conta
    user.block();

    // Atualizar usuário no banco de dados
    await this.userRepository.update(user);

    // Publicar evento de conta bloqueada
    try {
      await rabbitmqService.publishAccountBlocked(userId, reason);
    } catch (error) {
      console.error('Erro ao publicar evento de conta bloqueada:', error);
      // Não falhar o processo por causa do RabbitMQ
    }

    // Aqui poderia ter uma lógica para registrar o log de auditoria
    // informando qual administrador bloqueou a conta e por qual motivo

    return true;
  }
}

module.exports = BlockAccount; 