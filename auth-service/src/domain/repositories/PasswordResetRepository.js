/**
 * Interface para o repositório de tokens de recuperação de senha
 */
class PasswordResetRepository {
  /**
   * Cria um novo token de recuperação de senha
   * @param {string} userId - O ID do usuário
   * @param {string} token - O token gerado
   * @param {Date} expiresAt - Data de expiração do token
   * @returns {Promise<Object>} - O objeto do token criado
   */
  async create(userId, token, expiresAt) {
    throw new Error('O método create deve ser implementado');
  }

  /**
   * Busca um token de recuperação de senha
   * @param {string} token - O token a ser buscado
   * @returns {Promise<Object|null>} - O objeto do token encontrado ou null
   */
  async findByToken(token) {
    throw new Error('O método findByToken deve ser implementado');
  }

  /**
   * Invalida um token após seu uso
   * @param {string} token - O token a ser invalidado
   * @returns {Promise<boolean>} - True se o token foi invalidado
   */
  async invalidate(token) {
    throw new Error('O método invalidate deve ser implementado');
  }

  /**
   * Remove tokens expirados do banco de dados
   * @returns {Promise<number>} - Número de tokens removidos
   */
  async removeExpired() {
    throw new Error('O método removeExpired deve ser implementado');
  }

  /**
   * Invalida todos os tokens de um usuário
   * @param {string} userId - O ID do usuário
   * @returns {Promise<number>} - Número de tokens invalidados
   */
  async invalidateAllForUser(userId) {
    throw new Error('O método invalidateAllForUser deve ser implementado');
  }
}

module.exports = PasswordResetRepository; 