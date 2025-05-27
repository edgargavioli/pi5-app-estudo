const RegisterUserUseCase = require('../../application/useCases/auth/RegisterUserUseCase');
const { createHateoasLinks } = require('../../infrastructure/utils/hateoas');
const { verifyPassword } = require('../../infrastructure/utils/passwordUtils');
const jwt = require('jsonwebtoken');
const userRepository = require('../../infrastructure/repositories/UserRepository');
const { handleGoogleAuth } = require('../../infrastructure/services/googleService');
const { verifyEmailToken, sendPasswordResetEmail, resetUserPassword } = require('../../infrastructure/services/emailService');

class AuthController {
  async register(req, res) {
    try {
      const registerUseCase = new RegisterUserUseCase(userRepository);
      const user = await registerUseCase.execute(req.body);
      
      const response = createHateoasLinks(req, user, {
        login: {
          href: '/api/auth/login',
          method: 'POST'
        }
      });

      res.status(201).json(response);
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }

  async login(req, res) {
    try {
      const { email, password } = req.body;
      const user = await userRepository.findByEmail(email);

      if (!user) {
        return res.status(401).json({ error: 'Invalid credentials' });
      }

      const isValidPassword = await verifyPassword(password, user.password);
      if (!isValidPassword) {
        return res.status(401).json({ error: 'Invalid credentials' });
      }

      // Update last login
      await userRepository.updateLastLogin(user.id);

      // Generate JWT token
      const token = jwt.sign(
        { userId: user.id },
        process.env.JWT_SECRET,
        { expiresIn: '1h' }
      );

      const response = createHateoasLinks(req, {
        token,
        user: {
          id: user.id,
          email: user.email,
          name: user.name
        }
      });

      res.json(response);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }

  async googleAuth(req, res) {
    try {
      const { token } = req.body;
      const result = await handleGoogleAuth(token);
      res.json(result);
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }

  async verifyEmail(req, res) {
    try {
      const { token } = req.params;
      const result = await verifyEmailToken(token);
      res.json(result);
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }

  async forgotPassword(req, res) {
    try {
      const { email } = req.body;
      await sendPasswordResetEmail(email);
      res.json({ message: 'Password reset email sent' });
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }

  async resetPassword(req, res) {
    try {
      const { token, password } = req.body;
      await resetUserPassword(token, password);
      res.json({ message: 'Password has been reset' });
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }
}

module.exports = new AuthController(); 