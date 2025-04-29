const RegisterUser = require('../../application/useCases/RegisterUser');
const AuthenticateUser = require('../../application/useCases/AuthenticateUser');
const RecoverPassword = require('../../application/useCases/RecoverPassword');
const ResetPassword = require('../../application/useCases/ResetPassword');
const ChangePassword = require('../../application/useCases/ChangePassword');
const VerifyEmail = require('../../application/useCases/VerifyEmail');
const BlockAccount = require('../../application/useCases/BlockAccount');
const UnblockAccount = require('../../application/useCases/UnblockAccount');
const VerifyResetToken = require('../../application/useCases/VerifyResetToken');
const jwtService = require('../../infrastructure/jwt/jwtService');
const { generateAuthLinks, generateUserLinks, generateAdminLinks } = require('../../utils/hateoas');

/**
 * Controlador para gerenciar todas as rotas relacionadas à autenticação
 */
class AuthController {
  /**
   * Cria uma instância do controlador
   * @param {UserRepository} userRepository - Repositório de usuários
   * @param {PasswordResetRepository} passwordResetRepository - Repositório de tokens de recuperação de senha
   */
  constructor(userRepository, passwordResetRepository) {
    this.userRepository = userRepository;
    this.passwordResetRepository = passwordResetRepository;
    
    // Inicializa os casos de uso
    this.registerUserUseCase = new RegisterUser(userRepository);
    this.authenticateUserUseCase = new AuthenticateUser(userRepository);
    this.recoverPasswordUseCase = new RecoverPassword(userRepository, passwordResetRepository);
    this.resetPasswordUseCase = new ResetPassword(userRepository, passwordResetRepository);
    this.changePasswordUseCase = new ChangePassword(userRepository);
    this.verifyEmailUseCase = new VerifyEmail(userRepository);
    this.blockAccountUseCase = new BlockAccount(userRepository);
    this.unblockAccountUseCase = new UnblockAccount(userRepository);
    this.verifyResetTokenUseCase = new VerifyResetToken(userRepository, passwordResetRepository);
  }

  /**
   * Registra um novo usuário
   * @param {Object} req - Requisição
   * @param {Object} res - Resposta
   */
  async register(req, res) {
    try {
      const { email, password, name } = req.body;

      if (!email || !password) {
        return res.status(400).json({
          success: false,
          message: 'Email e senha são obrigatórios',
          _links: generateAuthLinks()
        });
      }

      const result = await this.registerUserUseCase.execute(email, password, name);

      return res.status(201).json({
        success: true,
        message: 'Usuário registrado com sucesso',
        data: {
          user: result.user,
          tokens: result.tokens
        },
        _links: {
          ...generateAuthLinks(),
          ...generateUserLinks(result.user.id)
        }
      });
    } catch (error) {
      console.error('Erro ao registrar usuário:', error);
      
      if (error.message.includes('Email já está em uso')) {
        return res.status(409).json({
          success: false,
          message: 'Email já está em uso',
          _links: generateAuthLinks()
        });
      }
      
      if (error.message.includes('Formato de email inválido')) {
        return res.status(400).json({
          success: false,
          message: 'Formato de email inválido',
          _links: generateAuthLinks()
        });
      }
      
      if (error.message.includes('A senha deve ter')) {
        return res.status(400).json({
          success: false,
          message: error.message,
          _links: generateAuthLinks()
        });
      }

      if (error.message.includes('O nome não pode exceder')) {
        return res.status(400).json({
          success: false,
          message: error.message,
          _links: generateAuthLinks()
        });
      }

      return res.status(500).json({
        success: false,
        message: 'Erro ao registrar usuário',
        _links: generateAuthLinks()
      });
    }
  }

  /**
   * Autentica um usuário
   * @param {Object} req - Requisição
   * @param {Object} res - Resposta
   */
  async login(req, res) {
    try {
      const { email, password } = req.body;

      if (!email || !password) {
        return res.status(400).json({
          success: false,
          message: 'Email e senha são obrigatórios',
          _links: generateAuthLinks()
        });
      }

      const result = await this.authenticateUserUseCase.execute(email, password);

      return res.status(200).json({
        success: true,
        message: 'Login realizado com sucesso',
        data: {
          user: result.user,
          accessToken: result.tokens.accessToken,
          refreshToken: result.tokens.refreshToken
        },
        _links: generateUserLinks(result.user.id)
      });
    } catch (error) {
      console.error('Erro ao autenticar usuário:', error);
      
      if (error.message.includes('Credenciais inválidas')) {
        return res.status(401).json({
          success: false,
          message: error.message,
          _links: generateAuthLinks()
        });
      }
      
      if (error.message.includes('Conta bloqueada')) {
        return res.status(403).json({
          success: false,
          message: error.message,
          _links: generateAuthLinks()
        });
      }
      
      if (error.message.includes('Email não verificado')) {
        return res.status(403).json({
          success: false,
          message: error.message,
          _links: generateAuthLinks()
        });
      }

      return res.status(500).json({
        success: false,
        message: 'Erro ao realizar login',
        _links: generateAuthLinks()
      });
    }
  }

