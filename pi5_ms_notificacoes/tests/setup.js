// Setup global para testes do microserviço de notificações
import { jest } from '@jest/globals';

// Configurar variáveis de ambiente para teste
process.env.NODE_ENV = 'test';
process.env.DATABASE_URL = 'postgresql://postgres:postgres@localhost:5432/notificacoes_test';
process.env.JWT_SECRET = 'test-secret-key';
process.env.FIREBASE_PROJECT_ID = 'test-project';
process.env.FIREBASE_PRIVATE_KEY = 'test-private-key';
process.env.FIREBASE_CLIENT_EMAIL = 'test@test.com';
process.env.RABBITMQ_URL = 'amqp://admin:admin123@localhost:5672/';

// Mock global do RabbitMQ
jest.unstable_mockModule('../src/infrastructure/messaging/rabbitmq.js', () => ({
    getChannel: jest.fn(),
    connect: jest.fn(),
    publish: jest.fn(),
    consume: jest.fn(),
    close: jest.fn()
}));

// Mock global do Firebase
jest.unstable_mockModule('../src/infrastructure/firebase/firebase-notification-service.js', () => ({
    default: jest.fn().mockImplementation(() => ({
        sendNotification: jest.fn(),
        sendMulticast: jest.fn()
    }))
}));

// Configurar timeout para testes
jest.setTimeout(10000);

// Limpeza automática de mocks após cada teste
afterEach(() => {
    jest.clearAllMocks();
}); 