async handle(req, res) {
  try {
    const { token } = req.params;

    if (!token) {
      return res.status(400).json({ error: 'Token é obrigatório' });
    }

    const result = await this.verifyResetToken.execute(token);
    
    if (!result.valid) {
      return res.status(400).json({ error: 'Token inválido ou expirado' });
    }

    return res.status(200).json({ 
      message: 'Token válido',
      fullToken: result.fullToken 
    });
  } catch (error) {
    console.error('Erro ao verificar token:', error);
    return res.status(500).json({ error: 'Erro interno do servidor' });
  }
} 