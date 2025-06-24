const ProvaRepository = require('../../../infrastructure/persistence/repositories/ProvaRepository');

class ObterEstatisticasProvasUseCase {
    constructor() {
        this.provaRepository = new ProvaRepository();
    }

    async execute(userId) {
        try {
            // Buscar todas as provas do usuário
            const provas = await this.provaRepository.buscarPorUsuario(userId);

            // Calcular estatísticas por status
            const total = provas.length;
            const pendentes = provas.filter(prova => prova.status === 'PENDENTE').length;
            const concluidas = provas.filter(prova => prova.status === 'CONCLUIDA').length;
            const canceladas = provas.filter(prova => prova.status === 'CANCELADA').length;

            // Calcular percentuais
            const percentualConcluidas = total > 0 ? (concluidas / total) * 100 : 0;
            const percentualPendentes = total > 0 ? (pendentes / total) * 100 : 0;
            const percentualCanceladas = total > 0 ? (canceladas / total) * 100 : 0;

            return {
                total,
                pendentes,
                concluidas,
                canceladas,
                percentualConcluidas: Math.round(percentualConcluidas * 100) / 100,
                percentualPendentes: Math.round(percentualPendentes * 100) / 100,
                percentualCanceladas: Math.round(percentualCanceladas * 100) / 100,
            };
        } catch (error) {
            console.error('❌ Erro ao obter estatísticas das provas:', error);
            throw new Error('Erro ao obter estatísticas das provas');
        }
    }
}

module.exports = ObterEstatisticasProvasUseCase;
