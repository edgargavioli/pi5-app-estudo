class VerifyResetToken {
  constructor(passwordResetRepository) {
    this.passwordResetRepository = passwordResetRepository;
  }

  async execute(partialToken) {
    try {
      const resetRecord = await this.passwordResetRepository.findByPartialToken(partialToken);
      
      if (!resetRecord) {
        return { isValid: false };
      }

      return {
        isValid: true,
        fullToken: resetRecord.token
      };
    } catch (error) {
      console.error('Erro ao verificar token:', error);
      throw error;
    }
  }
}

module.exports = VerifyResetToken; 