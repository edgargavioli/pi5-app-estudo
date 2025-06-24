const GetUserUseCase = require('../../application/useCases/GetUserUseCase');
const UpdateUserUseCase = require('../../application/useCases/UpdateUserUseCase');
const UpdateFcmTokenUseCase = require('../../application/useCases/UpdateFcmTokenUseCase');
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
    this.updateFcmTokenUseCase = new UpdateFcmTokenUseCase(this.userRepository);    // Bind methods to preserve 'this' context
    this.getUser = this.getUser.bind(this);
    this.updateUser = this.updateUser.bind(this);
    this.updateFcmToken = this.updateFcmToken.bind(this);
    this.deleteUser = this.deleteUser.bind(this);
    this.updateProfileImage = this.updateProfileImage.bind(this);
    this.getProfileImage = this.getProfileImage.bind(this);
    this.addPoints = this.addPoints.bind(this);
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
      // Melhorar mensagens de erro para busca de usuário
      if (error.message && error.message.includes('User not found')) {
        const enhancedError = new AppError(
          'The requested user could not be found',
          404,
          {
            field: 'userId',
            value: req.params.id,
            type: 'user_not_found'
          }
        ).withContext({
          action: 'get_user',
          requestingUserId: req.user.id,
          requestedUserId: req.params.id
        }).withSuggestions([
          'Verify the user ID is correct',
          'Check if the user account still exists',
          'Ensure you have permission to view this user'
        ]);

        throw enhancedError;
      }

      if (error.message && error.message.includes('Unauthorized')) {
        const enhancedError = new AppError(
          'You do not have permission to view this user profile',
          403,
          {
            field: 'authorization',
            type: 'access_denied'
          }
        ).withContext({
          action: 'get_user',
          requestingUserId: req.user.id,
          requestedUserId: req.params.id
        }).withSuggestions([
          'You can only view your own profile',
          'Contact support if you believe this is an error'
        ]);

        throw enhancedError;
      }

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
   * Update FCM token for push notifications
   */
  async updateFcmToken(req, res) {
    try {
      const userId = req.params.id;
      const requestingUserId = req.user.id;
      const { fcmToken } = req.body;

      // Authorization check
      if (userId !== requestingUserId) {
        throw new AppError('Unauthorized: You can only update your own FCM token', 403);
      }

      // Validation
      if (!fcmToken || typeof fcmToken !== 'string' || fcmToken.trim().length === 0) {
        throw new AppError('FCM token is required and must be a valid string', 400);
      }

      const result = await this.updateFcmTokenUseCase.execute(userId, fcmToken.trim(), requestingUserId);

      const response = {
        message: 'FCM token updated successfully',
        data: {
          fcmToken: result.fcmToken
        },
        _links: this.generateHateoasLinks(req, userId)
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
   * Add points to user
   */
  async addPoints(req, res) {
    try {
      const userId = req.params.id;
      const requestingUserId = req.user.id;
      const { points, reason, type = 'ADD' } = req.body;

      // Verificar se o usuário pode adicionar pontos para este usuário
      if (userId !== requestingUserId) {
        const enhancedError = new AppError(
          'You can only add points to your own account',
          403,
          {
            field: 'authorization',
            type: 'access_denied'
          }
        ).withContext({
          action: 'add_points',
          requestingUserId,
          targetUserId: userId
        });

        throw enhancedError;
      }

      // Validar dados de entrada
      if (!points || typeof points !== 'number' || points <= 0) {
        const enhancedError = new AppError(
          'Points must be a positive number',
          400,
          {
            field: 'points',
            value: points,
            type: 'invalid_value'
          }
        );

        throw enhancedError;
      }

      if (!reason || typeof reason !== 'string' || reason.trim().length === 0) {
        const enhancedError = new AppError(
          'Reason is required and must be a non-empty string',
          400,
          {
            field: 'reason',
            value: reason,
            type: 'invalid_value'
          }
        );

        throw enhancedError;
      }

      // Buscar o usuário atual
      const user = await this.getUserUseCase.execute(userId, requestingUserId);      // Calcular novos pontos
      const newPoints = user.points + points;

      // Criar objeto user atualizado para o update
      const userToUpdate = {
        ...user,
        points: newPoints,
        updatedAt: new Date()
      };

      // Atualizar pontos do usuário
      await this.userRepository.update(userToUpdate);

      // Criar transação de pontos
      await this.userRepository.createPointsTransaction({
        userId,
        points,
        reason: reason.trim(),
        type
      });

      // Buscar usuário atualizado
      const updatedUser = await this.getUserUseCase.execute(userId, requestingUserId);

      // Add HATEOAS links
      const response = {
        data: updatedUser,
        message: `Successfully added ${points} points`,
        _links: this.generateHateoasLinks(req, userId)
      };

      res.status(200).json(response);
    } catch (error) {
      throw error;
    }
  }
  /**
   * Processar XP de finalização de sessão de estudo
   */
  async processarXpSessao(req, res) {
    try {
      const userId = req.user.id;
      const sessaoData = req.body;

      console.log('🔍 DEBUG processarXpSessao:', {
        userId,
        sessaoData,
        body: req.body
      });

      // Validar dados obrigatórios - aceitar mínimo de 1 minuto para testes      // Validação mais flexível para testes
      if (sessaoData.tempoEstudoMinutos === undefined || sessaoData.tempoEstudoMinutos === null) {
        console.log('❌ Erro de validação: tempoEstudoMinutos é obrigatório');
        throw new AppError('Tempo de estudo é obrigatório', 400);
      }

      // Aceitar qualquer valor >= 0 (incluindo 0 para testes rápidos)
      if (sessaoData.tempoEstudoMinutos < 0) {
        console.log('❌ Erro de validação:', {
          tempoEstudoMinutos: sessaoData.tempoEstudoMinutos,
          tipo: typeof sessaoData.tempoEstudoMinutos
        });
        throw new AppError('Tempo de estudo não pode ser negativo', 400);
      }

      // Importar GamificationService
      const GamificationService = require('../../infrastructure/services/GamificationService');
      const gamificationService = new GamificationService();

      // Processar XP da sessão
      const resultado = await gamificationService.processarFinalizacaoSessao(userId, {
        ...sessaoData,
        id: sessaoData.sessionId || 'unknown'
      }); console.log('✅ Resultado processarXpSessao:', resultado);

      // Retornar resposta simples sem HATEOAS por enquanto
      const response = {
        data: resultado,
        message: 'XP processado com sucesso'
      };

      res.json(response);
    } catch (error) {
      console.error('❌ Erro em processarXpSessao:', error);

      if (error instanceof AppError) {
        return res.status(error.statusCode).json({
          error: error.message,
          details: error.details
        });
      }

      console.error('Erro ao processar XP da sessão:', error);
      res.status(500).json({
        error: 'Erro interno do servidor ao processar XP',
        message: 'Tente novamente mais tarde'
      });
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
      updateFcmToken: {
        href: `${baseUrl}/api/users/${userId}/fcm-token`,
        method: 'PATCH'
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