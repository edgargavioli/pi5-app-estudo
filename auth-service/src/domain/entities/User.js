/**
 * Classe que representa a entidade User no domínio
 */
class User {
  constructor(id, email, password, name = '', status = 'pending', loginAttempts = 0, lockedUntil = null, createdAt = new Date(), updatedAt = new Date()) {
    this.id = id;
    this.email = email;
    this.password = password;
    this.name = name;
    this.status = status; // pending, verified, blocked
    this.loginAttempts = loginAttempts;
    this.lockedUntil = lockedUntil;
    this.createdAt = createdAt;
    this.updatedAt = updatedAt;
  }

  /**
   * Verifica se o usuário está com a conta bloqueada
   * @returns {boolean} - True se a conta estiver bloqueada
   */
  isLocked() {
    if (!this.lockedUntil) return false;
    return new Date() < new Date(this.lockedUntil);
  }

  /**
   * Verifica se o email do usuário está verificado
   * @returns {boolean} - True se o email estiver verificado
   */
  isVerified() {
    return this.status === 'verified';
  }

  /**
   * Incrementa o número de tentativas de login
   */
  incrementLoginAttempts() {
    this.loginAttempts += 1;
    this.updatedAt = new Date();
  }

  /**
   * Reseta o número de tentativas de login
   */
  resetLoginAttempts() {
    this.loginAttempts = 0;
    this.lockedUntil = null;
    this.updatedAt = new Date();
  }

  /**
   * Bloqueia a conta do usuário por um determinado período
   * @param {number} minutes - Tempo em minutos que a conta ficará bloqueada
   */
  lock(minutes) {
    const lockTime = new Date();
    lockTime.setMinutes(lockTime.getMinutes() + minutes);
    this.lockedUntil = lockTime;
    this.updatedAt = new Date();
  }

  /**
   * Verifica o email do usuário
   */
  verify() {
    this.status = 'verified';
    this.updatedAt = new Date();
  }

  /**
   * Bloqueia permanentemente a conta do usuário (só pode ser desbloqueada por admin)
   */
  block() {
    this.status = 'blocked';
    this.updatedAt = new Date();
  }

  /**
   * Desbloqueia a conta do usuário
   */
  unblock() {
    this.status = 'verified';
    this.lockedUntil = null;
    this.loginAttempts = 0;
    this.updatedAt = new Date();
  }

  /**
   * Retorna o objeto User sem a senha
   * @returns {Object} - Objeto User sem a senha
   */
  toJSON() {
    const { password, ...userWithoutPassword } = this;
    return userWithoutPassword;
  }
}

module.exports = User; 