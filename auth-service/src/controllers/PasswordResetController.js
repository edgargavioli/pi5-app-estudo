const VerifyResetToken = require('../useCases/VerifyResetToken');

class PasswordResetController {
  constructor(passwordResetRepository) {
    this.verifyResetToken = new VerifyResetToken(passwordResetRepository);
  }

  async verifyToken(req, res) {
    try {
      const { token } = req.params;
      
      const result = await this.verifyResetToken.execute(token);
      
      if (!result.valid) {
        return res.status(400).json({ 
          error: 'Token inválido ou expirado' 
        });
      }

      return res.json({
        valid: true,
        token: result.fullToken
      });
    } catch (error) {
      console.error('Erro ao verificar token:', error);
      return res.status(500).json({ 
        error: 'Erro ao verificar token de redefinição' 
      });
    }
  }

  // ... existing code ...
}

module.exports = PasswordResetController; 