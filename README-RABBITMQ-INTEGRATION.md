# 🐰 RabbitMQ Integration - PI5 Microservices

## 🎯 **ARQUITETURA CRÍTICA DE MENSAGERIA**

Sistema de mensageria assíncrona entre `user-service` e `pi5_ms_provas` usando RabbitMQ como broker central. Esta integração é **FUNDAMENTAL** para o funcionamento do sistema de gamificação.

---

## 📊 **FLUXO DE EVENTOS IMPLEMENTADO**

### **PI5_MS_PROVAS → USER-SERVICE**
```
┌─────────────────┐    📤 Event     ┌─────────────┐    🎮 Process    ┌──────────────┐
│  Sessão Criada  │ ──────────────→ │  RabbitMQ   │ ──────────────→ │ Gamificação  │
└─────────────────┘                 │   Broker    │                 │   +10 XP     │
                                     └─────────────┘                 └──────────────┘

┌─────────────────┐    📤 Event     ┌─────────────┐    🎮 Process    ┌──────────────┐
│ Sessão Finaliz. │ ──────────────→ │  RabbitMQ   │ ──────────────→ │ Gamificação  │
└─────────────────┘                 │   Broker    │                 │ +25 XP +tempo│
                                     └─────────────┘                 └──────────────┘

┌─────────────────┐    📤 Event     ┌─────────────┐    🎮 Process    ┌──────────────┐
│ Prova Finaliz.  │ ──────────────→ │  RabbitMQ   │ ──────────────→ │ Gamificação  │
└─────────────────┘                 │   Broker    │                 │ +50 XP +bonus│
                                     └─────────────┘                 └──────────────┘
```

### **USER-SERVICE → PI5_MS_PROVAS**
```
┌─────────────────┐    📤 Sync      ┌─────────────┐    📥 Update     ┌──────────────┐
│ Pontos Atualiz. │ ──────────────→ │  RabbitMQ   │ ──────────────→ │ Cache Sync   │
└─────────────────┘                 │   Broker    │                 │              │
                                     └─────────────┘                 └──────────────┘
```

---

## 🚀 **COMO INICIALIZAR O SISTEMA**

### **1. Subir todos os serviços**
```bash
# No diretório raiz pi5-app-estudo
docker-compose up --build

# Verificar se todos estão rodando
docker ps
```

### **2. Verificar RabbitMQ Management**
```bash
# Abrir no navegador
http://localhost:15672

# Credenciais
Username: admin
Password: admin123
```

### **3. Monitorar logs em tempo real**
```bash
# User Service
docker logs -f user-service

# Provas Service
docker logs -f provas-service

# RabbitMQ
docker logs -f rabbitmq-broker
```

---

## 🔧 **CONFIGURAÇÃO DOS SERVIÇOS**

### **Variáveis de Ambiente Críticas**
```env
# RabbitMQ Connection (MESMO EM TODOS OS SERVIÇOS)
RABBITMQ_URL=amqp://admin:admin123@rabbitmq:5672/
RABBITMQ_EXCHANGE=pi5_events

# Service Names (ÚNICOS POR SERVIÇO)
SERVICE_NAME=user-service      # Para user-service
SERVICE_NAME=provas-service    # Para pi5_ms_provas
```

### **Portas Configuradas**
- **RabbitMQ AMQP**: `5672`
- **RabbitMQ Management**: `15672`
- **User Service**: `3000`
- **Provas Service**: `3001`
- **PostgreSQL User**: `5432`
- **PostgreSQL Provas**: `5433`

---

## 📋 **EVENTOS IMPLEMENTADOS**

### **1. provas.sessao.criada**
```json
{
  "data": {
    "userId": "user-default",
    "sessaoId": "uuid",
    "materiaId": "uuid",
    "provaId": "uuid",
    "tempoInicio": "2024-01-01T10:00:00Z",
    "conteudo": "string",
    "topicos": ["array"]
  },
  "timestamp": "2024-01-01T10:00:00Z",
  "service": "provas-service",
  "messageId": "unique-id"
}
```

### **2. provas.sessao.finalizada**
```json
{
  "data": {
    "userId": "user-default",
    "sessaoId": "uuid",
    "materiaId": "uuid",
    "provaId": "uuid",
    "tempoEstudo": 45,
    "questoesAcertadas": 8,
    "totalQuestoes": 10
  }
}
```

### **3. provas.prova.finalizada**
```json
{
  "data": {
    "userId": "user-default",
    "provaId": "uuid",
    "materiaId": "uuid",
    "questoesAcertadas": 15,
    "totalQuestoes": 20,
    "percentualAcerto": 75
  }
}
```

