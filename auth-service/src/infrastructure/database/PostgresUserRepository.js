const { v4: uuidv4 } = require('uuid');
const { query } = require('../../config/database');
const User = require('../../domain/entities/User');
const UserRepository = require('../../domain/repositories/UserRepository');

/**
 * Implementação do UserRepository para PostgreSQL
 */
class PostgresUserRepository extends UserRepository {
  /**
   * Salva um novo usuário no banco de dados
   * @param {User} user - O usuário a ser salvo
   * @returns {Promise<User>} - O usuário salvo com ID gerado
   */
  async save(user) {
    // Gerar um ID UUID se não existir
    const userId = user.id || uuidv4();
    
    const result = await query(
      `INSERT INTO users 
       (id, email, password, name, status, login_attempts, locked_until, created_at, updated_at) 
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9) 
       RETURNING *`,
      [
        userId,
        user.email, 
        user.password,
        user.name,
        user.status,
        user.loginAttempts,
        user.lockedUntil,
        user.createdAt,
        user.updatedAt
      ]
    );
    
    const savedUser = result.rows[0];
    return this.mapToUser(savedUser);
  }

  /**
   * Busca um usuário pelo ID
   * @param {string} id - O ID do usuário
   * @returns {Promise<User|null>} - O usuário encontrado ou null
   */
  async findById(id) {
    const result = await query('SELECT * FROM users WHERE id = $1', [id]);
    
    if (result.rows.length === 0) {
      return null;
    }
    
    return this.mapToUser(result.rows[0]);
  }

  /**
   * Busca um usuário pelo email
   * @param {string} email - O email do usuário
   * @returns {Promise<User|null>} - O usuário encontrado ou null
   */
  async findByEmail(email) {
    const result = await query('SELECT * FROM users WHERE email = $1', [email]);
    
    if (result.rows.length === 0) {
      return null;
    }
    
    return this.mapToUser(result.rows[0]);
  }

  /**
   * Atualiza um usuário existente no banco de dados
   * @param {User} user - O usuário a ser atualizado
   * @returns {Promise<User>} - O usuário atualizado
   */
  async update(user) {
    // Atualizar a data de atualização
    user.updatedAt = new Date();
    
    const result = await query(
      `UPDATE users 
       SET email = $1, 
           password = $2,
           name = $3, 
           status = $4, 
           login_attempts = $5, 
           locked_until = $6, 
           updated_at = $7 
       WHERE id = $8 
       RETURNING *`,
      [
        user.email,
        user.password,
        user.name,
        user.status,
        user.loginAttempts,
        user.lockedUntil,
        user.updatedAt,
        user.id
      ]
    );
    
    if (result.rows.length === 0) {
      throw new Error(`Usuário com ID ${user.id} não encontrado`);
    }
    
    return this.mapToUser(result.rows[0]);
  }

  /**
   * Exclui um usuário do banco de dados
   * @param {string} id - O ID do usuário a ser excluído
   * @returns {Promise<boolean>} - True se o usuário foi excluído
   */
  async delete(id) {
    const result = await query('DELETE FROM users WHERE id = $1 RETURNING id', [id]);
    return result.rows.length > 0;
  }

  /**
   * Mapeia um objeto do banco de dados para a entidade User
   * @param {Object} dbUser - Objeto do banco de dados
   * @returns {User} - Entidade User
   */
  mapToUser(dbUser) {
    return new User(
      dbUser.id,
      dbUser.email,
      dbUser.password,
      dbUser.name,
      dbUser.status,
      dbUser.login_attempts,
      dbUser.locked_until,
      dbUser.created_at,
      dbUser.updated_at
    );
  }
}

module.exports = PostgresUserRepository; 