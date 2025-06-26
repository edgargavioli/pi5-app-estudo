const User = require('../src/domain/entities/User');
const Password = require('../src/domain/valueObjects/Password');
const Email = require('../src/domain/valueObjects/Email');

describe('🏛️ DOMAIN LAYER - User Service', () => {
  
  describe('📋 User Entity', () => {
    
    test('deve criar usuário com dados válidos', () => {
      const userData = {
        email: 'test@example.com',
        password: 'hashedPassword123',
        name: 'Test User'
      };
      
      const user = new User(userData);
      
      expect(user.email).toBe('test@example.com');
      expect(user.name).toBe('Test User');
      expect(user.points).toBe(0);
      expect(user.isEmailVerified).toBe(false);
    });

    test('deve falhar com email inválido', () => {
      const userData = {
        email: 'invalid-email',
        name: 'Test User'
      };
      
      expect(() => new User(userData)).toThrow('Invalid email format');
    });

    test('deve falhar com nome muito curto', () => {
      const userData = {
        email: 'test@example.com',
        name: 'A'
      };
      
      expect(() => new User(userData)).toThrow('Name must be at least 2 characters long');
    });

    test('deve falhar com pontos negativos', () => {
      const userData = {
        email: 'test@example.com',
        name: 'Test User',
        points: -10
      };
      
      expect(() => new User(userData)).toThrow('Points cannot be negative');
    });

    test('deve verificar email corretamente', () => {
      const user = new User({
        email: 'test@example.com',
        name: 'Test User'
      });
      
      user.verifyEmail();
      
      expect(user.isEmailVerified).toBe(true);
      expect(user.updatedAt).toBeInstanceOf(Date);
    });

    test('deve atualizar último login', () => {
      const user = new User({
        email: 'test@example.com',
        name: 'Test User'
      });
      
      user.updateLastLogin();
      
      expect(user.lastLogin).toBeInstanceOf(Date);
      expect(user.updatedAt).toBeInstanceOf(Date);
    });

    test('deve retornar JSON público sem dados sensíveis', () => {
      const user = new User({
        email: 'test@example.com',
        password: 'secretPassword',
        name: 'Test User'
      });
      
      const publicData = user.toPublicJSON();
      
      expect(publicData).toHaveProperty('email');
      expect(publicData).toHaveProperty('name');
      expect(publicData).not.toHaveProperty('password');
    });

    test('deve permitir atualização de perfil apenas com email verificado', () => {
      const user = new User({
        email: 'test@example.com',
        name: 'Test User',
        isEmailVerified: true
      });
      
      expect(user.canUpdateProfile()).toBe(true);
    });

    test('não deve permitir atualização sem email verificado', () => {
      const user = new User({
        email: 'test@example.com',
        name: 'Test User',
        isEmailVerified: false
      });
      
      expect(user.canUpdateProfile()).toBe(false);
    });
  });

  describe('🔒 Password Value Object', () => {
    
    test('deve criar senha válida', () => {
      const password = new Password('ValidPass123!');
      
      expect(password.value).toBe('ValidPass123!');
      expect(password.isHashed).toBe(false);
    });

    test('deve falhar com senha muito curta', () => {
      expect(() => new Password('123')).toThrow('Password does not meet security requirements');
    });

    test('deve falhar sem letra maiúscula', () => {
      expect(() => new Password('validpass123!')).toThrow('Password does not meet security requirements');
    });

    test('deve falhar sem letra minúscula', () => {
      expect(() => new Password('VALIDPASS123!')).toThrow('Password does not meet security requirements');
    });

    test('deve falhar sem número', () => {
      expect(() => new Password('ValidPass!')).toThrow('Password does not meet security requirements');
    });

    test('deve falhar sem caractere especial', () => {
      expect(() => new Password('ValidPass123')).toThrow('Password does not meet security requirements');
    });

    test('deve criar senha a partir de hash', () => {
      const hashedPassword = Password.fromHash('$2b$10$hashedValue');
      
      expect(hashedPassword.isHashed).toBe(true);
      expect(hashedPassword.value).toBe('$2b$10$hashedValue');
    });

    test('deve fazer hash da senha', async () => {
      const password = new Password('ValidPass123!');
      
      const hashedValue = await password.hash();
      
      expect(hashedValue).toBe('hashedPassword123'); // Mock value
      expect(password.isHashed).toBe(true);
    });
  });

  describe('📧 Email Value Object', () => {
    
    test('deve criar email válido', () => {
      const email = new Email('test@example.com');
      
      expect(email.value).toBe('test@example.com');
    });

    test('deve normalizar email (lowercase e trim)', () => {
      const email = new Email('  TEST@EXAMPLE.COM  ');
      
      expect(email.value).toBe('test@example.com');
    });

    test('deve falhar com email inválido', () => {
      expect(() => new Email('invalid-email')).toThrow('Invalid email format');
    });

    test('deve falhar com email vazio', () => {
      expect(() => new Email('')).toThrow('Email is required');
    });

    test('deve extrair domínio corretamente', () => {
      const email = new Email('user@example.com');
      
      expect(email.getDomain()).toBe('example.com');
    });

    test('deve extrair parte local corretamente', () => {
      const email = new Email('user@example.com');
      
      expect(email.getLocalPart()).toBe('user');
    });

    test('deve comparar emails corretamente', () => {
      const email1 = new Email('test@example.com');
      const email2 = new Email('test@example.com');
      const email3 = new Email('other@example.com');
      
      expect(email1.equals(email2)).toBe(true);
      expect(email1.equals(email3)).toBe(false);
    });
  });
}); 