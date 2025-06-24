#!/bin/bash

# PI5 - Script de Inicialização Completa
# Este script inicializa todo o ecosistema PI5 incluindo monitoramento

set -e

echo "🚀 Iniciando PI5 - Aplicativo de Estudos com Gamificação"
echo "=================================================="

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para mostrar status
show_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

show_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

show_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

show_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar se Docker está rodando
show_status "Verificando Docker..."
if ! docker info > /dev/null 2>&1; then
    show_error "Docker não está rodando. Por favor, inicie o Docker primeiro."
    exit 1
fi
show_success "Docker está ativo"

# Verificar se docker-compose está disponível
show_status "Verificando Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    show_error "Docker Compose não encontrado. Por favor, instale o Docker Compose."
    exit 1
fi
show_success "Docker Compose disponível"

# Verificar arquivos .env
show_status "Verificando arquivos de configuração..."
ENV_FILES=(
    "user-service/.env"
    "pi5_ms_provas/.env"
    "pi5_ms_notificacoes/.env"
)

missing_files=0
for file in "${ENV_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        show_warning "Arquivo $file não encontrado"
        missing_files=$((missing_files + 1))
    fi
done

if [ $missing_files -gt 0 ]; then
    show_warning "$missing_files arquivo(s) .env não encontrado(s). O sistema pode não funcionar corretamente."
    read -p "Continuar mesmo assim? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        show_error "Execução cancelada pelo usuário"
        exit 1
    fi
fi

# Verificar arquivo Firebase
show_status "Verificando arquivo Firebase..."
FIREBASE_FILE="D:/Faculdade/pi5-ms-notificacoes.json"
if [ ! -f "$FIREBASE_FILE" ]; then
    show_warning "Arquivo Firebase não encontrado em $FIREBASE_FILE"
    show_warning "Notificações push podem não funcionar"
fi

# Parar containers existentes se houver
show_status "Parando containers existentes..."
docker-compose down -v --remove-orphans 2>/dev/null || true

# Construir e iniciar serviços
show_status "Construindo e iniciando todos os serviços..."
docker-compose up --build -d

# Aguardar inicialização
show_status "Aguardando inicialização dos serviços..."
sleep 30

# Verificar status dos serviços
show_status "Verificando saúde dos serviços..."

SERVICES=(
    "http://localhost:3000/api/health:User Service"
    "http://localhost:3002/api/health:Provas Service"
    "http://localhost:4040/api/health:Notifications Service"
    "http://localhost:9090/-/healthy:Prometheus"
    "http://localhost:3001/api/health:Grafana"
)

healthy_services=0
total_services=${#SERVICES[@]}

for service in "${SERVICES[@]}"; do
    url="${service%%:*}"
    name="${service##*:}"
    
    if curl -s -f "$url" > /dev/null 2>&1; then
        show_success "$name está saudável"
        healthy_services=$((healthy_services + 1))
    else
        show_warning "$name não está respondendo"
    fi
done

# Verificar bancos de dados
show_status "Verificando bancos de dados..."
DB_SERVICES=("postgres-user" "postgres-provas" "postgres-notifications")

for db in "${DB_SERVICES[@]}"; do
    if docker exec "$db" pg_isready -U postgres > /dev/null 2>&1; then
        show_success "Database $db está ativo"
    else
        show_warning "Database $db não está respondendo"
    fi
done

# Mostrar resumo
echo
echo "=================================================="
echo "🎯 RESUMO DA INICIALIZAÇÃO"
echo "=================================================="

show_success "$healthy_services de $total_services serviços estão saudáveis"

echo
echo "📋 URLs dos Serviços:"
echo "   🔐 User Service API:        http://localhost:3000"
echo "   📚 Provas Service API:      http://localhost:3002"
echo "   🔔 Notifications Service:   http://localhost:4040"
echo "   📊 Grafana (Monitoring):    http://localhost:3001 (admin/admin123)"
echo "   📈 Prometheus (Metrics):    http://localhost:9090"
echo "   🐰 RabbitMQ Management:     http://localhost:15672 (admin/admin123)"
echo "   🗄️  Adminer (Database):      http://localhost:8080"

echo
echo "📖 Documentação API (Swagger):"
echo "   User Service:       http://localhost:3000/api-docs"
echo "   Provas Service:     http://localhost:3002/api-docs"
echo "   Notifications:      http://localhost:4040/api-docs"

echo
echo "🔧 Comandos Úteis:"
echo "   Ver logs:           docker-compose logs -f"
echo "   Parar serviços:     docker-compose down"
echo "   Restart:            docker-compose restart"
echo "   Status:             docker-compose ps"

echo
if [ $healthy_services -eq $total_services ]; then
    show_success "✅ Sistema PI5 inicializado com sucesso!"
    show_status "Agora você pode executar o app Flutter com: cd pi5_ms_mobile && flutter run"
else
    show_warning "⚠️  Sistema parcialmente inicializado. Verifique os logs para detalhes."
    show_status "Execute: docker-compose logs -f para investigar problemas"
fi

echo
show_status "Para monitorar o sistema em tempo real, acesse Grafana em http://localhost:3001"
echo "=================================================="
