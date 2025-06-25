const GetUserUseCase = require('../src/application/useCases/GetUserUseCase');
const UpdateUserUseCase = require('../src/application/useCases/UpdateUserUseCase');
const User = require('../src/domain/entities/User');

// Mock do repositório
const mockUserRepository = {
  findById: jest.fn(),
  findByEmail: jest.fn(),
  save: jest.fn(),
  update: jest.fn(),
  delete: jest.fn(),
  emailExists: jest.fn()
};

describe('🚀 APPLICATION LAYER - Use Cases', () => {
  
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('👤 GetUserUseCase', () => {
    let getUserUseCase;

    beforeEach(() => {
      getUserUseCase = new GetUserUseCase(mockUserRepository);
    });

    test('deve retornar usuário quando autorizado', async () => {
      const mockUser = new User({
        id: 'user-123',
        email: 'test@example.com',
        name: 'Test User'
      });
      
      mockUserRepository.findById.mockResolvedValue(mockUser);

      const result = await getUserUseCase.execute('user-123', 'user-123');

      expect(mockUserRepository.findById).toHaveBeenCalledWith('user-123');
      expect(result).toEqual(mockUser.toPublicJSON());
    });

    test('deve falhar quando usuário tenta acessar dados de outro', async () => {
      await expect(
        getUserUseCase.execute('user-123', 'user-456')
      ).rejects.toThrow('Unauthorized: You can only access your own profile');

      expect(mockUserRepository.findById).not.toHaveBeenCalled();
    });

    test('deve falhar quando usuário não existe', async () => {
      mockUserRepository.findById.mockResolvedValue(null);

      await expect(
        getUserUseCase.execute('user-123', 'user-123')
      ).rejects.toThrow('User not found');

      expect(mockUserRepository.findById).toHaveBeenCalledWith('user-123');
    });

    test('deve propagar erros do repositório', async () => {
      const repositoryError = new Error('Database connection failed');
      mockUserRepository.findById.mockRejectedValue(repositoryError);

      await expect(
        getUserUseCase.execute('user-123', 'user-123')
      ).rejects.toThrow('Database connection failed');
    });
  });

  describe('✏️ UpdateUserUseCase', () => {
    let updateUserUseCase;

    beforeEach(() => {
      updateUserUseCase = new UpdateUserUseCase(mockUserRepository);
    });

    test('deve atualizar usuário com dados válidos', async () => {
      const existingUser = new User({
        id: 'user-123',
        email: 'old@example.com',
        name: 'Old Name'
      });

      const updatedUser = new User({
        id: 'user-123',
        email: 'new@example.com',
        name: 'New Name'
      });

      mockUserRepository.findById.mockResolvedValue(existingUser);
      mockUserRepository.emailExists.mockResolvedValue(false);
      mockUserRepository.update.mockResolvedValue(updatedUser);

      const updateData = {
        email: 'new@example.com',
        name: 'New Name'
      };

      const result = await updateUserUseCase.execute('user-123', updateData, 'user-123');

      expect(mockUserRepository.findById).toHaveBeenCalledWith('user-123');
      expect(mockUserRepository.emailExists).toHaveBeenCalledWith('new@example.com', 'user-123');
      expect(mockUserRepository.update).toHaveBeenCalled();
      expect(result).toEqual(updatedUser.toPublicJSON());
    });

    test('deve falhar quando usuário tenta atualizar dados de outro', async () => {
      const updateData = { name: 'New Name' };

      await expect(
        updateUserUseCase.execute('user-123', updateData, 'user-456')
      ).rejects.toThrow('Unauthorized: You can only update your own profile');

      expect(mockUserRepository.findById).not.toHaveBeenCalled();
    });

    test('deve falhar quando usuário não existe', async () => {
      mockUserRepository.findById.mockResolvedValue(null);
      const updateData = { name: 'New Name' };

      await expect(
        updateUserUseCase.execute('user-123', updateData, 'user-123')
      ).rejects.toThrow('User not found');

      expect(mockUserRepository.findById).toHaveBeenCalledWith('user-123');
    });

    test('deve falhar quando email já está em uso', async () => {
      const existingUser = new User({
        id: 'user-123',
        email: 'old@example.com',
        name: 'Test User'
      });

      mockUserRepository.findById.mockResolvedValue(existingUser);
      mockUserRepository.emailExists.mockResolvedValue(true);

      const updateData = { email: 'taken@example.com' };

      await expect(
        updateUserUseCase.execute('user-123', updateData, 'user-123')
      ).rejects.toThrow('Email already in use');

      expect(mockUserRepository.emailExists).toHaveBeenCalledWith('taken@example.com', 'user-123');
      expect(mockUserRepository.update).not.toHaveBeenCalled();
    });

    test('deve atualizar senha com hash', async () => {
      const existingUser = new User({
        id: 'user-123',
        email: 'test@example.com',
        name: 'Test User'
      });

      mockUserRepository.findById.mockResolvedValue(existingUser);
      mockUserRepository.update.mockResolvedValue(existingUser);

      const updateData = { password: 'NewPassword123!' };

      await updateUserUseCase.execute('user-123', updateData, 'user-123');

      expect(mockUserRepository.update).toHaveBeenCalled();
      const updateCall = mockUserRepository.update.mock.calls[0][0];
      expect(updateCall.password).toBe('hashedPassword123'); // Mock hash value
    });

    test('deve falhar com email inválido', async () => {
      const existingUser = new User({
        id: 'user-123',
        email: 'test@example.com',
        name: 'Test User'
      });

      mockUserRepository.findById.mockResolvedValue(existingUser);

      const updateData = { email: 'invalid-email' };

      await expect(
        updateUserUseCase.execute('user-123', updateData, 'user-123')
      ).rejects.toThrow('Invalid email format');

      expect(mockUserRepository.update).not.toHaveBeenCalled();
    });

    test('deve falhar com senha inválida', async () => {
      const existingUser = new User({
        id: 'user-123',
        email: 'test@example.com',
        name: 'Test User'
      });

      mockUserRepository.findById.mockResolvedValue(existingUser);

      const updateData = { password: '123' }; // Senha muito curta

      await expect(
        updateUserUseCase.execute('user-123', updateData, 'user-123')
      ).rejects.toThrow('Password does not meet security requirements');

      expect(mockUserRepository.update).not.toHaveBeenCalled();
    });

    test('deve atualizar apenas o nome quando fornecido', async () => {
      const existingUser = new User({
        id: 'user-123',
        email: 'test@example.com',
        name: 'Old Name'
      });

      mockUserRepository.findById.mockResolvedValue(existingUser);
      mockUserRepository.update.mockResolvedValue(existingUser);

      const updateData = { name: '  New Name  ' }; // Com espaços

      await updateUserUseCase.execute('user-123', updateData, 'user-123');

      expect(mockUserRepository.update).toHaveBeenCalled();
      const updateCall = mockUserRepository.update.mock.calls[0][0];
      expect(updateCall.name).toBe('New Name'); // Trimmed
    });

    test('deve atualizar timestamp updatedAt', async () => {
      const existingUser = new User({
        id: 'user-123',
        email: 'test@example.com',
        name: 'Test User'
      });

      const originalUpdatedAt = existingUser.updatedAt;
      mockUserRepository.findById.mockResolvedValue(existingUser);
      mockUserRepository.update.mockResolvedValue(existingUser);

      const updateData = { name: 'New Name' };

      await updateUserUseCase.execute('user-123', updateData, 'user-123');

      expect(mockUserRepository.update).toHaveBeenCalled();
      const updateCall = mockUserRepository.update.mock.calls[0][0];
      expect(updateCall.updatedAt).toBeInstanceOf(Date);
      expect(updateCall.updatedAt).not.toEqual(originalUpdatedAt);
    });
  });
}); 