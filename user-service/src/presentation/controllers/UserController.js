const GetUserUseCase = require('../../application/useCases/GetUserUseCase');
const UpdateUserUseCase = require('../../application/useCases/UpdateUserUseCase');
const PrismaUserRepository = require('../../infrastructure/repositories/PrismaUserRepository');
const { AppError } = require('../../middleware/errorHandler');

/**
 * User Controller - Presentation Layer
 * Handles HTTP requests and responses with HATEOAS
 */
class UserController {
  constructor() {
    this.userRepository = new PrismaUserRepository();
    this.getUserUseCase = new GetUserUseCase(this.userRepository);
    this.updateUserUseCase = new UpdateUserUseCase(this.userRepository);

    // Bind methods to preserve 'this' context
    this.getUser = this.getUser.bind(this);
    this.updateUser = this.updateUser.bind(this);
    this.deleteUser = this.deleteUser.bind(this);
    this.updateProfileImage = this.updateProfileImage.bind(this);
    this.getProfileImage = this.getProfileImage.bind(this);
    this.generateHateoasLinks = this.generateHateoasLinks.bind(this);
    this.isValidBase64Image = this.isValidBase64Image.bind(this);
  }

  /**
   * Get user by ID
   */
  async getUser(req, res) {
    try {
      const userId = req.params.id;
      const requestingUserId = req.user.id;

      const user = await this.getUserUseCase.execute(userId, requestingUserId);
      
      // Add HATEOAS links
      const response = {
        data: user,
        _links: this.generateHateoasLinks(req, user.id)
      };

      res.json(response);
    } catch (error) {
      throw error;
    }
  }

  /**
   * Update user
   */
  async updateUser(req, res) {
    try {
      const userId = req.params.id;
      const requestingUserId = req.user.id;
      const updateData = req.body;

      const user = await this.updateUserUseCase.execute(userId, updateData, requestingUserId);
      
      // Add HATEOAS links
      const response = {
        data: user,
        message: 'User updated successfully',
        _links: this.generateHateoasLinks(req, user.id)
      };

      res.json(response);
    } catch (error) {
      throw error;
    }
  }

  /**
   * Delete user
   */
  async deleteUser(req, res) {
    try {
      const userId = req.params.id;
      const requestingUserId = req.user.id;

      // Authorization check
      if (userId !== requestingUserId) {
        throw new AppError('Unauthorized: You can only delete your own account', 403);
      }

      await this.userRepository.delete(userId);

      res.json({
        message: 'User deleted successfully',
        _links: {
          register: {
            href: `${req.protocol}://${req.get('host')}/api/auth/register`,
            method: 'POST'
          }
        }
      });
    } catch (error) {
      throw error;
    }
  }

  /**
   * Update profile image
   */
  async updateProfileImage(req, res) {
    try {
      const userId = req.params.id;
      const requestingUserId = req.user.id;
      const { imageBase64 } = req.body;

      // Authorization check
      if (userId !== requestingUserId) {
        throw new AppError('Unauthorized: You can only update your own profile image', 403);
      }

      // Validate base64 format
      if (!imageBase64 || !this.isValidBase64Image(imageBase64)) {
        throw new AppError('Invalid image format. Please provide a valid base64 encoded image.', 400);
      }

      await this.userRepository.updateProfileImage(userId, imageBase64);

      const response = {
        message: 'Profile image updated successfully',
        _links: this.generateHateoasLinks(req, userId)
      };

      res.json(response);
    } catch (error) {
      throw error;
    }
  }

  /**
   * Get profile image
   */
  async getProfileImage(req, res) {
    try {
      const userId = req.params.id;
      const requestingUserId = req.user.id;

      // Authorization check
      if (userId !== requestingUserId) {
        throw new AppError('Unauthorized: You can only access your own profile image', 403);
      }

      const imageBase64 = await this.userRepository.getProfileImage(userId);

      if (!imageBase64) {
        throw new AppError('No profile image found', 404);
      }

      const response = {
        data: { imageBase64 },
        _links: this.generateHateoasLinks(req, userId)
      };

      res.json(response);
    } catch (error) {
      throw error;
    }
  }

  /**
   * Generate HATEOAS links for user resources
   */
  generateHateoasLinks(req, userId) {
    const baseUrl = `${req.protocol}://${req.get('host')}`;
    
    return {
      self: {
        href: `${baseUrl}/api/users/${userId}`,
        method: 'GET'
      },
      update: {
        href: `${baseUrl}/api/users/${userId}`,
        method: 'PUT'
      },
      delete: {
        href: `${baseUrl}/api/users/${userId}`,
        method: 'DELETE'
      },
      image: {
        href: `${baseUrl}/api/users/${userId}/image`,
        method: 'GET'
      },
      updateImage: {
        href: `${baseUrl}/api/users/${userId}/image`,
        method: 'POST'
      },
      wrapped: {
        href: `${baseUrl}/api/wrapped/${userId}`,
        method: 'GET'
      }
    };
  }

  /**
   * Validate base64 image format
   */
  isValidBase64Image(base64String) {
    const base64Regex = /^data:image\/(jpeg|jpg|png|gif|webp);base64,/;
    return base64Regex.test(base64String);
  }
}

// Exportar uma instância em vez da classe
module.exports = new UserController(); 