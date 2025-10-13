# PI5 - Aplicativo de Estudos com Gamificação

## 📱 Visão Geral

O **PI5** é uma solução completa para gestão de estudos com gamificação, desenvolvida como projeto integrador do 5º período. O sistema utiliza arquitetura de microsserviços distribuídos com aplicativo móvel Flutter, proporcionando uma experiência de estudo interativa e motivacional.

## 📱 Screenshots

<img width="387" height="832" alt="image" src="https://github.com/user-attachments/assets/a4c49db0-f16a-4bb6-a58c-f97871ad274e" />
<img width="395" height="843" alt="image" src="https://github.com/user-attachments/assets/a208fb10-9b99-4c97-8e9f-15ba778a8288" />
<img width="390" height="839" alt="image" src="https://github.com/user-attachments/assets/31a95b81-009c-483a-87cd-b7c22e3ede36" />
<img width="381" height="830" alt="image" src="https://github.com/user-attachments/assets/d974f4fd-fb7e-4471-a5df-88325212751c" />
<img width="387" height="832" alt="image" src="https://github.com/user-attachments/assets/135e02c4-6e18-4fcb-87b2-3916db97f69c" />
<img width="412" height="861" alt="image" src="https://github.com/user-attachments/assets/a2bf821d-4221-4d68-a5f6-fe141cfd055f" />
<img width="406" height="845" alt="image" src="https://github.com/user-attachments/assets/6ec54a37-c5f4-4fa9-8e71-c898ec32769c" />
<img width="395" height="841" alt="image" src="https://github.com/user-attachments/assets/895dd9d5-2198-44d2-9a58-2bbdcb4c95f9" />
<img width="390" height="836" alt="image" src="https://github.com/user-attachments/assets/3ef31148-5558-4e57-a705-6b6e76a72788" />
<img width="382" height="843" alt="image" src="https://github.com/user-attachments/assets/180fbe36-a85e-4f8c-bb8a-579c5a3a67db" />


### 🎯 Funcionalidades Principais

- **🎮 Sistema de Gamificação**: XP, níveis, streaks e conquistas para motivar estudos
- **📚 Gestão Inteligente de Provas**: CRUD completo com status dinâmico e acompanhamento
- **⏱️ Sessões de Estudo Avançadas**: Cronômetro com modalidades livres e agendadas
- **📊 Analytics e Relatórios**: Gráficos interativos, estatísticas e exportação PDF
- **🔔 Notificações Inteligentes**: Sistema push via Firebase Cloud Messaging
- **🎁 Wrapped Anual**: Resumo gamificado e personalizado do progresso anual
- **👤 Perfil Personalizado**: Upload de foto, estatísticas e configurações

## 🏗️ Arquitetura do Sistema

### Microsserviços Backend (Domain-Driven Design)

```
pi5-app-estudo/
├── user-service/                   # Autenticação & Gestão de Usuários
│   ├── Port: 3000                 # API REST + Swagger Documentation
│   ├── Database: auth_service      # PostgreSQL (porta 5432)
│   └── Features: Auth, Profile, Gamification Data
│
├── pi5_ms_provas/                 # Gestão de Provas & Sessões
│   ├── Port: 3001                 # API REST + Swagger Documentation  
│   ├── Database: provas_db        # PostgreSQL (porta 5433)
│   └── Features: CRUD Provas, Sessões, Matérias, Estatísticas
│
├── pi5_ms_notificacoes/           # Sistema de Notificações
│   ├── Port: 4040                 # API REST + Firebase Integration
│   ├── Database: notificacoes     # PostgreSQL (porta 5434)
│   └── Features: Push Notifications, Templates, Logs
│
└── Infrastructure/
    ├── RabbitMQ (5672/15672)      # Message Broker para comunicação entre serviços
    ├── Adminer (8080)             # Interface web para gestão de bancos
    └── Docker Network             # Comunicação interna segura
```

### Aplicativo Mobile (Clean Architecture)

