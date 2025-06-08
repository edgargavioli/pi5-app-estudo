/**
 * Email Value Object
 * Encapsulates email validation and behavior
 */
class Email {
  constructor(value) {
    if (!value) {
      throw new Error('Email is required');
    }
    
    this.value = value.toLowerCase().trim();
    this.validate();
  }

  validate() {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(this.value)) {
      throw new Error('Invalid email format');
    }
  }

  toString() {
    return this.value;
  }

  equals(other) {
    return other instanceof Email && this.value === other.value;
  }

  getDomain() {
    return this.value.split('@')[1];
  }

  getLocalPart() {
    return this.value.split('@')[0];
  }
}

module.exports = Email; 