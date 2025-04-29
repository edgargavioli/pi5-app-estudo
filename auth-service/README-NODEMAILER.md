# Configuração do Nodemailer com Gmail

Este documento explica como configurar corretamente o serviço de email do auth-service usando o Gmail como provedor SMTP.

## Pré-requisitos

Para usar o Gmail como servidor SMTP para envio de emails, você precisará:

1. Uma conta Gmail
2. Verificação em duas etapas ativada na sua conta Google
3. Uma senha de app específica (não use sua senha normal do Gmail)

## Passos para Configuração

### 1. Ativar a Verificação em Duas Etapas (Obrigatório)

1. Acesse sua conta Google em [https://myaccount.google.com](https://myaccount.google.com)
2. Navegue até a seção "Segurança"
3. Em "Como fazer login no Google", selecione "Verificação em duas etapas"
4. Siga as instruções para ativar a verificação em duas etapas
5. Você precisará de um smartphone para completar a configuração

### 2. Criar uma Senha de App (Obrigatório)

Após ativar a verificação em duas etapas:

1. Acesse sua conta Google em [https://myaccount.google.com/security](https://myaccount.google.com/security)
2. Role para baixo até encontrar "Senhas de app" e clique nela
3. Na seção "Selecionar app", escolha "Outro (Nome personalizado)"
4. Digite um nome descritivo como "Auth Service"
5. Clique em "Gerar"
6. **IMPORTANTE**: Uma senha de 16 caracteres será gerada. Copie essa senha imediatamente, pois ela só será mostrada uma vez.
7. Esta senha gerada deve ser usada no arquivo .env (SMTP_PASS)

### 3. Configurar as Variáveis de Ambiente

Edite o arquivo `.env` na raiz do projeto:

```
# Email
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=seu.email@gmail.com
SMTP_PASS=senha_de_app_de_16_caracteres
EMAIL_FROM=seu.email@gmail.com
APP_URL=http://localhost:3000
```

⚠️ **IMPORTANTE**:
- `senha_de_app_de_16_caracteres` deve ser a senha gerada no passo 2, não sua senha normal do Gmail
- A senha de app não possui espaços, mesmo que na interface do Google ela seja mostrada com espaços
- A senha de app tem exatamente 16 caracteres

### 4. Modificações no Código (Já Implementadas)

O código já foi atualizado para usar configurações mais simples e robustas:

```javascript
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.SMTP_USER,
    pass: process.env.SMTP_PASS
  },
  tls: {
    rejectUnauthorized: false // Ajuda com certificados em desenvolvimento
  }
});
```

### 5. Configurar o Docker Compose (se estiver usando)

Se estiver usando Docker, edite o arquivo `docker-compose.yml`:

```yaml
environment:
  # ... outras variáveis ...
  - SMTP_HOST=smtp.gmail.com
  - SMTP_PORT=587
  - SMTP_USER=seu.email@gmail.com
  - SMTP_PASS=senha_de_app_de_16_caracteres
  - EMAIL_FROM=seu.email@gmail.com
  - APP_URL=http://localhost:3000
  # ... outras variáveis ...
```

## Solução de Problemas Comuns

### "Invalid login: 535-5.7.8 Username and Password not accepted"

Este é o erro mais comum. Ele acontece quando:

1. **Você não está usando uma senha de app**: Utilize APENAS senhas de app, nunca sua senha normal do Gmail
2. **Verificação em duas etapas não ativada**: A verificação em duas etapas DEVE estar ativada para usar senhas de app
3. **Senha copiada incorretamente**: Certifique-se de copiar a senha de app corretamente (16 caracteres sem espaços)
4. **Senha expirada**: Senhas de app raramente expiram, mas se necessário, crie uma nova
5. **Cache de senha**: Tente recriar a senha de app, apagar a antiga e configurar a nova

### "Erro de certificado" ou "self signed certificate"

Isso já deve estar resolvido com a configuração `tls.rejectUnauthorized: false`, mas caso ocorra:

1. **Em produção**: Remova a opção `tls.rejectUnauthorized: false` para manter a segurança
2. **Em desenvolvimento**: Mantenha essa opção para evitar problemas com certificados

### "Error: connect ETIMEDOUT"

Ocorre quando há problemas de rede ou firewall:

1. **Firewall**: Verifique se seu ambiente permite conexões de saída na porta 587
2. **Proxy**: Se estiver atrás de um proxy, configure-o corretamente
3. **Rate limiting**: O Gmail pode estar temporariamente bloqueando sua conexão. Aguarde um pouco

## Teste Final

Após configurar tudo corretamente:

1. Reinicie o servidor: `docker-compose down && docker-compose up -d`
2. Registre um novo usuário e verifique se o email de verificação é enviado
3. Verifique os logs do servidor para confirmar o envio do email

## Limitações do Gmail

- Contas Gmail pessoais: máximo de 500 emails por dia
- Contas Google Workspace: entre 2.000 e 10.000 emails por dia (dependendo do plano)

Para ambientes de produção com volume maior, considere serviços como SendGrid, Mailgun ou Amazon SES.

## Recursos Adicionais

- [Documentação oficial do Nodemailer](https://nodemailer.com/about/)
- [Configuração do Gmail com Nodemailer](https://nodemailer.com/usage/using-gmail/)
- [Senhas de app do Google](https://support.google.com/accounts/answer/185833) 