```
pi5_ms_mobile/                     # Flutter App Multiplataforma
├── android/                       # Configurações Android + Firebase
├── ios/                          # Configurações iOS + Firebase  
├── web/                          # Suporte Web (desenvolvimento)
├── assets/
│   ├── fonts/                    # Poppins, Roboto
│   └── images/                   # Logo, placeholders
└── lib/src/
    ├── components/               # Widgets reutilizáveis
    ├── config/                   # Configurações API e Firebase
    ├── infrastructure/           # Camada de dados e HTTP
    ├── presentation/             # Telas e UI Components
    │   ├── auth/                # Login, Registro, Recuperação
    │   ├── cronograma/          # Calendário e sessões
    │   ├── desempenho/          # Gráficos e estatísticas
    │   ├── provas/              # CRUD e listagem de provas
    │   ├── user/                # Perfil e configurações
    │   └── wrapped/             # Relatório anual gamificado
    ├── routes/                   # Navegação e routing
    ├── services/                 # Deprecated (migrado para shared/)
    └── shared/
        ├── models/              # DTOs e Models
        ├── services/            # API Services e HTTP clients  
        └── utils/               # Helpers e constantes
```

## 🚀 Stack Tecnológica Completa

### Backend (Microsserviços)
- **Node.js 20.x** com Express.js framework
- **PostgreSQL 16** com Prisma ORM para type-safe database access
- **RabbitMQ 3.12** para messaging assíncrono entre serviços
- **Firebase Admin SDK** para push notifications
- **JWT + Refresh Tokens** para autenticação stateless
- **Docker & Docker Compose** para containerização e orquestração
- **Swagger/OpenAPI 3.0** para documentação interativa de APIs
- **Winston** para logging estruturado e centralizado
- **Helmet + CORS + Rate Limiting** para segurança
- **Joi/Yup/Zod** para validação de schemas
- **Prisma Studio** para administração visual de dados

### Frontend Mobile
- **Flutter 3.7.0+** (Dart 3.0+) para desenvolvimento multiplataforma
- **Firebase Core + Messaging** para notificações push
- **FL Chart 0.71.0** para gráficos interativos e animados
- **Syncfusion Gauges 29.1.39** para medidores circulares visuais
- **PDF 3.11.3 + Printing 5.14.2** para geração e exportação de relatórios
- **Share Plus 11.0.0** para compartilhamento nativo
- **Image Picker 1.1.2 + Image 4.5.4** para upload e processamento de fotos
- **HTTP 1.1.0 + Shared Preferences 2.2.2** para API calls e cache local
- **Table Calendar 3.1.3** para interface de calendário
- **Flutter Local Notifications** para notificações locais
- **Intl 0.19.0** para internacionalização

### Banco de Dados & ORM
- **PostgreSQL 16-alpine** (múltiplas instâncias isoladas)
- **Prisma ORM** com migrations automáticas
- **Database per Service** pattern para isolamento completo
- **Connection pooling** e otimizações de performance
- **Backup automatizado** via Docker volumes

### DevOps & Infraestrutura
- **Docker Compose 3.8** para orquestração local
- **Health Checks** para monitoramento de serviços
- **Volume Persistence** para dados críticos
- **Network Isolation** para segurança entre serviços
- **Environment Variables** para configuração flexível
- **Logs Centralizados** com rotação automática

### Monitoramento & Observabilidade
- **Prometheus** para coleta e armazenamento de métricas
- **Grafana** para dashboards e visualização de dados
- **Node Exporter** para métricas do sistema operacional
- **Alerting** configurável para eventos críticos
- **Custom Dashboards** para microsserviços e bancos de dados
- **Real-time Monitoring** de performance e recursos

## 📋 Pré-requisitos Detalhados