  /**
   * Atualiza o token de acesso usando o refresh token
   * @param {Object} req - Requisição
   * @param {Object} res - Resposta
   */
  async refreshToken(req, res) {
    try {
      const refreshToken = req.cookies.refreshToken || req.body.refreshToken;
      
      if (!refreshToken) {
        return res.status(400).json({
          success: false,
          message: 'Refresh token não fornecido',
          _links: generateAuthLinks()
        });
      }

      const newAccessToken = jwtService.refreshAccessToken(refreshToken);
      
      if (!newAccessToken) {
        return res.status(401).json({
          success: false,
          message: 'Refresh token inválido ou expirado',
          _links: generateAuthLinks()
        });
      }

      return res.status(200).json({
        success: true,
        message: 'Token atualizado com sucesso',
        data: {
          accessToken: newAccessToken
        },
        _links: generateAuthLinks()
      });
    } catch (error) {
      console.error('Erro ao atualizar token:', error);
      return res.status(500).json({
        success: false,
        message: 'Erro ao atualizar token',
        _links: generateAuthLinks()
      });
    }
  }

  /**
   * Inicia o processo de recuperação de senha
   * @param {Object} req - Requisição
   * @param {Object} res - Resposta
   */
  async recoverPasswordRequest(req, res) {
    try {
      const { email } = req.body;

      if (!email) {
        return res.status(400).json({
          success: false,
          message: 'Email é obrigatório',
          _links: generateAuthLinks()
        });
      }

      await this.recoverPasswordUseCase.execute(email);

      return res.status(200).json({
        success: true,
        message: 'Link de recuperação de senha enviado para o email informado',
        _links: generateAuthLinks()
      });
    } catch (error) {
      console.error('Erro ao solicitar recuperação de senha:', error);
      
      if (error.message.includes('Email inválido ou não registrado')) {
        return res.status(404).json({
          success: false,
          message: 'Email não encontrado em nossa base de dados',
          _links: generateAuthLinks()
        });
      }

      return res.status(500).json({
        success: false,
        message: 'Erro ao solicitar recuperação de senha',
        _links: generateAuthLinks()
      });
    }
  }

  /**
   * Redefine a senha usando o token de recuperação
   * @param {Object} req - Requisição
   * @param {Object} res - Resposta
   */
  async resetPassword(req, res) {
    try {
      const { token, newPassword } = req.body;

      if (!token || !newPassword) {
        return res.status(400).json({
          success: false,
          message: 'Token e nova senha são obrigatórios'
        });
      }

      // Chamar o caso de uso
      await this.resetPasswordUseCase.execute(token, newPassword);

      return res.status(200).json({
        success: true,
        message: 'Senha redefinida com sucesso'
      });
    } catch (error) {
      console.error('Erro ao redefinir senha:', error);
      
      // Tratar erros específicos
      if (error.message.includes('Token inválido')) {
        return res.status(400).json({
          success: false,
          message: error.message
        });
      }
      
      if (error.message.includes('A senha deve ter')) {
        return res.status(400).json({
          success: false,
          message: error.message
        });
      }

      return res.status(500).json({
        success: false,
        message: 'Erro ao redefinir senha'
      });
    }
  }

  /**
   * Altera a senha do usuário autenticado
   * @param {Object} req - Requisição
   * @param {Object} res - Resposta
   */
  async changePassword(req, res) {
    try {
      const { currentPassword, newPassword } = req.body;
      const userId = req.user.id;

      if (!currentPassword || !newPassword) {
        return res.status(400).json({
          success: false,
          message: 'Senha atual e nova senha são obrigatórias'
        });
      }

      // Chamar o caso de uso
      const result = await this.changePasswordUseCase.execute(userId, currentPassword, newPassword);

      return res.status(200).json({
        success: true,
        message: 'Senha alterada com sucesso',
        data: {
          accessToken: result.accessToken
        }
      });
    } catch (error) {
      console.error('Erro ao alterar senha:', error);
      
      // Tratar erros específicos
      if (error.message.includes('Senha atual incorreta')) {
        return res.status(401).json({
          success: false,
          message: error.message
        });
      }
      
      if (error.message.includes('A nova senha deve')) {
        return res.status(400).json({
          success: false,
          message: error.message
        });
      }

      return res.status(500).json({
        success: false,
        message: 'Erro ao alterar senha'
      });
    }
  }

