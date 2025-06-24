import { logger } from '../../utils/logger.js';

export class GetEstatisticasProvaUseCase {
    constructor(provaRepository) {
        this.provaRepository = provaRepository;
    }

    async execute(userId) {
        try {
            logger.info('Obtendo estatísticas de provas', { userId });

            // Buscar todas as provas do usuário
            const provas = await this.provaRepository.findByUserId(userId);

            // Calcular estatísticas por status
            const estatisticas = {
                total: provas.length,
                pendentes: provas.filter(p => p.status === 'PENDENTE').length,
                concluidas: provas.filter(p => p.status === 'CONCLUIDA').length,
                canceladas: provas.filter(p => p.status === 'CANCELADA').length,
                porcentagemConcluidas: 0,
                porcentagemPendentes: 0,
                porcentagemCanceladas: 0,
                proximasProvas: [],
                provasRecentes: []
            };

            // Calcular porcentagens
            if (estatisticas.total > 0) {
                estatisticas.porcentagemConcluidas = (estatisticas.concluidas / estatisticas.total) * 100;
                estatisticas.porcentagemPendentes = (estatisticas.pendentes / estatisticas.total) * 100;
                estatisticas.porcentagemCanceladas = (estatisticas.canceladas / estatisticas.total) * 100;
            }

            // Próximas provas (pendentes, ordenadas por data)
            const hoje = new Date();
            const provasPendentes = provas
                .filter(p => p.status === 'PENDENTE')
                .filter(p => new Date(p.data) >= hoje)
                .sort((a, b) => new Date(a.data) - new Date(b.data))
                .slice(0, 5);

            estatisticas.proximasProvas = provasPendentes.map(p => ({
                id: p.id,
                titulo: p.titulo,
                data: p.data,
                diasRestantes: Math.ceil((new Date(p.data) - hoje) / (1000 * 60 * 60 * 24))
            }));

            // Provas recentemente concluídas (últimas 5)
            const provasConcluidas = provas
                .filter(p => p.status === 'CONCLUIDA')
                .sort((a, b) => new Date(b.updatedAt) - new Date(a.updatedAt))
                .slice(0, 5);

            estatisticas.provasRecentes = provasConcluidas.map(p => ({
                id: p.id,
                titulo: p.titulo,
                dataProva: p.data,
                dataConclusao: p.updatedAt
            }));

            logger.info('Estatísticas de provas calculadas', {
                userId,
                total: estatisticas.total,
                concluidas: estatisticas.concluidas,
                pendentes: estatisticas.pendentes
            });

            return estatisticas;
        } catch (error) {
            logger.error('Erro ao obter estatísticas de provas', {
                userId,
                error: error.message
            });
            throw error;
        }
    }
}
