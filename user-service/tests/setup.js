// Configuração global de testes para user-service
// Este arquivo é executado antes de todos os testes

// Mock do Prisma Client
jest.mock('@prisma/client', () => {
  const mockPrisma = {
    user: {
      findUnique: jest.fn(),
      findFirst: jest.fn(),
      findMany: jest.fn(),
      create: jest.fn(),
      update: jest.fn(),
      delete: jest.fn(),
      count: jest.fn()
    },
    pointsTransaction: {
      create: jest.fn(),
      findMany: jest.fn()
    },
    studyStreak: {
      findUnique: jest.fn(),
      create: jest.fn(),
      update: jest.fn()
    },
    $disconnect: jest.fn()
  };

  return {
    PrismaClient: jest.fn(() => mockPrisma)
  };
});

// Mock do bcrypt
jest.mock('bcrypt', () => ({
  hash: jest.fn().mockResolvedValue('hashedPassword123'),
  compare: jest.fn().mockResolvedValue(true),
  genSalt: jest.fn().mockResolvedValue('salt')
}));

// Mock do jsonwebtoken
jest.mock('jsonwebtoken', () => ({
  sign: jest.fn().mockReturnValue('mockToken123'),
  verify: jest.fn().mockReturnValue({ userId: 'user123', email: 'test@example.com' }),
  decode: jest.fn().mockReturnValue({ userId: 'user123' })
}));

// Mock do nodemailer
jest.mock('nodemailer', () => ({
  createTransporter: jest.fn().mockReturnValue({
    sendMail: jest.fn().mockResolvedValue({ messageId: 'mock-message-id' })
  })
}));

// Mock do winston (logging)
jest.mock('winston', () => ({
  createLogger: jest.fn().mockReturnValue({
    info: jest.fn(),
    error: jest.fn(),
    warn: jest.fn(),
    debug: jest.fn(),
    add: jest.fn()
  }),
  format: {
    combine: jest.fn().mockReturnValue('combined-format'),
    timestamp: jest.fn().mockReturnValue('timestamp-format'),
    errors: jest.fn().mockReturnValue('errors-format'),
    json: jest.fn().mockReturnValue('json-format'),
    printf: jest.fn().mockReturnValue('printf-format'),
    colorize: jest.fn().mockReturnValue('colorize-format'),
    simple: jest.fn().mockReturnValue('simple-format')
  },
  transports: {
    Console: jest.fn().mockImplementation(() => ({})),
    File: jest.fn().mockImplementation(() => ({}))
  }
}));

// Configurar variáveis de ambiente para testes
process.env.NODE_ENV = 'test';
process.env.JWT_SECRET = 'test-jwt-secret';
process.env.JWT_EXPIRES_IN = '24h';
process.env.DATABASE_URL = 'postgresql://test:test@localhost:5432/test_db';

// Utilitários globais para testes
global.createMockUser = (overrides = {}) => ({
  id: 'user-123',
  email: 'test@example.com',
  password: 'hashedPassword123',
  name: 'Test User',
  points: 100,
  isEmailVerified: true,
  lastLogin: new Date('2024-01-01'),
  createdAt: new Date('2024-01-01'),
  updatedAt: new Date('2024-01-01'),
  imageBase64: null,
  ...overrides
});

global.createMockPrismaUser = (overrides = {}) => ({
  id: 'user-123',
  email: 'test@example.com',
  password: 'hashedPassword123',
  name: 'Test User',
  points: 100,
  isEmailVerified: true,
  lastLogin: new Date('2024-01-01'),
  createdAt: new Date('2024-01-01'),
  updatedAt: new Date('2024-01-01'),
  imageBase64: null,
  ...overrides
});

// Limpar todos os mocks antes de cada teste
beforeEach(() => {
  jest.clearAllMocks();
});

// Configurar timeout global
jest.setTimeout(10000); 