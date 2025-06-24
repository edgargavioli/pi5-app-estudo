const promClient = require('prom-client');

// Configurar métricas padrão para o Prometheus
class MetricsService {
    constructor(serviceName) {
        this.serviceName = serviceName;

        // Configurar labels padrão
        promClient.register.setDefaultLabels({
            app: serviceName,
            version: process.env.npm_package_version || '1.0.0'
        });

        // Coletar métricas padrão do Node.js
        promClient.collectDefaultMetrics({
            prefix: `${serviceName}_`,
            timeout: 5000,
        });

        // Métricas customizadas
        this.httpRequestDuration = new promClient.Histogram({
            name: `${serviceName}_http_request_duration_ms`,
            help: 'Duration of HTTP requests in ms',
            labelNames: ['method', 'route', 'status_code'],
            buckets: [0.1, 5, 15, 50, 100, 500]
        });

        this.httpRequestTotal = new promClient.Counter({
            name: `${serviceName}_http_requests_total`,
            help: 'Total number of HTTP requests',
            labelNames: ['method', 'route', 'status_code']
        });

        this.databaseConnectionPool = new promClient.Gauge({
            name: `${serviceName}_db_connections_active`,
            help: 'Number of active database connections'
        });

        this.businessMetrics = new promClient.Counter({
            name: `${serviceName}_business_operations_total`,
            help: 'Total number of business operations',
            labelNames: ['operation', 'status']
        });
    }

    // Middleware Express para coletar métricas HTTP
    getHttpMetricsMiddleware() {
        return (req, res, next) => {
            const start = Date.now();

            res.on('finish', () => {
                const duration = Date.now() - start;
                const route = req.route ? req.route.path : req.path;

                this.httpRequestDuration
                    .labels(req.method, route, res.statusCode)
                    .observe(duration);

                this.httpRequestTotal
                    .labels(req.method, route, res.statusCode)
                    .inc();
            });

            next();
        };
    }

    // Atualizar métrica de conexões do banco
    updateDatabaseConnections(count) {
        this.databaseConnectionPool.set(count);
    }

    // Incrementar métricas de negócio
    incrementBusinessMetric(operation, status = 'success') {
        this.businessMetrics.labels(operation, status).inc();
    }

    // Endpoint para Prometheus coletar métricas
    getMetricsEndpoint() {
        return async (req, res) => {
            try {
                res.set('Content-Type', promClient.register.contentType);
                const metrics = await promClient.register.metrics();
                res.end(metrics);
            } catch (error) {
                res.status(500).end(error);
            }
        };
    }

    // Limpar registry (para testes)
    clearMetrics() {
        promClient.register.clear();
    }
}

module.exports = MetricsService;
