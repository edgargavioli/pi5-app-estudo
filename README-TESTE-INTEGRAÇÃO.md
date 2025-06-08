# 🧪 TESTE DA INTEGRAÇÃO FLUTTER + USER-SERVICE + PI5_MS_PROVAS

## 🚀 COMO TESTAR A INTEGRAÇÃO COMPLETA

### **PASSO 1: Inicializar os Serviços**

```bash
# Terminal 1 - RabbitMQ (se não estiver rodando)
docker run -d --name rabbitmq -p 5672:5672 -p 15672:15672 \
  -e RABBITMQ_DEFAULT_USER=admin \
  -e RABBITMQ_DEFAULT_PASS=admin123 \
  rabbitmq:3.12-management

# Terminal 2 - User Service
cd user-service
npm run dev

# Terminal 3 - PI5 MS Provas
cd pi5_ms_provas
npm run dev

# Terminal 4 - Flutter
cd pi5_ms_mobile
flutter run
```

### **PASSO 2: Testar Endpoints do User Service**

```bash
# 🔐 TESTE 1: Registro de usuário
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Teste User",
    "email": "teste@exemplo.com", 
    "password": "MinhaSenh@123"
  }'

# 🔐 TESTE 2: Login
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "teste@exemplo.com",
    "password": "MinhaSenh@123"
  }'

# (Copiar o accessToken da resposta)

# 🔐 TESTE 3: Validar Token
curl -X GET http://localhost:3000/api/auth/validate \
  -H "Authorization: Bearer SEU_ACCESS_TOKEN_AQUI"

# 🔐 TESTE 4: Teste PI5_MS_PROVAS com JWT
curl -X GET http://localhost:3001/materias \
  -H "Authorization: Bearer SEU_ACCESS_TOKEN_AQUI"
```

### **PASSO 3: Testar no Flutter**

1. **Abrir app Flutter**
2. **Fazer registro:**
   - Nome: Teste User
   - Email: flutter@teste.com  
   - Senha: MinhaSenh@123

3. **Fazer login:**
   - Email: flutter@teste.com
   - Senha: MinhaSenh@123

4. **Verificar se:**
   - ✅ Login funciona
   - ✅ Redirecionamento para home
   - ✅ Token salvo localmente
   - ✅ APIs funcionam com autenticação

### **PASSO 4: Testar RabbitMQ + Gamificação**

```bash
# Acessar RabbitMQ Management
# http://localhost:15672 (admin/admin123)

# Criar sessão de estudo (deve gerar evento)
curl -X POST http://localhost:3001/sessoes \
  -H "Authorization: Bearer SEU_ACCESS_TOKEN_AQUI" \
  -H "Content-Type: application/json" \
  -d '{
    "materiaId": "uuid-da-materia",
    "conteudo": "Matemática - Álgebra",
    "topicos": ["equações", "funções"]
  }'
```

### **PASSO 5: Verificar Logs**

```bash
# User Service logs
tail -f user-service/logs/

# PI5 MS Provas logs  
tail -f pi5_ms_provas/logs/

# RabbitMQ Management
# http://localhost:15672 > Queues > Ver mensagens
```

## 🎯 RESULTADOS ESPERADOS

### **✅ CENÁRIO DE SUCESSO**

1. **User Service:**
   - ✅ Registro funciona
   - ✅ Login retorna JWT
   - ✅ Validate endpoint funciona
   - ✅ Refresh token funciona

2. **PI5 MS Provas:**
   - ✅ Rejeita requests sem token
   - ✅ Aceita requests com token válido
   - ✅ Filtra dados por userId
   - ✅ Publica eventos no RabbitMQ

3. **Flutter:**
   - ✅ Login/registro funcional
   - ✅ Navegação protegida
   - ✅ APIs funcionam automaticamente
   - ✅ Tokens renovam automaticamente

4. **RabbitMQ:**
   - ✅ Eventos são publicados
   - ✅ User-service consome eventos
   - ✅ Gamificação automática funciona

## 🚨 TROUBLESHOOTING

### **❌ Erro: "Token JWT requerido"**
- Verificar se AuthService está inicializado
- Verificar se token está sendo enviado nos headers

### **❌ Erro: "CORS"**  
- Verificar configuração CORS nos backends
- Adicionar localhost:* nas whitelist

### **❌ Erro: "Conexão recusada"**
- Verificar se todos os serviços estão rodando
- Verificar portas corretas (3000, 3001, 5672)

### **❌ Flutter não conecta**
- Usar IP da máquina em vez de localhost
- Para Android: usar 10.0.2.2:3000

## 📋 CHECKLIST FINAL

- [ ] User Service rodando (porta 3000)
- [ ] PI5 MS Provas rodando (porta 3001)  
- [ ] RabbitMQ rodando (porta 5672)
- [ ] PostgreSQL rodando (portas 5432, 5433)
- [ ] Flutter app rodando
- [ ] Registro de usuário funciona
- [ ] Login funciona
- [ ] JWT validation funciona
- [ ] APIs protegidas funcionam
- [ ] RabbitMQ recebe eventos
- [ ] Gamificação automática funciona

**🎯 Se todos os checkboxes estão marcados, a integração está COMPLETA!** 