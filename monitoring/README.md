# 📊 Sistema de Monitoramento PI5

Este diretório contém a configuração completa do sistema de monitoramento para os microsserviços do PI5, utilizando **Prometheus** para coleta de métricas e **Grafana** para visualização.

## 🏗️ Arquitetura de Monitoramento

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Microsserviços│    │   Prometheus    │    │     Grafana     │
│                 │───▶│                 │───▶│                 │
│ • User Service  │    │ Coleta Métricas │    │   Dashboards    │
│ • Provas Service│    │ Armazena Dados  │    │  Visualização   │
│ • Notifications │    │ Alertas         │    │    Alertas      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │              ┌─────────────────┐             │
         └─────────────▶│  Node Exporter  │◀────────────┘
                        │ Métricas Sistema │
                        └─────────────────┘
```

## 🚀 Serviços de Monitoramento

### Prometheus (http://localhost:9090)
- **Função**: Coleta e armazenamento de métricas
- **Coleta dados de**: 
  - Microsserviços (APIs, performance, erros)
  - PostgreSQL (conexões, queries, cache)
  - RabbitMQ (filas, mensagens)
  - Sistema operacional (CPU, memória, disk)

### Grafana (http://localhost:3001)
- **Função**: Visualização e dashboards
- **Credenciais padrão**: `admin` / `admin123`
- **Dashboards inclusos**:
  - PI5 Microsserviços Overview
  - Database Monitoring
  - Sistema de Alertas

### Node Exporter (http://localhost:9100)
- **Função**: Métricas do sistema operacional
- **Coleta**: CPU, memória, disco, rede, processos

## 📋 Configuração Automática

### Datasources
O Grafana é configurado automaticamente com:
- Prometheus como datasource padrão
- Conexão em `http://prometheus:9090`
- Timeout de 300s para queries complexas

### Dashboards Provisionados
Os dashboards são carregados automaticamente em `/var/lib/grafana/dashboards/`:
- `pi5-overview.json` - Overview geral dos microsserviços
- `pi5-database.json` - Monitoramento específico de bancos

## 🔧 Configuração Manual

### 1. Habilitar Métricas nos Microsserviços

Para que o Prometheus colete métricas dos microsserviços Node.js, você precisa adicionar o middleware de métricas:

```bash
# Instalar dependências nos microsserviços
npm install prom-client express-prometheus-middleware
```

**Exemplo para User Service (`src/app.js`):**
```javascript
const promClient = require('prom-client');
const promMiddleware = require('express-prometheus-middleware');

// Registrar métricas padrão
promClient.register.setDefaultLabels({
  app: 'user-service'
});
promClient.collectDefaultMetrics();

// Middleware de métricas
app.use(promMiddleware({
  metricsPath: '/metrics',
  collectDefaultMetrics: true,
  requestDurationBuckets: [0.1, 0.5, 1, 1.5, 2, 3, 5, 10],
}));
```

### 2. Configurar PostgreSQL Exporter

Para métricas detalhadas do PostgreSQL, adicione ao docker-compose:

```yaml
# PostgreSQL Exporter para métricas detalhadas
postgres-exporter:
  image: quay.io/prometheuscommunity/postgres-exporter
  container_name: postgres-exporter
  ports:
    - "9187:9187"
  environment:
    DATA_SOURCE_NAME: "postgresql://postgres:postgres@postgres-user:5432/auth_service?sslmode=disable"
  depends_on:
    - postgres-user
  networks:
    - microservices-network
```

### 3. Configurar RabbitMQ Management Plugin

O RabbitMQ já possui métricas nativas. Para habilitar:

```bash
# Entrar no container RabbitMQ
docker exec -it rabbitmq-broker bash

# Habilitar plugin de métricas
rabbitmq-plugins enable rabbitmq_prometheus
```

## 📊 Métricas Disponíveis

### Microsserviços Node.js
- `http_requests_total` - Total de requisições HTTP
- `http_request_duration_ms` - Duração das requisições
- `process_cpu_seconds_total` - Uso de CPU
- `process_resident_memory_bytes` - Uso de memória
- `nodejs_heap_size_total_bytes` - Heap do Node.js

