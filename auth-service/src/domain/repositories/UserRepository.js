/**
 * Interface para o repositório de usuários
 * Esta classe define os métodos que qualquer implementação de repositório de usuários deve ter
 */
class UserRepository {
  /**
   * Salva um usuário no banco de dados
   * @param {User} user - O usuário a ser salvo
   * @returns {Promise<User>} - O usuário salvo
   */
  async save(user) {
    throw new Error('O método save deve ser implementado');
  }

  /**
   * Busca um usuário pelo ID
   * @param {string} id - O ID do usuário
   * @returns {Promise<User|null>} - O usuário encontrado ou null
   */
  async findById(id) {
    throw new Error('O método findById deve ser implementado');
  }

  /**
   * Busca um usuário pelo email
   * @param {string} email - O email do usuário
   * @returns {Promise<User|null>} - O usuário encontrado ou null
   */
  async findByEmail(email) {
    throw new Error('O método findByEmail deve ser implementado');
  }

  /**
   * Atualiza um usuário no banco de dados
   * @param {User} user - O usuário a ser atualizado
   * @returns {Promise<User>} - O usuário atualizado
   */
  async update(user) {
    throw new Error('O método update deve ser implementado');
  }

  /**
   * Exclui um usuário do banco de dados
   * @param {string} id - O ID do usuário a ser excluído
   * @returns {Promise<boolean>} - True se o usuário foi excluído
   */
  async delete(id) {
    throw new Error('O método delete deve ser implementado');
  }
}

module.exports = UserRepository; 