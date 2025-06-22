// Setup global para testes
import dotenv from 'dotenv';
import { jest } from '@jest/globals';

// Carregar variáveis de ambiente de teste
dotenv.config({ path: '.env.test' });

// Configurar variáveis de ambiente padrão para testes
process.env.NODE_ENV = 'test';
process.env.DATABASE_URL = process.env.DATABASE_URL || 'postgresql://postgres:postgres@localhost:5432/provas_test';
process.env.JWT_SECRET = 'test-secret-key';
process.env.USER_SERVICE_URL = 'http://localhost:3000';
process.env.RABBITMQ_URL = 'amqp://admin:admin123@localhost:5672/';

// Importar módulos antes de mockar (ESM)
import * as loggerModule from '../src/application/utils/logger.js';
import * as rabbitModule from '../src/infrastructure/messaging/RabbitMQService.js';

// Mock do logger para evitar logs durante testes
jest.unstable_mockModule('../src/application/utils/logger.js', () => ({
  logger: {
    info: jest.fn(),
    error: jest.fn(),
    warn: jest.fn(),
    debug: jest.fn()
  }
}));

// Mock do RabbitMQ para evitar conexões reais durante testes
jest.unstable_mockModule('../src/infrastructure/messaging/RabbitMQService.js', () => ({
  default: {
    connect: jest.fn().mockResolvedValue(true),
    close: jest.fn().mockResolvedValue(true),
    publish: jest.fn().mockResolvedValue(true),
    publishSessaoCriada: jest.fn().mockResolvedValue(true),
    publishSessaoFinalizada: jest.fn().mockResolvedValue(true),
    publishProvaFinalizada: jest.fn().mockResolvedValue(true),
    isHealthy: jest.fn().mockReturnValue(true)
  }
}));

// Configurar timeout global para testes
jest.setTimeout(10000);

// Limpar mocks após cada teste
afterEach(() => {
  jest.clearAllMocks();
});

// Configurar console para não poluir os logs de teste
global.console = {
  ...console,
  log: jest.fn(),
  debug: jest.fn(),
  info: jest.fn(),
  warn: jest.fn(),
  error: jest.fn(),
}; 