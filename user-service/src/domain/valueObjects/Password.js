const bcrypt = require('bcrypt');
const { AppError } = require('../../middleware/errorHandler');

/**
 * Password Value Object
 * Encapsulates password validation and hashing behavior
 */
class Password {
  static requirements = {
    minLength: 8,
    requireUppercase: true,
    requireLowercase: true,
    requireNumbers: true,
    requireSpecialChars: true
  };
  constructor(value, isHashed = false) {
    if (!value) {
      throw new AppError(
        'Password is required',
        400,
        {
          field: 'password',
          type: 'required_field_missing'
        }
      ).withSuggestions(['Please provide a password']);
    }

    this.value = value;
    this.isHashed = isHashed;

    if (!isHashed) {
      this.validate();
    }
  }

  validate() {
    const errors = [];
    const { requirements } = Password;

    if (this.value.length < requirements.minLength) {
      errors.push(`Password must be at least ${requirements.minLength} characters long`);
    }

    if (requirements.requireUppercase && !/[A-Z]/.test(this.value)) {
      errors.push('Password must contain at least one uppercase letter');
    }

    if (requirements.requireLowercase && !/[a-z]/.test(this.value)) {
      errors.push('Password must contain at least one lowercase letter');
    } if (requirements.requireNumbers && !/\d/.test(this.value)) {
      errors.push('Password must contain at least one number');
    }

    if (requirements.requireSpecialChars && !/[!@#$%^&*(),.?":{}|<>]/.test(this.value)) {
      errors.push('Password must contain at least one special character (!@#$%^&*(),.?":{}|<>)');
    } if (errors.length > 0) {
      throw new AppError(
        'Password does not meet security requirements',
        400,
        {
          field: 'password',
          type: 'validation_failed',
          errors: errors,
          requirements: Password.requirements,
          allowedSpecialChars: '!@#$%^&*(),.?":{}|<>'
        }
      ).withContext({
        passwordLength: this.value.length,
        hasUppercase: /[A-Z]/.test(this.value),
        hasLowercase: /[a-z]/.test(this.value),
        hasNumbers: /\d/.test(this.value),
        hasSpecialChars: /[!@#$%^&*(),.?":{}|<>]/.test(this.value)
      }).withSuggestions([
        'Use at least 8 characters',
        'Include both uppercase (A-Z) and lowercase (a-z) letters',
        'Add at least one number (0-9)',
        'Include at least one special character: !@#$%^&*(),.?":{}|<>',
        'Example: MyPassword123!'
      ]);
    }
  }

  async hash() {
    if (this.isHashed) {
      return this.value;
    }

    const saltRounds = 10;
    this.value = await bcrypt.hash(this.value, saltRounds);
    this.isHashed = true;
    return this.value;
  }

  async compare(plainPassword) {
    if (!this.isHashed) {
      throw new Error('Cannot compare with unhashed password');
    }

    return await bcrypt.compare(plainPassword, this.value);
  }

  toString() {
    return this.value;
  }

  static fromHash(hashedValue) {
    return new Password(hashedValue, true);
  }
}

module.exports = Password; 