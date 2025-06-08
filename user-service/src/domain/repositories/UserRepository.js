/**
 * User Repository Interface
 * Defines the contract for user data persistence
 */
class UserRepository {
  /**
   * Find user by ID
   * @param {string} id - User ID
   * @returns {Promise<User|null>} User entity or null
   */
  async findById(id) {
    throw new Error('Method must be implemented');
  }

  /**
   * Find user by email
   * @param {string} email - User email
   * @returns {Promise<User|null>} User entity or null
   */
  async findByEmail(email) {
    throw new Error('Method must be implemented');
  }

  /**
   * Save user
   * @param {User} user - User entity
   * @returns {Promise<User>} Saved user entity
   */
  async save(user) {
    throw new Error('Method must be implemented');
  }

  /**
   * Update user
   * @param {User} user - User entity
   * @returns {Promise<User>} Updated user entity
   */
  async update(user) {
    throw new Error('Method must be implemented');
  }

  /**
   * Delete user
   * @param {string} id - User ID
   * @returns {Promise<void>}
   */
  async delete(id) {
    throw new Error('Method must be implemented');
  }

  /**
   * Check if email exists
   * @param {string} email - Email to check
   * @param {string} excludeId - ID to exclude from check
   * @returns {Promise<boolean>} True if email exists
   */
  async emailExists(email, excludeId = null) {
    throw new Error('Method must be implemented');
  }

  /**
   * Update user profile image
   * @param {string} id - User ID
   * @param {string} imageBase64 - Base64 image data
   * @returns {Promise<void>}
   */
  async updateProfileImage(id, imageBase64) {
    throw new Error('Method must be implemented');
  }

  /**
   * Get user profile image
   * @param {string} id - User ID
   * @returns {Promise<string|null>} Base64 image data or null
   */
  async getProfileImage(id) {
    throw new Error('Method must be implemented');
  }
}

module.exports = UserRepository; 