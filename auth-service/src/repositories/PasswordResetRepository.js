class PasswordResetRepository {
  constructor(db) {
    this.db = db;
  }

  async findByPartialToken(partialToken) {
    try {
      const query = `
        SELECT * FROM password_resets 
        WHERE token LIKE $1 
        AND expires_at > NOW() 
        AND used = false
      `;
      
      const result = await this.db.query(query, [`${partialToken}%`]);
      return result.rows[0] || null;
    } catch (error) {
      console.error('Erro ao buscar token:', error);
      throw error;
    }
  }

  // ... existing code ...
}

module.exports = PasswordResetRepository; 