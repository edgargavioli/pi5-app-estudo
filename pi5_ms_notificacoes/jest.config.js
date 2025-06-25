export default {
  // Configuração para Node.js com ESM
  testEnvironment: 'node',
  
  // Padrões de arquivos de teste
  testMatch: [
    '**/tests/**/*.test.js'
  ],
  
  // Arquivos para coleta de cobertura
  collectCoverageFrom: [
    'src/**/*.js',
    '!src/swagger.js',
    '!src/server.js',
    '!src/config/**',
    '!src/infrastructure/persistence/prisma/**'
  ],
  
  // Configuração de cobertura
  coverageDirectory: 'coverage',
  coverageReporters: ['text', 'lcov', 'html'],
  
  // Setup e teardown
  setupFilesAfterEnv: ['<rootDir>/tests/setup.js'],
  
  // Configurações de timeout
  testTimeout: 10000,
  
  // Configurações para mocking
  clearMocks: true,
  restoreMocks: true,
  resetMocks: true,
  
  // Configurações de verbose
  verbose: true
}; 