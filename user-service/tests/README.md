# 🧪 Testes Unitários - User Service

Este diretório contém os testes unitários para o microserviço `user-service`, seguindo a arquitetura Domain-Driven Design (DDD).

## 🏗️ **Estrutura dos Testes**

### **Suíte 1: Domain Layer** (`domain.test.js`)
Testa a **camada de domínio** - lógica de negócio pura:

#### 📋 **User Entity** (9 testes)
- ✅ Criação de usuário com dados válidos
- ❌ Validações de email inválido
- ❌ Validações de nome muito curto
- ❌ Validações de pontos negativos
- 🔄 Verificação de email
- 🕒 Atualização de último login
- 🔒 Serialização segura (sem dados sensíveis)
- 🛡️ Permissões de atualização de perfil

#### 🔒 **Password Value Object** (7 testes)
- ✅ Criação de senha válida
- ❌ Validações de requisitos de senha:
  - Comprimento mínimo
  - Letra maiúscula
  - Letra minúscula
  - Número
  - Caractere especial
- 🔐 Hash de senha
- 🔄 Criação a partir de hash

#### 📧 **Email Value Object** (4 testes)
- ✅ Criação e normalização de email
- ❌ Validações de formato
- 🔍 Extração de domínio e parte local
- ⚖️ Comparação de emails

### **Suíte 2: Application Layer** (`application.test.js`)
Testa a **camada de aplicação** - casos de uso e orquestração:

#### 👤 **GetUserUseCase** (4 testes)
- ✅ Retorno de usuário autorizado
- 🚫 Bloqueio de acesso não autorizado
- ❌ Tratamento de usuário não encontrado
- 🔄 Propagação de erros do repositório

#### ✏️ **UpdateUserUseCase** (7 testes)
- ✅ Atualização com dados válidos
- 🚫 Bloqueio de atualização não autorizada
- ❌ Tratamento de usuário não encontrado
- 📧 Verificação de email já em uso
- 🔐 Hash de senha na atualização
- ❌ Validações de email e senha inválidos
- 🕒 Atualização de timestamps

## 🛠️ **Configuração de Testes**

### **Setup Global** (`setup.js`)
- **Mocks**: Prisma, bcrypt, JWT, nodemailer, winston
- **Variáveis de ambiente** isoladas para testes
- **Utilitários globais**: `createMockUser()`, `createMockPrismaUser()`
- **Limpeza automática** de mocks entre testes

### **Jest Config** (`jest.config.js`)
- **Ambiente**: Node.js
- **Timeout**: 10 segundos
- **Cobertura**: HTML, LCOV, Text reports
- **Metas de qualidade** configuradas

## 🚀 **Como Executar**

### **Todos os testes:**
```bash
npm test
```

### **Com cobertura:**
```bash
npm run test:coverage
```

### **Modo watch:**
```bash
npm run test:watch
```

### **Teste específico:**
```bash
npm test -- domain.test.js
npm test -- application.test.js
```

## 📋 **Mocks Utilizados**

### **Prisma Client**
- Todas as operações CRUD mockadas
- Tabelas: `user`, `pointsTransaction`, `studyStreak`

### **Bibliotecas Externas**
- **bcrypt**: Hash e comparação de senhas
- **jsonwebtoken**: Geração e verificação de tokens
- **nodemailer**: Envio de emails
- **winston**: Sistema de logging

## 🎯 **Cenários Testados**

### **✅ Casos de Sucesso**
- Operações normais do sistema
- Fluxos esperados de uso
- Validações corretas

### **❌ Casos de Erro**
- Dados inválidos
- Usuários não encontrados
- Tentativas não autorizadas
- Emails duplicados

### **🔒 Segurança**
- Autorização de acesso
- Sanitização de dados
- Hash de senhas
- Validações de entrada

## 📊 **Cobertura Esperada**

| Componente | Cobertura Alvo |
|------------|----------------|
| **User Entity** | 95%+ |
| **Value Objects** | 90%+ |
| **Use Cases** | 85%+ |
| **Validações** | 100% |

## 📝 **Padrões Seguidos**

- **AAA Pattern**: Arrange, Act, Assert
- **Mocks isolados**: Sem dependências externas
- **Testes unitários**: Focados em uma unidade por vez
- **Nomes descritivos**: O que deve acontecer
- **Setup/Teardown**: Limpeza entre testes

---
