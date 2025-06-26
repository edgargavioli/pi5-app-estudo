module.exports = {
  // Ambiente de teste
  testEnvironment: 'node',
  
  // Configuração de setup
  setupFilesAfterEnv: ['<rootDir>/tests/setup.js'],
  
  // Padrões de arquivos de teste
  testMatch: [
    '**/tests/**/*.test.js',
    '**/__tests__/**/*.js'
  ],
  
  // Arquivos para análise de cobertura
  collectCoverageFrom: [
    'src/domain/**/*.js',
    'src/application/**/*.js',
    '!src/server.js',
    '!src/**/index.js',
    '!**/node_modules/**',
    '!**/*_backup.js',
    '!**/*_fixed.js'
  ],
  
  // Configuração de cobertura
  coverageDirectory: 'coverage',
  coverageReporters: ['text', 'lcov', 'html'],
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 55,
      lines: 65,
      statements: 65
    }
  },
  
  // Timeout para testes
  testTimeout: 10000,
  
  // Transformações
  transform: {},
  
  // Verbose output
  verbose: true,
  
  // Limpar mocks entre testes
  clearMocks: true,
  restoreMocks: true
}; 