# Auth Service

Serviço de autenticação seguindo a arquitetura DDD (Domain-Driven Design) implementado com Node.js e Express.

## Funcionalidades

- Registro de usuários
- Autenticação com JWT (access token e refresh token)
- Verificação de email
- Recuperação de senha
- Alteração de senha
- Bloqueio/desbloqueio de conta
- Limitação de tentativas de login

## Tecnologias Utilizadas

- Node.js e Express
- PostgreSQL (banco de dados)
- RabbitMQ (mensageria)
- JWT (autenticação)
- bcrypt (criptografia de senhas)
- Docker e Docker Compose

## Estrutura do Projeto

O projeto segue a arquitetura DDD:

- **domain**: Entidades e lógicas do domínio
  - **entities**: Entidades de domínio (ex: User)
  - **repositories**: Interfaces de repositórios

- **application**: Casos de uso
  - **useCases**: Implementação dos casos de uso

- **infrastructure**: Infraestrutura
  - **database**: Implementação dos repositórios
  - **rabbitmq**: Serviço de mensageria
  - **jwt**: Serviço de JWT
  - **email**: Serviço de email

- **interfaces**: Interface com o usuário
  - **controllers**: Controladores das requisições
  - **routes**: Definição das rotas
  - **middlewares**: Middlewares da aplicação

- **config**: Arquivos de configuração

## Instalação e Execução

### Pré-requisitos

- Node.js (v14+)
- Docker e Docker Compose

### Usando Docker

1. Clone o repositório
```bash
git clone [URL_DO_REPOSITORIO]
cd auth-service
```

2. Inicie os containers usando Docker Compose
```bash
docker-compose up -d
```

3. O serviço estará disponível em `http://localhost:3000`

### Desenvolvimento Local

1. Clone o repositório
```bash
git clone [URL_DO_REPOSITORIO]
cd auth-service
```

2. Instale as dependências
```bash
npm install
```

3. Configure as variáveis de ambiente
```bash
cp .env.example .env
# Edite o arquivo .env com suas configurações
```

4. Inicie o PostgreSQL e RabbitMQ (pode usar Docker Compose)
```bash
docker-compose up -d postgres rabbitmq
```

5. Inicie o servidor em modo de desenvolvimento
```bash
npm run dev
```

## API Endpoints

### Autenticação

- `POST /api/auth/register` - Registrar novo usuário
- `POST /api/auth/login` - Autenticar usuário
- `POST /api/auth/refresh-token` - Atualizar token de acesso
- `POST /api/auth/logout` - Logout
- `POST /api/auth/recover-password` - Solicitar recuperação de senha
- `POST /api/auth/reset-password` - Resetar senha com token
- `GET /api/auth/verify-email` - Verificar email
- `PUT /api/auth/change-password` - Alterar senha (autenticado)

### Admin

- `PUT /api/auth/block-account` - Bloquear conta (requer admin)
- `PUT /api/auth/unblock-account` - Desbloquear conta (requer admin)

## Licença

Este projeto está licenciado sob a licença MIT.
