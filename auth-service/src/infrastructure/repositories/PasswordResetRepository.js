  async findByPartialToken(partialToken) {
    const query = `
      SELECT * FROM password_resets 
      WHERE token LIKE $1 
      AND expires_at > NOW() 
      AND used = false
      ORDER BY created_at DESC
      LIMIT 1
    `;
    const values = [`${partialToken}%`];
    
    const result = await this.db.query(query, values);
    return result.rows[0];
  } 