### Para Desenvolvimento Local
- **Node.js 20.0.0+** ([Download oficial](https://nodejs.org/))
- **Flutter SDK 3.7.0+** ([Guia de instalação](https://docs.flutter.dev/get-started/install))
- **Docker 24.0+** e **Docker Compose V2** ([Instalação](https://docs.docker.com/get-docker/))
- **Git 2.30+** ([Download](https://git-scm.com/))
- **IDE**: Android Studio, VS Code, ou IntelliJ IDEA
  - **VS Code Extensions**: Flutter, Dart, Docker, Prisma
  - **Android Studio Plugins**: Flutter e Dart plugins

### Contas e Serviços Externos
- **Firebase Project** configurado ([Console](https://console.firebase.google.com/))
- **Gmail Account** com App Passwords habilitado para SMTP
- **Opcional**: GitHub Account para CI/CD

### Dispositivos para Teste
- **Android Emulator** (API 21+) ou dispositivo físico
- **iOS Simulator** (macOS apenas) ou dispositivo físico
- **Chrome/Edge** para teste web (desenvolvimento)

## 🛠️ Instalação e Configuração Completa

### 1. Clone e Navegação

```bash
# Clone do repositório
git clone <url-do-repositorio>
cd pi5-app-estudo

# Verificar estrutura
ls -la
```

### 2. Configuração Firebase (Obrigatória)

#### 2.1 Criar e Configurar Projeto Firebase
1. Acesse [Firebase Console](https://console.firebase.google.com/)
2. Clique em "**Criar um projeto**" ou "**Add project**"
3. Nomeie o projeto (ex: "pi5-estudos-app")
4. **Habilite Google Analytics** (recomendado)
5. Aguarde a criação do projeto

#### 2.2 Configurar Cloud Messaging
1. No painel do projeto, vá em "**Project Settings**" (engrenagem)
2. Aba "**Cloud Messaging**"
3. Anote o **Server Key** (será usado depois)

#### 2.3 Adicionar App Android
1. Clique em "**Add app**" → ícone Android
2. **Package name**: `com.example.pi5_ms_mobile`
3. **App nickname**: "PI5 Mobile App"
4. **Debug signing certificate SHA-1**: (opcional para desenvolvimento)
5. Clique "**Register app**"
6. **Download** `google-services.json`
7. Mova o arquivo para: `pi5_ms_mobile/android/app/google-services.json`

#### 2.4 Gerar Service Account (Para Backend)
1. No Firebase Console → "**Project Settings**"
2. Aba "**Service accounts**"
3. Clique "**Generate new private key**"
4. Salve como: `D:/Faculdade/pi5-ms-notificacoes.json`
   - **Importante**: Este caminho exato é usado no Docker Compose
   - Se alterar o caminho, atualize o `docker-compose.yml`

### 3. Configuração dos Microsserviços Backend

#### 3.1 User Service (Autenticação)
```bash
cd user-service
npm install
```

**Crie o arquivo `.env`:**
```env
# Server Configuration
NODE_ENV=development
PORT=3000

# Database  
DATABASE_URL=postgresql://postgres:postgres@postgres-user:5432/auth_service?schema=public

# JWT Configuration
JWT_SECRET=pi5_super_secret_key_2024_development_only
JWT_EXPIRES_IN=24h

# SMTP Configuration (Gmail)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=seu_email@gmail.com
SMTP_PASS=sua_senha_de_app_gmail

# RabbitMQ Configuration
RABBITMQ=amqp://admin:admin123@rabbitmq-broker:5672/
RABBITMQ_EXCHANGE=pi5_events

# Security
BCRYPT_ROUNDS=12
RATE_LIMIT_REQUESTS=100
RATE_LIMIT_WINDOW_MS=900000
```

#### 3.2 Microsserviço de Provas
```bash
cd ../pi5_ms_provas
npm install
```

**Crie o arquivo `.env`:**
```env
# Server Configuration
NODE_ENV=development
PORT=3000

# Database
DATABASE_URL=postgresql://postgres:postgres@postgres-provas:5432/provas_db

# JWT Configuration  
JWT_SECRET=pi5_super_secret_key_2024_development_only

# RabbitMQ Configuration
RABBITMQ_URL=amqp://admin:admin123@rabbitmq-broker:5672/
RABBITMQ_EXCHANGE=pi5_events

# Service Configuration
SERVICE_NAME=provas-service
USER_SERVICE_URL=http://user-service:3000

# Performance
DB_POOL_SIZE=10
CACHE_TTL=300
```

#### 3.3 Microsserviço de Notificações
```bash
cd ../pi5_ms_notificacoes
npm install
```

**Crie o arquivo `.env`:**
```env
# Server Configuration
NODE_ENV=development
PORT=4040

# Database
DATABASE_URL=postgresql://postgres:postgres@postgres-notifications:5432/notificacoes

# RabbitMQ Configuration
RABBITMQ=amqp://admin:admin123@rabbitmq-broker:5672/

# Queue Names
USER_QUEUE=user_created_queue
EVENT_QUEUE=event_created_queue
STREAK_QUEUE=streak_created_queue

# Firebase Configuration
FIREBASE=/app/config/firebase-service-account.json

# JWT Configuration
JWTSECRET=pi5_super_secret_key_2024_development_only
JWTEXPIRE=24h

# Notification Settings
MAX_RETRY_ATTEMPTS=3
NOTIFICATION_BATCH_SIZE=100
```

### 4. Configuração do Aplicativo Mobile

#### 4.1 Instalar Dependências Flutter
```bash
cd ../pi5_ms_mobile

# Verificar instalação do Flutter
flutter doctor

# Instalar dependências
flutter pub get

# Verificar dispositivos disponíveis
flutter devices
```

#### 4.2 Configurar Endpoints da API

**Edite `lib/src/config/api_config.dart`:**
```dart
class ApiConfig {
  // OPÇÃO 1: Para Docker Compose (Emulador Android)
  static const String baseUrl = 'http://10.0.2.2:3000/api';
  
  // OPÇÃO 2: Para dispositivo físico (substitua pelo seu IP local)
  // static const String baseUrl = 'http://192.168.1.100:3000/api';
  
  // OPÇÃO 3: Para execução local sem Docker
  // static const String baseUrl = 'http://localhost:3000/api';
  
  static const Map<String, String> headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*',
  };
  
  // Timeout configurations
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
```

#### 4.3 Verificar Configuração Android

**Arquivo `android/app/src/main/AndroidManifest.xml`** deve conter:
```xml
<!-- Permissões de Internet -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

<!-- Permissões de Notificação -->
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
```

## 🚀 Executando o Projeto

### Opção 1: Docker Compose (Recomendado para Desenvolvimento)

```bash
# Voltar para a raiz do projeto
cd /caminho/para/pi5-app-estudo

# Verificar se todos os arquivos .env foram criados
ls user-service/.env pi5_ms_provas/.env pi5_ms_notificacoes/.env

# Verificar se o arquivo Firebase está no local correto
ls -la "D:/Faculdade/pi5-ms-notificacoes.json"

# Construir e subir todos os serviços
docker-compose up --build -d

# Verificar status dos containers
docker-compose ps

# Aguardar inicialização completa (pode levar 2-3 minutos)
docker-compose logs -f --tail=50

# Verificar saúde dos serviços
curl http://localhost:3000/api/health  # User Service
curl http://localhost:3002/api/health  # Provas Service  
curl http://localhost:4040/api/health  # Notifications Service

# Verificar serviços de monitoramento
curl http://localhost:9090/-/healthy   # Prometheus
curl http://localhost:3001/api/health  # Grafana
curl http://localhost:9100/metrics     # Node Exporter
```

**URLs dos Serviços Disponíveis:**
- **User Service API**: http://localhost:3000
  - Swagger: http://localhost:3000/api-docs
  - Health: http://localhost:3000/api/health
- **Provas Service API**: http://localhost:3002
  - Swagger: http://localhost:3002/api-docs
  - Health: http://localhost:3002/api/health
- **Notifications Service API**: http://localhost:4040
  - Swagger: http://localhost:4040/api-docs
  - Health: http://localhost:4040/api/health
- **RabbitMQ Management**: http://localhost:15672
  - Usuário: `admin` / Senha: `admin123`
- **Adminer (Database UI)**: http://localhost:8080
- **📊 Grafana (Monitoring)**: http://localhost:3001
  - Usuário: `admin` / Senha: `admin123`
- **📈 Prometheus (Metrics)**: http://localhost:9090
- **🖥️ Node Exporter (System Metrics)**: http://localhost:9100

**Credenciais para Adminer:**
| Campo | Valor |
|-------|-------|
| Sistema | PostgreSQL |
| Servidor | `postgres-user` (ou `postgres-provas`, `postgres-notifications`) |
| Usuário | `postgres` |
| Senha | `postgres` |
| Base de dados | `auth_service` (ou `provas_db`, `notificacoes`) |

### Opção 2: Execução Local Manual (Para Debug Avançado)

#### 2.1 Infraestrutura Base
```bash
# RabbitMQ
docker run -d --name rabbitmq-local \
  -p 5672:5672 -p 15672:15672 \
  -e RABBITMQ_DEFAULT_USER=admin \
  -e RABBITMQ_DEFAULT_PASS=admin123 \
  rabbitmq:3.12-management

# PostgreSQL para User Service
docker run -d --name postgres-user-local \
  -e POSTGRES_DB=auth_service \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -p 5432:5432 postgres:16-alpine

# PostgreSQL para Provas Service
docker run -d --name postgres-provas-local \
  -e POSTGRES_DB=provas_db \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -p 5433:5432 postgres:16-alpine

# PostgreSQL para Notifications Service
docker run -d --name postgres-notifications-local \
  -e POSTGRES_DB=notificacoes \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -p 5434:5432 postgres:16-alpine

# Aguardar inicialização dos bancos
sleep 30
```

#### 2.2 Configurar Bancos e Executar Migrações
```bash
# User Service - Database Setup
cd user-service
# Atualizar DATABASE_URL no .env para localhost:5432
npm run prisma:generate
npm run prisma:migrate
npm run prisma:seed  # Se existir

# Provas Service - Database Setup  
cd ../pi5_ms_provas
# Atualizar DATABASE_URL no .env para localhost:5433
npm run prisma:generate
npm run prisma:migrate
npm run seed  # Popular dados de exemplo

# Notifications Service - Database Setup
cd ../pi5_ms_notificacoes  
# Atualizar DATABASE_URL no .env para localhost:5434
npm run prisma:generate
npm run prisma:migrate
```

#### 2.3 Executar Microsserviços (4 terminais separados)
```bash
# Terminal 1 - User Service
cd user-service
npm run dev

# Terminal 2 - Provas Service  
cd pi5_ms_provas
npm run dev

# Terminal 3 - Notifications Service
cd pi5_ms_notificacoes
npm run start

# Terminal 4 - Flutter App
cd pi5_ms_mobile
# Atualizar baseUrl em api_config.dart para localhost:3000
flutter run
```

### Opção 3: Executar Apenas o App Mobile (Backend em Docker)

```bash
# Subir apenas o backend
docker-compose up -d user-service provas-service notification-service rabbitmq postgres-user postgres-provas postgres-notifications

# Executar o app mobile
cd pi5_ms_mobile
flutter run

# Para Web (desenvolvimento)
flutter run -d chrome --web-port 8081

# Para dispositivo específico
flutter devices
flutter run -d <device-id>
```

## 📱 Funcionalidades Implementadas e Testadas

### 🎮 Sistema de Gamificação Avançado
- ✅ **Sistema de XP Dinâmico**: Pontos baseados em tempo de estudo, desempenho e frequência
- ✅ **Progressão de Níveis**: Sistema automático com diferentes tiers de conquistas
- ✅ **Streaks Inteligentes**: Sequências de dias estudando com tolerância configurável
- ✅ **Métricas Visuais**: Gauges animados e cards informativos em tempo real
- ✅ **Sincronização Completa**: Dados centralizados entre mobile e backend
- ✅ **Motivação Gamificada**: Feedback positivo e conquistas desbloqueáveis

### 📚 Gestão Completa de Provas
- ✅ **CRUD Robusto**: Criar, visualizar, editar e excluir provas com validação
- ✅ **Status Dinâmico**: PENDENTE → CONCLUÍDA → CANCELADA com interface intuitiva
- ✅ **Menu Contextual**: Alteração rápida de status com feedback visual
- ✅ **Filtros Avançados**: Busca por título, data, status e matéria
- ✅ **Validação Inteligente**: Campos obrigatórios e formatos de data/hora
- ✅ **Integração Calendario**: Visualização de provas na timeline
- ✅ **Estatísticas Visuais**: Gauge de provas concluídas e métricas

### ⏱️ Sessões de Estudo Inteligentes
- ✅ **Modalidades Múltiplas**: Sessões livres e agendadas (vinculadas a provas)
- ✅ **Cronômetro Avançado**: Pausa, resume, finalização com confirmação
- ✅ **Métricas Detalhadas**: Tempo, questões totais/acertadas, percentual de desempenho
- ✅ **Histórico Unificado**: Integração no cronograma com visualização completa
- ✅ **Auto-save**: Proteção contra perda de dados em caso de fechamento inesperado
- ✅ **Notificações**: Lembretes e alertas de sessões agendadas

### 📊 Analytics e Relatórios Profissionais
- ✅ **Dashboard Executivo**: Métricas consolidadas na tela inicial
- ✅ **Gráficos Interativos**: Análise de desempenho por prova com FL Chart
- ✅ **Estatísticas Avançadas**: Tempo total, média de acertos, evolução temporal
- ✅ **Exportação PDF Premium**: Relatórios com gráficos, tabelas e estatísticas
- ✅ **Compartilhamento Social**: Share de conquistas e progressos
- ✅ **Comparação Temporal**: Análise de evolução semanal/mensal

### 🎁 Wrapped Anual Gamificado
- ✅ **Interface Dedicada**: Tela especial com design atrativo
- ✅ **Dados Consolidados**: Estatísticas anuais completas e personalizadas
- ✅ **Storytelling Visual**: Narrativa gamificada do progresso
- ✅ **Compartilhamento Nativo**: Texto formatado para redes sociais
- ✅ **Conquistas Especiais**: Marcos anuais e recordes pessoais

### 👤 Perfil de Usuário Personalizado
- ✅ **Dados Sincronizados**: Informações atualizadas em tempo real do backend
- ✅ **Upload de Foto Otimizado**: Compressão automática e armazenamento em base64
- ✅ **Estatísticas Integradas**: Métricas de gamificação e desempenho
- ✅ **Interface Moderna**: Design responsivo com Material Design 3
- ✅ **Configurações Avançadas**: Preferências de notificação e privacidade

### 🔔 Sistema de Notificações Inteligente
- ✅ **Push Notifications**: Via Firebase Cloud Messaging
- ✅ **Notificações Locais**: Lembretes mesmo offline
- ✅ **Lembretes Adaptativos**: Baseados em padrões de estudo do usuário
- ✅ **Alertas de Provas**: Notificações configuráveis para eventos próximos
- ✅ **Conquistas em Tempo Real**: Notificações de marcos e níveis alcançados
- ✅ **Gerenciamento Granular**: Controle individual de tipos de notificação

### 🔄 Sincronização e Performance
- ✅ **Lifecycle Management**: Atualização automática ao retomar o app
- ✅ **Pull-to-Refresh**: Atualização manual em todas as telas
- ✅ **Feedback Visual**: Indicadores de loading e estados de conexão
- ✅ **Tratamento de Erros**: Fallbacks para cenários offline
- ✅ **Cache Inteligente**: Shared Preferences para dados frequentes
- ✅ **Retry Logic**: Tentativas automáticas em falhas de rede

### 🏗️ Arquitetura e Qualidade de Código
- ✅ **Clean Architecture**: Separação clara de camadas e responsabilidades
- ✅ **Domain-Driven Design**: Modelagem focada no domínio do negócio
- ✅ **SOLID Principles**: Código maintível e extensível
- ✅ **Type Safety**: Prisma ORM e Dart strict mode
- ✅ **Error Handling**: Tratamento consistente de exceções
- ✅ **Logging Estruturado**: Winston com diferentes níveis de log
- ✅ **API Documentation**: Swagger/OpenAPI 3.0 completo
- ✅ **Database Migrations**: Versionamento automático de schema

### 📊 Monitoramento e Observabilidade
- ✅ **Prometheus Integration**: Coleta automática de métricas dos microsserviços
- ✅ **Grafana Dashboards**: Visualização em tempo real de performance e recursos
- ✅ **System Monitoring**: Node Exporter para métricas do sistema operacional
- ✅ **Database Monitoring**: Métricas específicas de PostgreSQL e conexões
- ✅ **API Performance**: Monitoramento de latência, throughput e taxa de erro
- ✅ **Resource Tracking**: CPU, memória, disco e rede em tempo real
- ✅ **Custom Dashboards**: Painéis específicos para cada microsserviço
- ✅ **Health Checks**: Verificação automática de saúde dos serviços
- ✅ **Alerting Ready**: Base preparada para configuração de alertas críticos

## 🧪 Testando o Sistema Completo

### Verificação Rápida da Infraestrutura
```bash
# 1. Verificar se todos os serviços estão rodando
docker-compose ps

# 2. Testar APIs de Health Check
curl -f http://localhost:3000/api/health && echo "✓ User Service OK"
curl -f http://localhost:3002/api/health && echo "✓ Provas Service OK"  
curl -f http://localhost:4040/api/health && echo "✓ Notifications Service OK"

# 3. Verificar serviços de monitoramento
curl -f http://localhost:9090/-/healthy && echo "✓ Prometheus OK"
curl -f http://localhost:3001/api/health && echo "✓ Grafana OK"
curl -f http://localhost:9100/metrics > /dev/null && echo "✓ Node Exporter OK"

# 4. Verificar conectividade do banco
docker exec postgres-user pg_isready -U postgres
docker exec postgres-provas pg_isready -U postgres  
docker exec postgres-notifications pg_isready -U postgres

# 5. Verificar RabbitMQ Management
curl -u admin:admin123 http://localhost:15672/api/overview

# 6. Verificar Adminer
curl -f http://localhost:8080 && echo "✓ Adminer OK"
```

### Fluxo de Teste End-to-End Completo

#### Fase 1: Cadastro e Autenticação
1. **Abrir app mobile** e verificar tela de login
2. **Cadastrar novo usuário** com email válido
3. **Fazer login** e verificar token JWT
4. **Testar refresh token** (aguardar expiração)
5. **Verificar perfil** com dados padrão

#### Fase 2: Gestão de Provas
1. **Criar nova prova** com todos os campos
2. **Editar prova criada** alterando data/horário
3. **Marcar como CONCLUÍDA** usando menu de status
4. **Verificar estatísticas** atualizadas no gauge
5. **Filtrar provas** por status e título

#### Fase 3: Sessões de Estudo
1. **Iniciar sessão livre** sem vinculação
2. **Pausar e retomar** cronômetro
3. **Finalizar sessão** com questões e desempenho
4. **Iniciar sessão agendada** vinculada a prova
5. **Verificar histórico** no cronograma

#### Fase 4: Gamificação e Métricas
1. **Verificar XP** ganho após sessões
2. **Confirmar streak** incrementado
3. **Checar nível** baseado em XP total
4. **Visualizar cards** de gamificação atualizados
5. **Testar sincronização** fechando e reabrindo app

#### Fase 5: Analytics e Relatórios
1. **Acessar tela de desempenho** 
2. **Visualizar gráfico** por prova
3. **Exportar relatório PDF** com sucesso
4. **Compartilhar resultado** via share
5. **Verificar wrapped anual** com dados consolidados

#### Fase 6: Notificações (Opcional)
1. **Configurar Firebase** corretamente
2. **Testar notificação** via backend
3. **Verificar recebimento** no dispositivo
4. **Testar notificação local** de lembrete

### Scripts de Teste Automatizado

**Criar arquivo `test-api.sh`:**
```bash
#!/bin/bash

BASE_URL="http://localhost:3000/api"
EMAIL="teste@example.com"
PASSWORD="123456"

echo "🧪 Testando APIs do PI5..."

# 1. Health Check
echo "1. Health Checks..."
curl -f $BASE_URL/health || echo "❌ User Service down"

# 2. Cadastro
echo "2. Testando cadastro..."
REGISTER_RESPONSE=$(curl -s -X POST $BASE_URL/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Usuario Teste","email":"'$EMAIL'","password":"'$PASSWORD'"}')

# 3. Login
echo "3. Testando login..."
LOGIN_RESPONSE=$(curl -s -X POST $BASE_URL/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"'$EMAIL'","password":"'$PASSWORD'"}')

TOKEN=$(echo $LOGIN_RESPONSE | jq -r '.token')

# 4. Perfil
echo "4. Testando perfil..."
curl -s -H "Authorization: Bearer $TOKEN" $BASE_URL/user/profile

# 5. Criar Prova
echo "5. Testando criação de prova..."
curl -s -X POST http://localhost:3001/api/provas \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"titulo":"Prova Teste","descricao":"Teste automatizado","data":"2024-12-31","horario":"10:00","local":"Sala 101"}'

echo "✅ Testes concluídos!"
```

### Testes de Performance e Carga

```bash
# Teste de carga simples com curl
for i in {1..100}; do
  curl -s http://localhost:3000/api/health > /dev/null &
done
wait
echo "✅ 100 requisições simultâneas concluídas"

# Teste de memória dos containers
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"

# Teste de conectividade do banco sob carga
docker exec postgres-user psql -U postgres -d auth_service -c "SELECT COUNT(*) FROM \"User\";"
```

## � Troubleshooting

### Problemas Comuns

#### 1. Containers não sobem
```bash
# Limpar ambiente
docker-compose down -v
docker system prune -f

# Reconstruir imagens
docker-compose build --no-cache
docker-compose up -d
```

#### 2. Erro de Firebase no Mobile
```bash
# Verificar arquivo de configuração
ls pi5_ms_mobile/android/app/google-services.json

# Recompilar aplicativo
cd pi5_ms_mobile
flutter clean
flutter pub get
flutter run
```

#### 3. Banco de dados não conecta
```bash
# Verificar containers postgres
docker ps | grep postgres

# Logs do banco
docker-compose logs postgres-user
docker-compose logs postgres-provas
docker-compose logs postgres-notifications

# Reiniciar serviço específico
docker-compose restart postgres-user
```

#### 4. RabbitMQ não funciona
```bash
# Logs do RabbitMQ
docker-compose logs rabbitmq

# Verificar filas no management
# http://localhost:15672 → Queues tab

# Reiniciar messaging
docker-compose restart rabbitmq
```

#### 5. Flutter não conecta com API
```bash
# Para emulador Android
# Usar: http://10.0.2.2:3000/api

# Para dispositivo físico
# Descobrir IP local:
ipconfig  # Windows
ifconfig  # Linux/Mac
# Usar: http://SEU_IP_LOCAL:3000/api
```

### Logs Úteis
```bash
# Logs de todos os serviços
docker-compose logs -f

# Logs específicos
docker-compose logs -f user-service
docker-compose logs -f provas-service
docker-compose logs -f notification-service

# Logs do Flutter
flutter logs

# Banco de dados diretamente
docker exec -it postgres-user psql -U postgres -d auth_service
```

## 📚 Documentação Adicional

### APIs Swagger
- **User Service**: http://localhost:3000/api-docs
- **Provas Service**: http://localhost:3001/api-docs  
- **Notifications Service**: http://localhost:4040/api-docs

### Estrutura de Dados

#### User Service - Principais Entidades
```javascript
User {
  id: string
  name: string
  email: string  
  points: number
  isEmailVerified: boolean
  imageBase64: string?
  createdAt: datetime
  updatedAt: datetime
}
```

#### Provas Service - Principais Entidades  
```javascript
Prova {
  id: string
  titulo: string
  descricao: string?
  data: date
  horario: time
  local: string
  status: enum('PENDENTE', 'CONCLUIDA', 'CANCELADA')
  materiasIds: string[]
  userId: string
  createdAt: datetime
  updatedAt: datetime
}

SessaoEstudo {
  id: string
  tipo: enum('LIVRE', 'AGENDADA')
  tempoSegundos: number
  questoesTotal: number?
  questoesAcertadas: number?
  desempenho: number?
  provaId: string?
  userId: string
  iniciadaEm: datetime
  finalizadaEm: datetime?
}
```

### Comandos Docker Úteis
```bash
# Ver recursos utilizados
docker stats

# Limpar sistema completo
docker system prune -a --volumes

# Backup de banco específico
docker exec postgres-user pg_dump -U postgres auth_service > backup_user.sql

# Restaurar backup
docker exec -i postgres-user psql -U postgres auth_service < backup_user.sql

# Executar comandos em containers
docker exec -it user-service npm run prisma:studio
docker exec -it provas-service npm run seed
```

## 🚀 Deploy em Produção

### Preparação de Ambiente
```bash
# Servidor Ubuntu/Debian
sudo apt update && sudo apt upgrade -y
sudo apt install docker.io docker-compose-v2 -y
sudo systemctl enable docker
sudo usermod -aG docker $USER
```

### Configuração de Produção
1. **Configurar DNS** apontando para o servidor
2. **Obter certificado SSL** (Let's Encrypt)
3. **Configurar proxy reverso** (Nginx)
4. **Ajustar variáveis de ambiente** para produção
5. **Configurar backup automático** dos bancos

### Considerações de Segurança
- **Alterar senhas padrão** do RabbitMQ e PostgreSQL
- **Configurar firewall** (UFW) com portas específicas
- **Usar HTTPS** obrigatório para todas as APIs
- **Implementar rate limiting** mais restritivo
- **Configurar logs estruturados** com rotação

## 🤝 Contribuição

### Padrões de Código
- **Backend**: ESLint + Prettier
- **Frontend**: Dart Analysis com lint rigoroso
- **Commits**: Conventional Commits
- **Branches**: GitFlow (feature/, develop, main)

### Como Contribuir
1. Fork do repositório
2. Branch para feature: `git checkout -b feature/nova-funcionalidade`
3. Commit: `git commit -m 'feat: adiciona nova funcionalidade'`
4. Push: `git push origin feature/nova-funcionalidade`
5. Pull Request

## 📄 Licença

Este projeto está sob a licença MIT. Consulte o arquivo LICENSE para detalhes.

## 👥 Equipe de Desenvolvimento

- **Projeto Integrador 5º Período**
- **Instituição**: [Nome da Faculdade]
- **Curso**: Ciência da Computação / Sistemas de Informação

---

**🎯 Projeto PI5 - Transformando a experiência de estudos através da gamificação!**
