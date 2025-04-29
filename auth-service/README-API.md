# Documentação da API do Auth Service

Este documento descreve todas as rotas disponíveis no serviço de autenticação, incluindo os parâmetros necessários para cada requisição e exemplos de uso.

## Base URL

```
http://localhost:3000/api/auth
```

## Endpoints Públicos

### Registro de Usuário

**Endpoint:** `POST /register`

**Body:**
```json
{
  "email": "usuario@exemplo.com",
  "password": "Senha123!"
}
```

**Resposta de Sucesso (201):**
```json
{
  "success": true,
  "message": "Usuário registrado com sucesso",
  "data": {
    "user": {
      "id": "a1b2c3d4-e5f6-g7h8-i9j0-k1l2m3n4o5p6",
      "email": "usuario@exemplo.com",
      "status": "pending",
      "loginAttempts": 0,
      "lockedUntil": null,
      "createdAt": "2023-05-15T10:30:00.000Z",
      "updatedAt": "2023-05-15T10:30:00.000Z"
    },
    "tokens": {
      "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
    }
  }
}
```

**Possíveis Erros:**
- 400: Email ou senha inválidos
- 409: Email já está em uso

### Login

**Endpoint:** `POST /login`

**Body:**
```json
{
  "email": "usuario@exemplo.com",
  "password": "Senha123!"
}
```

**Resposta de Sucesso (200):**
```json
{
  "success": true,
  "message": "Login realizado com sucesso",
  "data": {
    "user": {
      "id": "a1b2c3d4-e5f6-g7h8-i9j0-k1l2m3n4o5p6",
      "email": "usuario@exemplo.com",
      "status": "verified",
      "loginAttempts": 0,
      "lockedUntil": null,
      "createdAt": "2023-05-15T10:30:00.000Z",
      "updatedAt": "2023-05-15T10:30:00.000Z"
    },
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

**Possíveis Erros:**
- 400: Email ou senha não fornecidos
- 401: Credenciais inválidas
- 403: Conta bloqueada ou email não verificado

### Atualizar Token de Acesso

**Endpoint:** `POST /refresh-token`

**Body:**
```json
{
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Alternativa:** O token também pode ser enviado como cookie HTTP.

**Resposta de Sucesso (200):**
```json
{
  "success": true,
  "message": "Token atualizado com sucesso",
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

**Possíveis Erros:**
- 400: Refresh token não fornecido
- 401: Refresh token inválido ou expirado

### Recuperação de Senha

**Endpoint:** `POST /recover-password`

**Body:**
```json
{
  "email": "usuario@exemplo.com"
}
```

**Resposta de Sucesso (200):**
```json
{
  "success": true,
  "message": "Se o email existir, um link de recuperação de senha será enviado"
}
```

### Redefinição de Senha

**Endpoint:** `POST /reset-password`

**Body:**
```json
{
  "token": "f8a7s6d5f7a6sd5f7a6s5df76as5df7",
  "newPassword": "NovaSenha123!"
}
```

**Resposta de Sucesso (200):**
```json
{
  "success": true,
  "message": "Senha redefinida com sucesso"
}
```

**Possíveis Erros:**
- 400: Token ou nova senha não fornecidos, token inválido ou formato de senha inválido

### Verificação de Email

**Endpoint:** `GET /verify-email?token=[TOKEN]`

**Query Parameter:**
- `token`: Token de verificação recebido por email

**Resposta de Sucesso (200):**
```json
{
  "success": true,
  "message": "Email verificado com sucesso"
}
```

**Possíveis Erros:**
- 400: Token não fornecido ou token inválido

## Endpoints Protegidos (Requerem Autenticação)

Para estas rotas, é necessário incluir o header de autenticação:
```
Authorization: Bearer [ACCESS_TOKEN]
```

### Logout

**Endpoint:** `POST /logout`

**Body:** Não necessário

**Resposta de Sucesso (200):**
```json
{
  "success": true,
  "message": "Logout realizado com sucesso"
}
```

### Alteração de Senha

**Endpoint:** `PUT /change-password`

**Body:**
```json
{
  "currentPassword": "Senha123!",
  "newPassword": "NovaSenha123!"
}
```

**Resposta de Sucesso (200):**
```json
{
  "success": true,
  "message": "Senha alterada com sucesso",
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

**Possíveis Erros:**
- 400: Senhas não fornecidas ou formato de senha inválido
- 401: Senha atual incorreta

## Endpoints de Administrador (Requerem Autenticação de Admin)

Para estas rotas, é necessário incluir o header de autenticação de um usuário administrador:
```
Authorization: Bearer [ADMIN_ACCESS_TOKEN]
```

### Bloqueio de Conta

**Endpoint:** `PUT /block-account`

**Body:**
```json
{
  "userId": "a1b2c3d4-e5f6-g7h8-i9j0-k1l2m3n4o5p6",
  "reason": "Violação dos termos de uso"
}
```

**Resposta de Sucesso (200):**
```json
{
  "success": true,
  "message": "Conta bloqueada com sucesso"
}
```

**Possíveis Erros:**
- 400: ID do usuário não fornecido
- 403: Permissão negada (não é admin)
- 404: Usuário não encontrado

### Desbloqueio de Conta

**Endpoint:** `PUT /unblock-account`

**Body:**
```json
{
  "userId": "a1b2c3d4-e5f6-g7h8-i9j0-k1l2m3n4o5p6"
}
```

**Resposta de Sucesso (200):**
```json
{
  "success": true,
  "message": "Conta desbloqueada com sucesso"
}
```

**Possíveis Erros:**
- 400: ID do usuário não fornecido
- 403: Permissão negada (não é admin)
- 404: Usuário não encontrado

## Exemplos de Uso com cURL

### Registrar um usuário:
```bash
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"usuario@exemplo.com", "password":"Senha123!"}'
```

### Login:
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"usuario@exemplo.com", "password":"Senha123!"}'
```

### Atualizar token:
```bash
curl -X POST http://localhost:3000/api/auth/refresh-token \
  -H "Content-Type: application/json" \
  -d '{"refreshToken":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."}'
```

### Solicitar recuperação de senha:
```bash
curl -X POST http://localhost:3000/api/auth/recover-password \
  -H "Content-Type: application/json" \
  -d '{"email":"usuario@exemplo.com"}'
```

### Alterar senha (autenticado):
```bash
curl -X PUT http://localhost:3000/api/auth/change-password \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -d '{"currentPassword":"Senha123!", "newPassword":"NovaSenha123!"}'
```

## Notas sobre Segurança

1. Todas as senhas devem seguir os requisitos mínimos:
   - Mínimo de 8 caracteres
   - Pelo menos uma letra maiúscula
   - Pelo menos uma letra minúscula
   - Pelo menos um número

2. O serviço implementa limitação de tentativas de login:
   - Após 5 tentativas incorretas, a conta é bloqueada temporariamente
   - O tempo de bloqueio padrão é de 30 minutos

3. Os tokens JWT têm os seguintes tempos de expiração:
   - Token de acesso: 15 minutos
   - Token de refresh: 7 dias 