const { PrismaClient } = require('@prisma/client');
const { AppError } = require('../../middleware/errorHandler');

const prisma = new PrismaClient();

/**
 * Prisma implementation of UserRepository
 * Infrastructure layer - handles data persistence
 */
class PrismaUserRepository {
  /**
   * Find user by ID
   */
  async findById(id) {
    try {
      const user = await prisma.user.findUnique({
        where: { id }
      });

      if (!user) {
        return null;
      }

      return {
        ...user,
        toPublicJSON() {
          const { password, ...publicData } = this;
          return publicData;
        }
      };
    } catch (error) {
      throw new AppError('Error finding user', 500);
    }
  }

  /**
   * Find user by email
   */
  async findByEmail(email) {
    try {
      const user = await prisma.user.findUnique({
        where: { email }
      });

      if (!user) {
        return null;
      }

      return {
        ...user,
        toPublicJSON() {
          const { password, ...publicData } = this;
          return publicData;
        }
      };
    } catch (error) {
      throw new AppError('Error finding user', 500);
    }
  }

  /**
   * Update user
   */
  async update(id, data) {
    try {
      const user = await prisma.user.update({
        where: { id },
        data
      });

      return {
        ...user,
        toPublicJSON() {
          const { password, ...publicData } = this;
          return publicData;
        }
      };
    } catch (error) {
      throw new AppError('Error updating user', 500);
    }
  }

  /**
   * Delete user
   */
  async delete(id) {
    try {
      await prisma.user.delete({
        where: { id }
      });
    } catch (error) {
      throw new AppError('Error deleting user', 500);
    }
  }

  /**
   * Update profile image
   */
  async updateProfileImage(id, imageBase64) {
    try {
      const user = await prisma.user.update({
        where: { id },
        data: { imageBase64 }
      });

      return {
        ...user,
        toPublicJSON() {
          const { password, ...publicData } = this;
          return publicData;
        }
      };
    } catch (error) {
      throw new AppError('Error updating profile image', 500);
    }
  }

  /**
   * Get profile image
   */
  async getProfileImage(id) {
    try {
      const user = await prisma.user.findUnique({
        where: { id },
        select: { imageBase64: true }
      });

      return user?.imageBase64 || null;
    } catch (error) {
      throw new AppError('Error getting profile image', 500);
    }
  }
}

module.exports = PrismaUserRepository; 