/**
 * User Domain Entity
 * Contains business logic and domain rules for User
 */
class User {
  constructor({ id = null, email, password, name, points = 0, isEmailVerified = false, lastLogin = null, createdAt = null, updatedAt = null, imageBase64 = null }) {
    this.id = id;
    this.email = email;
    this.password = password;
    this.name = name;
    this.points = points;
    this.isEmailVerified = isEmailVerified;
    this.lastLogin = lastLogin;
    this.createdAt = createdAt;
    this.updatedAt = updatedAt;
    this.imageBase64 = imageBase64;

    this.validate();
  }

  /**
   * Domain validation rules
   */
  validate() {
    if (!this.email || !this.isValidEmail(this.email)) {
      throw new Error('Invalid email format');
    }

    if (!this.name || this.name.trim().length < 2) {
      throw new Error('Name must be at least 2 characters long');
    }

    if (this.points < 0) {
      throw new Error('Points cannot be negative');
    }
  }

  /**
   * Domain business logic
   */
  isValidEmail(email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  }

  /**
   * Check if user can perform certain actions
   */
  canUpdateProfile() {
    return this.isEmailVerified;
  }

  /**
   * Domain method to verify email
   */
  verifyEmail() {
    this.isEmailVerified = true;
    this.updatedAt = new Date();
  }

  /**
   * Domain method to update last login
   */
  updateLastLogin() {
    this.lastLogin = new Date();
    this.updatedAt = new Date();
  }

  /**
   * Convert to JSON (excluding sensitive data)
   */
  toJSON() {
    return {
      id: this.id,
      email: this.email,
      name: this.name,
      points: this.points,
      isEmailVerified: this.isEmailVerified,
      lastLogin: this.lastLogin,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt,
      imageBase64: this.imageBase64
    };
  }

  /**
   * Convert to public JSON (for API responses)
   */
  toPublicJSON() {
    return {
      id: this.id,
      email: this.email,
      name: this.name,
      points: this.points,
      isEmailVerified: this.isEmailVerified,
      lastLogin: this.lastLogin,
      imageBase64: this.imageBase64
    };
  }
}

module.exports = User; 