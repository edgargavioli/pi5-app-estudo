const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

class UserService {
  /**
   * Get all users
   * @returns {Promise<Array>} List of users
   */
  async getAllUsers() {
    try {
      const users = await prisma.user.findMany({
        select: { id: true, username: true, email: true, points: true, lastLogin: true }
      });
      return users;
    } catch (error) {
      throw new Error(error.message);
    }
  }

  /**
   * Get user by ID
   * @param {string} id - User ID
   * @returns {Promise<Object>} User object
   */
  async getUserById(id) {
    try {
      const user = await prisma.user.findUnique({
        where: { id },
        select: { id: true, username: true, email: true, points: true, lastLogin: true }
      });
      
      if (!user) {
        throw new Error('User not found');
      }
      
      return user;
    } catch (error) {
      throw new Error(error.message);
    }
  }

  /**
   * Update user
   * @param {string} id - User ID
   * @param {Object} userData - User data to update
   * @returns {Promise<Object>} Updated user object
   */
  async updateUser(id, userData) {
    try {
      const user = await prisma.user.update({
        where: { id },
        data: userData,
        select: { id: true, username: true, email: true, points: true, lastLogin: true }
      });
      
      return user;
    } catch (error) {
      throw new Error(error.message);
    }
  }

  /**
   * Delete user
   * @param {string} id - User ID
   * @returns {Promise<boolean>} Success status
   */
  async deleteUser(id) {
    try {
      await prisma.user.delete({ where: { id } });
      return true;
    } catch (error) {
      throw new Error(error.message);
    }
  }
}

module.exports = new UserService(); 