const User = require('../../../domain/entities/User');
const { hashPassword } = require('../../../infrastructure/utils/passwordUtils');
const { sendVerificationEmail } = require('../../../infrastructure/services/emailService');

class RegisterUserUseCase {
  constructor(userRepository) {
    this.userRepository = userRepository;
  }

  async execute(userData) {
    const { email, password, name } = userData;

    // Check if user already exists
    const existingUser = await this.userRepository.findByEmail(email);
    if (existingUser) {
      throw new Error('User already exists');
    }

    // Hash password
    const hashedPassword = await hashPassword(password);

    // Create user entity
    const user = new User({
      email,
      password: hashedPassword,
      name
    });

    // Save user
    const savedUser = await this.userRepository.save(user);

    // Send verification email
    await sendVerificationEmail(savedUser);

    return savedUser;
  }
}

module.exports = RegisterUserUseCase; 