  /**
   * Verifica o email do usuário
   * @param {Object} req - Requisição
   * @param {Object} res - Resposta
   */
  async verifyEmail(req, res) {
    try {
      const { token } = req.query;

      if (!token) {
        return res.status(400).json({
          success: false,
          message: 'Token é obrigatório',
          _links: generateAuthLinks()
        });
      }

      await this.verifyEmailUseCase.execute(token);

      return res.status(200).json({
        success: true,
        message: 'Email verificado com sucesso',
        _links: generateAuthLinks()
      });
    } catch (error) {
      console.error('Erro ao verificar email:', error);
      
      if (error.message.includes('Token inválido')) {
        return res.status(400).json({
          success: false,
          message: error.message,
          _links: generateAuthLinks()
        });
      }

      return res.status(500).json({
        success: false,
        message: 'Erro ao verificar email',
        _links: generateAuthLinks()
      });
    }
  }

  /**
   * Bloqueia a conta de um usuário (requer permissão de admin)
   * @param {Object} req - Requisição
   * @param {Object} res - Resposta
   */
  async blockAccount(req, res) {
    try {
      const { userId, reason } = req.body;
      const adminId = req.user.id;

      if (!userId) {
        return res.status(400).json({
          success: false,
          message: 'ID do usuário é obrigatório',
          _links: generateAdminLinks(userId)
        });
      }

      await this.blockAccountUseCase.execute(userId, reason || 'Não especificado', adminId);

      return res.status(200).json({
        success: true,
        message: 'Conta bloqueada com sucesso',
        _links: generateAdminLinks(userId)
      });
    } catch (error) {
      console.error('Erro ao bloquear conta:', error);
      
      if (error.message.includes('Usuário não encontrado')) {
        return res.status(404).json({
          success: false,
          message: error.message,
          _links: generateAdminLinks(req.body.userId)
        });
      }

      return res.status(500).json({
        success: false,
        message: 'Erro ao bloquear conta',
        _links: generateAdminLinks(req.body.userId)
      });
    }
  }

  /**
   * Desbloqueia a conta de um usuário (requer permissão de admin)
   * @param {Object} req - Requisição
   * @param {Object} res - Resposta
   */
  async unblockAccount(req, res) {
    try {
      const { userId } = req.body;
      const adminId = req.user.id;

      if (!userId) {
        return res.status(400).json({
          success: false,
          message: 'ID do usuário é obrigatório',
          _links: generateAdminLinks(userId)
        });
      }

      await this.unblockAccountUseCase.execute(userId, adminId);

      return res.status(200).json({
        success: true,
        message: 'Conta desbloqueada com sucesso',
        _links: generateAdminLinks(userId)
      });
    } catch (error) {
      console.error('Erro ao desbloquear conta:', error);
      
      if (error.message.includes('Usuário não encontrado')) {
        return res.status(404).json({
          success: false,
          message: error.message,
          _links: generateAdminLinks(req.body.userId)
        });
      }

      return res.status(500).json({
        success: false,
        message: 'Erro ao desbloquear conta',
        _links: generateAdminLinks(req.body.userId)
      });
    }
  }

  /**
   * Realiza o logout do usuário
   * @param {Object} req - Requisição
   * @param {Object} res - Resposta
   */
  async logout(req, res) {
    try {
      res.clearCookie('refreshToken');
      
      return res.status(200).json({
        success: true,
        message: 'Logout realizado com sucesso',
        _links: generateAuthLinks()
      });
    } catch (error) {
      console.error('Erro ao realizar logout:', error);
      return res.status(500).json({
        success: false,
        message: 'Erro ao realizar logout',
        _links: generateAuthLinks()
      });
    }
  }

  /**
   * Verifica se um token de redefinição de senha é válido
   * @param {Object} req - Requisição
   * @param {Object} res - Resposta
   */
  async verifyResetToken(req, res) {
    try {
      const { token } = req.body;

      if (!token) {
        return res.status(400).json({
          success: false,
          message: 'Token é obrigatório'
        });
      }

      const result = await this.verifyResetTokenUseCase.execute(token);

      if (!result.valid) {
        return res.status(400).json({
          success: false,
          message: 'Token inválido ou expirado'
        });
      }

      return res.status(200).json({
        success: true,
        message: 'Token válido',
        data: {
          userId: result.userId
        }
      });
    } catch (error) {
      console.error('Erro ao verificar token de redefinição de senha:', error);
      
      if (error.message.includes('Token é obrigatório')) {
        return res.status(400).json({
          success: false,
          message: error.message
        });
      }

      return res.status(500).json({
        success: false,
        message: 'Erro ao verificar token de redefinição de senha'
      });
    }
  }
}

module.exports = AuthController; 