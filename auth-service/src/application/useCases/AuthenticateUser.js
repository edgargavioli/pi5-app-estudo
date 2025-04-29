const bcrypt = require('bcrypt');
const jwtService = require('../../infrastructure/jwt/jwtService');

/**
 * Caso de uso para autenticar um usuário
 */
class AuthenticateUser {
  /**
   * @param {UserRepository} userRepository - Repositório de usuários
   */
  constructor(userRepository) {
    this.userRepository = userRepository;
    this.maxLoginAttempts = parseInt(process.env.MAX_LOGIN_ATTEMPTS) || 5;
    this.lockTimeMinutes = this.parseTimeToMinutes(process.env.ACCOUNT_LOCK_TIME || '30m');
  }

  /**
   * Executa o caso de uso para autenticar um usuário
   * @param {string} email - Email do usuário
   * @param {string} password - Senha do usuário
   * @returns {Promise<Object>} - Objeto com usuário e tokens
   */
  async execute(email, password) {
    // Buscar usuário pelo email
    const user = await this.userRepository.findByEmail(email);
    if (!user) {
      throw new Error('Credenciais inválidas');
    }

    // Verificar se a conta está bloqueada
    if (user.isLocked()) {
      const lockTimeRemaining = this.getRemainingLockTime(user.lockedUntil);
      throw new Error(`Conta bloqueada temporariamente. Tente novamente em ${lockTimeRemaining} minutos.`);
    }

    // Verificar se a conta está no status de bloqueio permanente
    if (user.status === 'blocked') {
      throw new Error('Conta bloqueada. Entre em contato com o suporte.');
    }

    // Verificar a senha
    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      // Incrementar contador de tentativas de login
      user.incrementLoginAttempts();

      // Verificar se atingiu o limite de tentativas
      if (user.loginAttempts >= this.maxLoginAttempts) {
        user.lock(this.lockTimeMinutes);
      }

      // Atualizar usuário no banco de dados
      await this.userRepository.update(user);

      // Informar ao usuário quantas tentativas restam antes do bloqueio
      const attemptsLeft = this.maxLoginAttempts - user.loginAttempts;
      if (attemptsLeft > 0) {
        throw new Error(`Credenciais inválidas. Restam ${attemptsLeft} tentativas antes do bloqueio da conta.`);
      } else {
        throw new Error('Conta bloqueada temporariamente devido a múltiplas tentativas de login.');
      }
    }

    // Verificar se o email está verificado (se necessário)
    if (process.env.EMAIL_VERIFICATION_ENABLED === 'true' && !user.isVerified()) {
      throw new Error('Email não verificado. Por favor, verifique seu email antes de fazer login.');
    }

    // Resetar contador de tentativas em caso de login bem-sucedido
    if (user.loginAttempts > 0) {
      user.resetLoginAttempts();
      await this.userRepository.update(user);
    }

    // Gerar tokens JWT
    const accessToken = jwtService.generateAccessToken({
      id: user.id,
      email: user.email
    });

    const refreshToken = jwtService.generateRefreshToken({
      id: user.id,
      email: user.email
    });

    // Retornar usuário (sem senha) e tokens
    return {
      user: user.toJSON(),
      tokens: {
        accessToken,
        refreshToken
      }
    };
  }

  /**
   * Calcula o tempo restante de bloqueio em minutos
   * @param {Date} lockedUntil - Data até quando a conta está bloqueada
   * @returns {number} - Minutos restantes
   */
  getRemainingLockTime(lockedUntil) {
    const now = new Date();
    const locked = new Date(lockedUntil);
    const diffMs = locked - now;
    return Math.ceil(diffMs / (60 * 1000)); // Converter para minutos e arredondar para cima
  }

  /**
   * Converte string de tempo (ex: '30m', '2h') para minutos
   * @param {string} timeString - String de tempo
   * @returns {number} - Tempo em minutos
   */
  parseTimeToMinutes(timeString) {
    const match = timeString.match(/^(\d+)([mhd])$/);
    if (!match) return 30; // Padrão: 30 minutos

    const value = parseInt(match[1]);
    const unit = match[2];

    switch (unit) {
      case 'm': return value; // minutos
      case 'h': return value * 60; // horas para minutos
      case 'd': return value * 24 * 60; // dias para minutos
      default: return 30;
    }
  }
}

module.exports = AuthenticateUser; 