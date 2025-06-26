# 🧪 **Testes Unitários - Microserviço pi5_ms_provas**

## 📊 **Status dos Testes**
- ✅ **35 testes** implementados
- ✅ **3 suítes** organizadas
- ✅ **100% funcionais** (Domain → Use Cases → Infrastructure)
- ✅ **ES Modules** configurado
- ✅ **Mocks otimizados** (Prisma, RabbitMQ)

---

## 🏗️ **Arquitetura Testada**

### **Domain Layer (15 testes)**
```
tests/domain/entities/
├── prova.test.js           (8 testes) - Entidade principal 
├── sessao-estudo.test.js   (5 testes) - Lógica complexa XP/Tempo
└── materia.test.js         (2 testes) - Validações básicas
```

### **Application Layer (12 testes)** 
```
tests/application/use-cases/
└── prova-use-cases.test.js (12 testes) - CRUD completo
    ├── CreateProvaUseCase   (4 testes)
    ├── GetProvaUseCase      (2 testes) 
    ├── UpdateProvaUseCase   (3 testes)
    └── DeleteProvaUseCase   (3 testes)
```

### **Infrastructure Layer (8 testes)**
```
tests/infrastructure/
└── infrastructure.test.js  (8 testes) - Repository & Messaging
    ├── ProvaRepository      (4 testes)
    ├── RabbitMQ Mocking     (2 testes)
    └── Error Handling       (2 testes)
```

---

## 🎯 **Funcionalidades Testadas**

### **🔹 Prova Entity (8 testes)**
- Constructor com todas as propriedades
- Parâmetros opcionais (null handling)
- Factory method `create()` 
- Validações obrigatórias (título, data, horário, local)
- Método `update()` com preservação de campos
- Edge cases (local vazio, trimming)

### **🔹 SessaoEstudo Entity (5 testes)**
- **Cálculo de Duração**: tempo real de estudo
- **Sistema de Progresso**: % baseado em meta de tempo
- **Sistema de XP Inteligente**:
  - 100%+ progresso → **1.5x XP bonus**
  - 80-99% progresso → **XP normal**
  - <80% progresso → **XP proporcional**

### **🔹 Materia Entity (2 testes)**
- Factory method com validação
- Error handling para campos obrigatórios

### **🔹 Use Cases (12 testes)**
- **CREATE**: Validação de userId, matéria ownership, relacionamentos
- **READ**: Busca por ID e listagem por usuário
- **UPDATE**: Preservação de ownership, validações
- **DELETE**: Segurança de ownership, casos de erro

### **🔹 Infrastructure (8 testes)**
- **ProvaRepository**: CRUD com Prisma, relacionamentos many-to-many
- **RabbitMQ**: Connection mocking, message publishing
- **Error Handling**: Database failures, not found scenarios

---

## ⚙️ **Configuração Técnica**

### **Jest + ES Modules**
```javascript
// jest.config.js
export default {
  testEnvironment: 'node',
  testMatch: ['**/tests/**/*.test.js'],
  setupFilesAfterEnv: ['<rootDir>/tests/setup.js']
};
```

### **Helper Functions Globais**
```javascript
global.createMockProva()        // Prova mock completa
global.createMockSessaoEstudo() // Sessão com XP/tempo
global.createMockMateria()      // Matéria básica
global.createMockRepository()   // Repository mock
global.waitFor(ms)              // Async utilities
global.mockTimers()             // Jest timers
```

### **Mocks Otimizados**
```javascript
// Prisma Client
const mockPrisma = {
  prova: { create, findUnique, findMany, update, delete },
  provaMateria: { createMany, deleteMany }
};

// RabbitMQ (amqplib)
const mockAmqp = {
  connect, createChannel, assertExchange, publish
};
```

---

## 🚀 **Comandos de Execução**

### **Executar Todos os Testes**
```bash
npm test
```

### **Modo Watch (Desenvolvimento)**
```bash
npm run test:watch
```

### **Cobertura de Código**
```bash
npm run test:coverage
```

### **Executar Suíte Específica**
```bash
# Domain entities apenas
npm test -- tests/domain

# Use cases apenas  
npm test -- tests/application

# Infrastructure apenas
npm test -- tests/infrastructure
```

---

## 📈 **Métricas de Qualidade**

### **Distribuição de Testes**
- **Domain**: 15/35 (43%) - Lógica de negócio core
- **Application**: 12/35 (34%) - Casos de uso críticos  
- **Infrastructure**: 8/35 (23%) - Persistência & messaging

### **Cobertura Esperada**
- **Entities**: ~95% (lógica crítica)
- **Use Cases**: ~90% (fluxos principais)
- **Repositories**: ~80% (operações CRUD)

### **Timeout Configurações**
- **Testes rápidos**: 1s (entities, validações)
- **Testes normais**: 5s (use cases)
- **Testes lentos**: 10s (async operations)

---

## 🔧 **Troubleshooting**

### **ES Modules Issues**
```bash
# Error: Cannot use import statement outside a module
# Fix: Verificar type: "module" em package.json
```

### **Prisma Mock Errors**
```bash
# Error: Cannot read property 'create' of undefined
# Fix: Verificar jest.unstable_mockModule() antes do import
```

### **Async/Await Issues**
```bash
# Error: Test timeout
# Fix: Usar await corretamente e ajustar timeout
```

---

## 🎖️ **Padrões de Qualidade**

### **Naming Convention**
- `should + action + condition` (em inglês)
- Descritivo e específico
- Foco no comportamento, não implementação

### **Test Structure (AAA)**
```javascript
test('should create prova successfully', async () => {
  // ARRANGE - Preparar dados e mocks
  const mockData = createMockProva();
  
  // ACT - Executar ação
  const result = await useCase.execute(mockData);
  
  // ASSERT - Verificar resultado
  expect(result.id).toBeDefined();
});
```

### **Mock Strategy**
- **Unit Level**: Mock dependencies, test isolation
- **Integration Level**: Real objects interaction
- **No E2E**: Focus on unit + integration testing

---

## 📝 **Próximos Passos**

### **Expansão Futura (se necessário)**
1. **Performance Tests**: Stress testing repository operations
2. **Integration Tests**: Real database scenarios
3. **Contract Tests**: API endpoint validation
4. **E2E Tests**: Full user journey simulation

### **Melhorias Contínuas**
1. **Snapshot Testing**: UI components (se houver)
2. **Property-Based Testing**: Edge cases automáticos
3. **Mutation Testing**: Qualidade dos testes
4. **Benchmarking**: Performance regression detection

---

