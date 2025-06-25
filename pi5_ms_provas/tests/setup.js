// Mock de variáveis de ambiente para testes
process.env.NODE_ENV = 'test';
process.env.PORT = '3001';
process.env.DATABASE_URL = 'postgresql://test:test@localhost:5432/provas_test';
process.env.JWT_SECRET = 'test-jwt-secret';
process.env.RABBITMQ_URL = 'amqp://localhost:5672';

// Configurações de timeout globais
global.TEST_TIMEOUTS = {
  QUICK: 1000,
  NORMAL: 5000,
  SLOW: 10000,
  ASYNC_TIMEOUT: 15000
};

// Helper functions para testes
global.createMockProva = (overrides = {}) => ({
  id: 'prova-123',
  titulo: 'Prova de Matemática',
  descricao: 'Prova sobre álgebra linear',
  data: new Date('2024-12-25T10:00:00Z'),
  horario: new Date('2024-12-25T10:00:00Z'),
  local: 'Sala 101',
  materiaId: 'materia-456',
  materias: [],
  filtros: null,
  createdAt: new Date(),
  updatedAt: new Date(),
  ...overrides
});

global.createMockSessaoEstudo = (overrides = {}) => ({
  id: 'sessao-123',
  materiaId: 'materia-456',
  provaId: 'prova-123',
  conteudo: 'Álgebra Linear',
  topicos: ['Matrizes', 'Determinantes'],
  tempoInicio: new Date(),
  tempoFim: null,
  isAgendada: false,
  horarioAgendado: null,
  metaTempo: 60,
  questoesAcertadas: 0,
  totalQuestoes: 0,
  finalizada: false,
  createdAt: new Date(),
  updatedAt: new Date(),
  ...overrides
});

global.createMockMateria = (overrides = {}) => ({
  id: 'materia-123',
  nome: 'Matemática',
  disciplina: 'Exatas',
  createdAt: new Date(),
  updatedAt: new Date(),
  ...overrides
});

// Importando jest globals
import { jest } from '@jest/globals';
global.jest = jest;

global.createMockRepository = () => ({
  create: jest.fn(),
  findById: jest.fn(),
  findAll: jest.fn(),
  update: jest.fn(),
  delete: jest.fn(),
  findByUserId: jest.fn()
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