const { PrismaClient } = require('@prisma/client');
const UserRepository = require('../../domain/repositories/UserRepository');
const User = require('../../domain/entities/User');
const { AppError } = require('../../middleware/errorHandler');

const prisma = new PrismaClient();

/**
 * Prisma implementation of UserRepository
 * Infrastructure layer - handles data persistence
 */
class PrismaUserRepository extends UserRepository {
  /**
   * Convert Prisma user data to User entity
   */
  toDomainEntity(userData) {
    if (!userData) return null;
    
    return new User({
      id: userData.id,
      email: userData.email,
      password: userData.password,
      name: userData.name,
      points: userData.points,
      isEmailVerified: userData.isEmailVerified,
      lastLogin: userData.lastLogin,
      createdAt: userData.createdAt,
      updatedAt: userData.updatedAt,
      imageBase64: userData.imageBase64
    });
  }

  /**
   * Convert User entity to Prisma data format
   */
  toPersistenceData(user) {
    return {
      id: user.id,
      email: user.email,
      password: user.password,
      name: user.name,
      points: user.points,
      isEmailVerified: user.isEmailVerified,
      lastLogin: user.lastLogin,
      imageBase64: user.imageBase64
    };
  }

  async findById(id) {
    try {
      const userData = await prisma.user.findUnique({
        where: { id }
      });
      
      return this.toDomainEntity(userData);
    } catch (error) {
      throw new AppError(`Error finding user by ID: ${error.message}`, 500);
    }
  }

  async findByEmail(email) {
    try {
      const userData = await prisma.user.findUnique({
        where: { email }
      });
      
      return this.toDomainEntity(userData);
    } catch (error) {
      throw new AppError(`Error finding user by email: ${error.message}`, 500);
    }
  }

  async save(user) {
    try {
      const userData = this.toPersistenceData(user);
      const savedUser = await prisma.user.create({
        data: userData
      });
      
      return this.toDomainEntity(savedUser);
    } catch (error) {
      if (error.code === 'P2002') {
        throw new AppError('Email already exists', 400);
      }
      throw new AppError(`Error saving user: ${error.message}`, 500);
    }
  }

  async update(user) {
    try {
      const userData = this.toPersistenceData(user);
      const updatedUser = await prisma.user.update({
        where: { id: user.id },
        data: userData
      });
      
      return this.toDomainEntity(updatedUser);
    } catch (error) {
      if (error.code === 'P2002') {
        throw new AppError('Email already exists', 400);
      }
      if (error.code === 'P2025') {
        throw new AppError('User not found', 404);
      }
      throw new AppError(`Error updating user: ${error.message}`, 500);
    }
  }

  async delete(id) {
    try {
      await prisma.user.delete({
        where: { id }
      });
    } catch (error) {
      if (error.code === 'P2025') {
        throw new AppError('User not found', 404);
      }
      throw new AppError(`Error deleting user: ${error.message}`, 500);
    }
  }

  async emailExists(email, excludeId = null) {
    try {
      const whereClause = { email };
      if (excludeId) {
        whereClause.NOT = { id: excludeId };
      }
      
      const user = await prisma.user.findFirst({
        where: whereClause,
        select: { id: true }
      });
      
      return !!user;
    } catch (error) {
      throw new AppError(`Error checking email existence: ${error.message}`, 500);
    }
  }

  async updateProfileImage(id, imageBase64) {
    try {
      await prisma.user.update({
        where: { id },
        data: { imageBase64 }
      });
    } catch (error) {
      if (error.code === 'P2025') {
        throw new AppError('User not found', 404);
      }
      throw new AppError(`Error updating profile image: ${error.message}`, 500);
    }
  }

  async getProfileImage(id) {
    try {
      const user = await prisma.user.findUnique({
        where: { id },
        select: { imageBase64: true }
      });
      
      if (!user) {
        throw new AppError('User not found', 404);
      }
      
      return user.imageBase64;
    } catch (error) {
      if (error instanceof AppError) {
        throw error;
      }
      throw new AppError(`Error getting profile image: ${error.message}`, 500);
    }
  }
}

module.exports = PrismaUserRepository; 