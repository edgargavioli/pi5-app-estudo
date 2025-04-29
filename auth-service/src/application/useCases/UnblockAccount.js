const rabbitmqService = require('../../infrastructure/rabbitmq/rabbitmqService');

/**
 * Caso de uso para desbloquear uma conta de usuário
 */
class UnblockAccount {
  /**
   * @param {UserRepository} userRepository - Repositório de usuários
   */
  constructor(userRepository) {
    this.userRepository = userRepository;
  }

  /**
   * Executa o caso de uso para desbloquear uma conta
   * @param {string} userId - ID do usuário
   * @param {string} adminId - ID do administrador que está fazendo o desbloqueio
   * @returns {Promise<boolean>} - True se a conta foi desbloqueada com sucesso
   */
  async execute(userId, adminId) {
    // Buscar usuário
    const user = await this.userRepository.findById(userId);
    if (!user) {
      throw new Error('Usuário não encontrado');
    }

    // Verificar se a conta já está desbloqueada
    if (user.status !== 'blocked' && !user.isLocked()) {
      return true; // Conta já desbloqueada
    }

    // Desbloquear a conta
    user.unblock();

    // Atualizar usuário no banco de dados
    await this.userRepository.update(user);

    // Publicar evento de conta desbloqueada
    try {
      await rabbitmqService.publishAccountUnblocked(userId);
    } catch (error) {
      console.error('Erro ao publicar evento de conta desbloqueada:', error);
      // Não falhar o processo por causa do RabbitMQ
    }

    // Aqui poderia ter uma lógica para registrar o log de auditoria
    // informando qual administrador desbloqueou a conta

    return true;
  }
}

module.exports = UnblockAccount; 