# Testes Unitários - Microserviço de Notificações

Este diretório contém os testes unitários para o microserviço `pi5_ms_notificacoes` utilizando Jest com suporte a ES Modules.

## 📋 Estrutura dos Testes

```
tests/
├── setup.js                           # Configuração global dos testes
├── domain/
│   └── entities/
│       ├── notification.test.js       # Testes da entidade Notification (29 testes)
│       └── user.test.js               # Testes da entidade User (18 testes)
└── infrastructure/
    └── persistence/
        └── notification.test.js       # Testes de persistência (7 testes)
```

## ✅ Status dos Testes

**Resultado Atual:** 
- ✅ **3 suites passaram** completamente
- ✅ **54 testes passaram** de 54 totais  


## 🚀 Como Executar os Testes

### Pré-requisitos

Certifique-se de ter as dependências do Jest instaladas:

```bash
npm install
```

### Comandos Disponíveis

#### Executar todos os testes
```bash
npm test
```

#### Executar testes em modo watch
```bash
npm run test:watch
```

#### Executar testes com relatório de cobertura
```bash
npm run test:coverage
```

#### Executar testes específicos
```bash
# Testes de uma categoria específica
npm test -- tests/domain/
npm test -- tests/infrastructure/

# Teste de um arquivo específico
npm test -- tests/domain/entities/notification.test.js

# Testes com pattern específico
npm test -- --testNamePattern="should generate"
```

### Configuração ES Modules

Os testes utilizam ES Modules nativamente:
- ✅ Jest configurado com `--experimental-vm-modules`
- ✅ Imports ES6 funcionando corretamente
- ✅ Mocks modernos com `jest.unstable_mockModule`

## 🧪 O que é Testado

### 1. Entidades de Domínio (47 testes)

#### Notification Entity (29 testes)
- ✅ **Constructor**: Criação com propriedades completas e status padrão
- ✅ **generateContent**: 15+ tipos de notificação:
  - Eventos: `EVENTO_CRIADO`, `EVENTO_LEMBRETE_3_DIAS`, `EVENTO_DIA`
  - Provas: `PROVA_CRIADA`, `PROVA_LEMBRETE_1_SEMANA`, `PROVA_DIA`, `PROVA_1_HORA`
  - Sessões: `SESSAO_CRIADA`, `SESSAO_INICIADA`, `SESSAO_LEMBRETE`
  - Streaks: `STREAK_WARNING`, `STREAK_EXPIRED`
  - Legacy: `EVENT_REMINDER`, `EXAM_CREATED`
- ✅ **Helper Methods**: `getDaysDifference`, `getHoursUntilMidnight`
- ✅ **Serialization**: `fromJson`, `toJson`, integridade de dados
- ✅ **Edge Cases**: Dados ausentes, nulos, caracteres especiais

#### User Entity (18 testes)
- ✅ **Constructor**: Criação com diferentes tipos de FCM token
- ✅ **Serialization**: Ciclo completo de serialização/deserialização
- ✅ **fromJson/toJson**: Conversão de/para JSON
- ✅ **Edge Cases**: Caracteres especiais, strings longas, Unicode
- ✅ **Type Safety**: Preservação de tipos após conversões

### 2. Infraestrutura de Persistência (7 testes)

#### NotificationPersistence (7 testes)
- ✅ **Constructor**: Inicialização com Prisma client
- ✅ **findPendingNotifications**: Busca notificações pendentes com filtros
- ✅ **updateStatus**: Atualização de status com timestamp
- ✅ **create**: Criação de novas notificações
- ✅ **Error Handling**: Tratamento de erros de banco de dados

## 🔧 Configuração dos Mocks

### Dependências Mockadas
- **Prisma Client**: Mock completo com `$connect`, `$disconnect`
- **Notification Entity**: Factory methods e serialização

### Utilitários Globais
- `createMockNotification()`: Cria notificações mock para testes
- `createMockUser()`: Cria usuários mock para testes
- `createMockChannel()`: Cria canais RabbitMQ mock
- `waitFor()`: Utilitário para aguardar operações assíncronas
- `waitForCondition()`: Aguarda condições específicas
- `mockTimers()`: Controle de timers em testes

## 📊 Cobertura de Código

Configuração de cobertura para arquivos relevantes:

```javascript
collectCoverageFrom: [
  'src/**/*.js',
  '!src/swagger.js',
  '!src/server.js', 
  '!src/config/**',
  '!src/infrastructure/persistence/prisma/**'
]
```

### Visualizar Relatório
```bash
npm run test:coverage
# Abre: coverage/lcov-report/index.html
```

## 📋 Cenários de Teste Cobertos

### ✅ Casos de Sucesso
- Operações normais de CRUD
- Geração de conteúdo para todos os tipos de notificação
- Serialização/deserialização de entidades
- Fluxos completos de persistência

### ❌ Casos de Erro
- Falhas de conexão com banco de dados
- Erros de serialização
- Dados inválidos ou malformados
- Timeouts e operações rejeitadas

### ⚠️ Casos Extremos
- Valores nulos e indefinidos
- Strings muito longas
- Caracteres especiais e Unicode
- Dados ausentes em entityData

## 🎯 Funcionalidades Específicas Testadas

### Tipos de Notificação
- **Eventos**: Criação, lembretes (3 dias), dia do evento
- **Provas**: Criação, lembretes (1 semana, 3 dias, 1 dia), dia da prova, 1 hora antes
- **Sessões**: Criação, início, lembretes
- **Streaks**: Avisos de expiração, notificação de perda
- **Legacy**: Compatibilidade com tipos antigos

### Contextos Inteligentes
- Formatação de datas brasileiras (DD/MM/YYYY)
- Horários localizados (timezone brasileiro)
- Emojis contextuais para cada tipo
- Mensagens personalizadas por matéria

## 🔍 Troubleshooting

### Erro: ES Module issues
```bash
# Certifique-se de que o comando correto está sendo usado
npm test
# Que executa: node --experimental-vm-modules ./node_modules/jest/bin/jest.js
```

### Timeout em testes
```bash
# Configurado para 10 segundos por padrão
# Ajuste em jest.config.js se necessário
```

### Problemas de encoding (emojis)
- Testes ajustados para usar `.toContain()` em vez de `.toBe()` para emojis
- Compatibilidade com diferentes sistemas de encoding

## 🚀 Melhorias Implementadas

### Otimizações Realizadas
1. ✅ Configuração ES Modules nativa
2. ✅ Mocks simplificados e funcionais
3. ✅ Correção de problemas de timezone
4. ✅ Ajuste de expectativas para emojis
5. ✅ Isolamento completo entre testes

### Configuração Final
- **Jest**: ES Modules com `--experimental-vm-modules`
- **Timeout**: 10 segundos por teste
- **Coverage**: HTML, LCOV, JSON
- **Mocks**: Prisma, entidades, utilitários globais

