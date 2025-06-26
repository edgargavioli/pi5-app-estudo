// Mock de variáveis de ambiente para testes
process.env.NODE_ENV = 'test';
process.env.PORT = '4040';
process.env.DATABASE = 'postgresql://test:test@localhost:5432/notifications_test';
process.env.RABBITMQ = 'amqp://localhost:5672';
process.env.FIREBASE = JSON.stringify({
  type: 'service_account',
  project_id: 'test-project',
  private_key_id: 'test-key-id',
  private_key: '-----BEGIN PRIVATE KEY-----\nTEST_KEY\n-----END PRIVATE KEY-----\n',
  client_email: 'test@test-project.iam.gserviceaccount.com',
  client_id: '123456789',
  auth_uri: 'https://accounts.google.com/o/oauth2/auth',
  token_uri: 'https://oauth2.googleapis.com/token'
});

// Configurações de timeout globais
global.TEST_TIMEOUTS = {
  QUICK: 1000,
  NORMAL: 5000,
  SLOW: 10000,
  ASYNC_TIMEOUT: 15000
};

// Helper functions para testes
global.createMockNotification = (overrides = {}) => ({
  id: 'test-notification-id',
  userId: 'test-user-id',
  type: 'PROVA_CRIADA',
  entityId: 'test-entity-id',
  entityType: 'exam',
  entityData: {
    titulo: 'Prova de Teste',
    data: new Date().toISOString(),
    local: 'Sala 101'
  },
  scheduledFor: new Date(),
  status: 'PENDING',
  createdAt: new Date(),
  updatedAt: new Date(),
  ...overrides
});

global.createMockUser = (overrides = {}) => ({
  id: 'test-user-id',
  fcmToken: 'test-fcm-token',
  createdAt: new Date(),
  updatedAt: new Date(),
  ...overrides
});

global.createMockChannel = () => ({
  assertQueue: jest.fn().mockResolvedValue({}),
  consume: jest.fn(),
  sendToQueue: jest.fn().mockResolvedValue(true),
  ack: jest.fn(),
  nack: jest.fn(),
  close: jest.fn(),
  on: jest.fn(),
  removeAllListeners: jest.fn()
});

// Mock de mensagens RabbitMQ
global.createMockRabbitMessage = (content = {}, properties = {}) => ({
  content: Buffer.from(JSON.stringify(content)),
  properties: {
    contentType: 'application/json',
    ...properties
  },
  fields: {
    deliveryTag: 1,
    redelivered: false,
    exchange: '',
    routingKey: 'test.queue'
  }
});

// Utilitários para aguardar operações assíncronas
global.waitFor = (ms) => new Promise(resolve => setTimeout(resolve, ms));

global.waitForCondition = async (condition, timeout = 15000) => {
  const start = Date.now();
  while (Date.now() - start < timeout) {
    if (await condition()) {
      return true;
    }
    await global.waitFor(10);
  }
  throw new Error(`Condition not met within ${timeout}ms`);
};

// Mock de timers globais
global.mockTimers = () => {
  jest.useFakeTimers();
  return {
    advanceBy: (ms) => jest.advanceTimersByTime(ms),
    runAll: () => jest.runAllTimers(),
    runPending: () => jest.runOnlyPendingTimers(),
    restore: () => jest.useRealTimers()
  };
}; 