---

## 🎮 **REGRAS DE GAMIFICAÇÃO AUTOMÁTICAS**

### **XP por Ação**
- ✅ **Criar Sessão**: +10 XP
- ✅ **Finalizar Sessão**: +25 XP base + (2 XP × minutos estudados)
- ✅ **Questão Acertada**: +5 XP por questão
- ✅ **Finalizar Prova**: +50 XP base

### **Bônus por Desempenho**
- 🏆 **90%+ acertos**: +30 XP bonus
- 🥇 **80-89% acertos**: +20 XP bonus
- 🥈 **70-79% acertos**: +10 XP bonus
- 🥉 **60-69% acertos**: +5 XP bonus

### **Conquistas Automáticas**
- 🎯 **Primeira Sessão**: Automática
- ⏰ **Sessão Longa**: 60+ minutos
- 🎓 **Primeira Prova**: Automática
- 💯 **Nota Perfeita**: 100% acertos
- 📚 **10 Sessões**: Contador automático

---

## 🔍 **TROUBLESHOOTING**

### **Problema: RabbitMQ não conecta**
```bash
# Verificar se container está rodando
docker ps | grep rabbitmq

# Verificar logs
docker logs rabbitmq-broker

# Restart se necessário
docker restart rabbitmq-broker
```

### **Problema: Eventos não são processados**
```bash
# Verificar filas no Management UI
http://localhost:15672/#/queues

# Verificar logs dos serviços
docker logs -f user-service
docker logs -f provas-service

# Verificar conexões ativas
docker exec rabbitmq-broker rabbitmqctl list_connections
```

### **Problema: Dead Letter Queue ativa**
```bash
# Verificar messages na DLQ
http://localhost:15672/#/queues/%2F/user-service.dead_letter

# Reprocessar mensagens manualmente se necessário
# (Implementar tools de recovery se necessário)
```

### **Problema: Performance lenta**
```bash
# Verificar memory usage
docker stats

# Verificar RabbitMQ metrics
http://localhost:15672/#/overview

# Ajustar prefetch se necessário
```

---

## ⚡ **COMANDOS DE EMERGÊNCIA**

### **Reset Completo**
```bash
# Parar tudo
docker-compose down

# Limpar volumes (CUIDADO: apaga dados)
docker-compose down -v

# Rebuild completo
docker-compose up --build --force-recreate
```

### **Restart apenas RabbitMQ**
```bash
docker restart rabbitmq-broker

# Aguardar healthcheck
docker exec rabbitmq-broker rabbitmq-diagnostics -q ping
```

### **Purgar filas específicas**
```bash
# Via CLI
docker exec rabbitmq-broker rabbitmqctl purge_queue user-service.points.updates

# Via Management UI
http://localhost:15672/#/queues (botão "Purge Messages")
```

---

## 📈 **MONITORAMENTO EM PRODUÇÃO**

### **Métricas Importantes**
- ✅ Conexões ativas com RabbitMQ
- ✅ Throughput de mensagens/segundo
- ✅ Dead Letter Queue count
- ✅ Memory usage RabbitMQ
- ✅ Connection recovery time

### **Alertas Críticos**
- 🚨 RabbitMQ down > 30 segundos
- 🚨 Dead Letter Queue > 100 mensagens
- 🚨 Memory usage > 80%
- 🚨 Message processing lag > 5 segundos

---

## 🎯 **PRÓXIMOS PASSOS**

### **Melhorias Futuras**
- [ ] Implementar autenticação real (remover user-default)
- [ ] Adicionar rate limiting nos publishers
- [ ] Implementar circuit breaker para RabbitMQ
- [ ] Adicionar metrics com Prometheus
- [ ] Implementar message replay tools
- [ ] Adicionar tracing distribuído

### **Escalabilidade**
- [ ] Configurar cluster RabbitMQ
- [ ] Implementar load balancing
- [ ] Adicionar consumer scaling automático
- [ ] Configurar persistent volumes adequados

---

## 🆘 **CONTATOS DE EMERGÊNCIA**

- **Documentação RabbitMQ**: https://www.rabbitmq.com/documentation.html
- **Monitoring**: http://localhost:15672
- **Health Checks**: 
  - User Service: http://localhost:3000/api/health
  - Provas Service: http://localhost:3001/health

> **⚠️ CRÍTICO**: Esta implementação é fundamental para o funcionamento do sistema. Qualquer falha na mensageria afeta diretamente a gamificação e a experiência do usuário. 