### PostgreSQL
- `pg_up` - Status do banco
- `pg_stat_database_*` - Estatísticas de database
- `pg_stat_bgwriter_*` - Estatísticas de escrita
- `pg_locks_count` - Contagem de locks

### RabbitMQ
- `rabbitmq_queue_messages` - Mensagens na fila
- `rabbitmq_connections` - Conexões ativas
- `rabbitmq_consumers` - Consumidores ativos

### Sistema (Node Exporter)
- `node_cpu_seconds_total` - CPU usage
- `node_memory_MemAvailable_bytes` - Memória disponível
- `node_filesystem_size_bytes` - Uso de disco
- `node_load1` - Load average

## 🚨 Configuração de Alertas

### Prometheus Alerting Rules

Crie `monitoring/prometheus/alerts.yml`:

```yaml
groups:
  - name: pi5-alerts
    rules:
      - alert: ServiceDown
        expr: up{job=~"user-service|provas-service|notification-service"} == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Serviço {{$labels.job}} está offline"
      
      - alert: HighMemoryUsage
        expr: process_resident_memory_bytes / 1024 / 1024 > 500
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Alto uso de memória em {{$labels.job}}"
      
      - alert: DatabaseConnectionsHigh
        expr: pg_stat_database_numbackends > 50
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "Muitas conexões no banco {{$labels.job}}"
```

### Grafana Alerts

1. Acesse Grafana → Alerting → Alert Rules
2. Configure canais de notificação (email, Slack, etc.)
3. Defina thresholds para métricas críticas

## 🔍 Queries Úteis do Prometheus

### Performance das APIs
```promql
# Taxa de requisições por segundo
rate(http_requests_total[5m])

# Latência P95
histogram_quantile(0.95, rate(http_request_duration_ms_bucket[5m]))

# Taxa de erro
rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m])
```

### Recursos do Sistema
```promql
# CPU usage por serviço
rate(process_cpu_seconds_total[5m]) * 100

# Memória em MB
process_resident_memory_bytes / 1024 / 1024

# Load average do sistema
node_load1
```

### Banco de Dados
```promql
# Conexões ativas
pg_stat_database_numbackends

# Cache hit ratio
pg_stat_database_blks_hit / (pg_stat_database_blks_hit + pg_stat_database_blks_read) * 100

# Query rate
rate(pg_stat_database_tup_returned[5m])
```

## 📝 Troubleshooting

### Prometheus não coleta métricas
1. Verificar se o endpoint `/metrics` está acessível
2. Checar configuração em `prometheus.yml`
3. Verificar logs: `docker logs prometheus`

### Grafana não conecta ao Prometheus
1. Verificar datasource em Configuration → Data Sources
2. Testar conectividade: `docker exec grafana ping prometheus`
3. Verificar logs: `docker logs grafana`

### Dashboards não carregam
1. Verificar se os arquivos estão em `/monitoring/grafana/dashboards/`
2. Conferir permissões dos arquivos
3. Reiniciar Grafana: `docker restart grafana`

## 🔄 Manutenção

### Backup das Configurações
```bash
# Backup das configurações do Grafana
docker exec grafana tar -czf /tmp/grafana-backup.tar.gz /var/lib/grafana

# Backup dos dados do Prometheus
docker exec prometheus tar -czf /tmp/prometheus-backup.tar.gz /prometheus
```

### Limpeza de Dados Antigos
```bash
# Configurar retenção no Prometheus (já configurado para 200h)
# Limpar dados manualmente se necessário
docker exec prometheus rm -rf /prometheus/data
```

### Atualização dos Dashboards
1. Editar arquivos JSON em `monitoring/grafana/dashboards/`
2. Reiniciar Grafana para aplicar mudanças
3. Ou importar via UI do Grafana

## 📈 Próximos Passos

1. **Métricas Customizadas**: Adicionar métricas específicas do negócio
2. **Alertas Avançados**: Configurar Alertmanager
3. **Logs Centralizados**: Integrar ELK Stack ou Loki
4. **Tracing Distribuído**: Adicionar Jaeger ou Zipkin
5. **Métricas de Aplicação**: Gamificação, sessões de estudo, etc.

---

**Para mais informações, consulte a documentação oficial:**
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [Node Exporter](https://github.com/prometheus/node_exporter)
