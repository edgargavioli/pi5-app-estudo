/**
 * Middleware para adicionar cabeçalhos úteis nas respostas
 * Ajuda com debugging e fornece informações adicionais para o cliente
 */

const addResponseHeaders = (req, res, next) => {
    // Adicionar ID de requisição único se não existir
    if (!req.headers['x-request-id']) {
        req.headers['x-request-id'] = `req_${Date.now()}_${Math.random().toString(36).substring(2, 8)}`;
    }

    // Adicionar cabeçalhos de resposta úteis
    res.set({
        'X-Request-ID': req.headers['x-request-id'],
        'X-Timestamp': new Date().toISOString(),
        'X-API-Version': process.env.API_VERSION || '1.0.0',
        'X-Environment': process.env.NODE_ENV || 'development',
        'X-Service': 'user-service'
    });

    // Em desenvolvimento, adicionar informações extras
    if (process.env.NODE_ENV === 'development') {
        res.set({
            'X-Debug-Method': req.method,
            'X-Debug-URL': req.originalUrl,
            'X-Debug-User-Agent': req.get('User-Agent') || 'unknown'
        });
    }

    next();
};

module.exports = addResponseHeaders;
