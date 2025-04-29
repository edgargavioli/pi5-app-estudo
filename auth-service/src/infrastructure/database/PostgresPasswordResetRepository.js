const { query } = require('../../config/database');
const PasswordResetRepository = require('../../domain/repositories/PasswordResetRepository');

/**
 * Implementação do PasswordResetRepository para PostgreSQL
 */
class PostgresPasswordResetRepository extends PasswordResetRepository {
  /**
   * Cria um novo token de recuperação de senha
   * @param {string} userId - O ID do usuário
   * @param {string} token - O token gerado
   * @param {Date} expiresAt - Data de expiração do token
   * @returns {Promise<Object>} - O objeto do token criado
   */
  async create(userId, token, expiresAt) {
    const result = await query(
      `INSERT INTO password_resets (user_id, token, expires_at, used)
       VALUES ($1, $2, $3, false)
       RETURNING *`,
      [userId, token, expiresAt]
    );

    return result.rows[0];
  }

  /**
   * Busca um token de recuperação de senha
   * @param {string} token - O token a ser buscado
   * @returns {Promise<Object|null>} - O objeto do token encontrado ou null
   */
  async findByToken(token) {
    const result = await query(
      `SELECT * FROM password_resets
       WHERE token LIKE $1 AND used = false AND expires_at > NOW()
       ORDER BY created_at DESC
       LIMIT 1`,
      [`${token}%`]
    );

    if (result.rows.length === 0) {
      return null;
    }

    return result.rows[0];
  }

  /**
   * Busca um token de recuperação de senha por parte do token
   * @param {string} partialToken - Parte do token a ser buscado
   * @returns {Promise<Object|null>} - O objeto do token encontrado ou null
   */
  async findByPartialToken(partialToken) {
    const result = await query(
      `SELECT * FROM password_resets
       WHERE token LIKE $1 AND used = false AND expires_at > NOW()
       ORDER BY created_at DESC
       LIMIT 1`,
      [`${partialToken}%`]
    );

    if (result.rows.length === 0) {
      return null;
    }

    return result.rows[0];
  }

  /**
   * Invalida um token após seu uso
   * @param {string} token - O token a ser invalidado
   * @returns {Promise<boolean>} - True se o token foi invalidado
   */
  async invalidate(token) {
    const result = await query(
      `UPDATE password_resets
       SET used = true
       WHERE token = $1 AND used = false`,
      [token]
    );

    return result.rowCount > 0;
  }

  /**
   * Remove tokens expirados do banco de dados
   * @returns {Promise<number>} - Número de tokens removidos
   */
  async removeExpired() {
    const result = await query(
      `DELETE FROM password_resets
       WHERE expires_at < NOW()
       RETURNING id`
    );

    return result.rowCount;
  }

  /**
   * Invalida todos os tokens de um usuário
   * @param {string} userId - O ID do usuário
   * @returns {Promise<number>} - Número de tokens invalidados
   */
  async invalidateAllForUser(userId) {
    const result = await query(
      `UPDATE password_resets
       SET used = true
       WHERE user_id = $1 AND used = false
       RETURNING id`,
      [userId]
    );

    return result.rowCount;
  }
}

module.exports = PostgresPasswordResetRepository; 