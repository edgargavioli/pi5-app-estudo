export class GetEstatisticasSessaoUseCase {
    constructor(sessaoEstudoRepository) {
        this.sessaoEstudoRepository = sessaoEstudoRepository;
    }

    async execute(userId, provaId = null) {
        if (!userId) {
            throw new Error('ID do usuário é obrigatório');
        }

        try {
            const estatisticas = await this.sessaoEstudoRepository.getEstatisticasPorProva(userId, provaId);

            // Formatar dados para retorno mais amigável
            const resultado = {
                userId,
                provaId: provaId || null,
                tempoTotalEstudado: {
                    minutos: estatisticas.geral.tempoTotalMinutos,
                    formatado: this._formatarTempo(estatisticas.geral.tempoTotalMinutos)
                },
                sessoes: {
                    total: estatisticas.geral.totalSessoes
                },
                questoes: {
                    total: estatisticas.geral.totalQuestoes,
                    acertadas: estatisticas.geral.totalQuestoesAcertadas,
                    desempenho: Math.round(estatisticas.geral.desempenho * 100) / 100 // Arredondar para 2 casas decimais
                }
            };

            // Se não filtrou por prova específica, incluir estatísticas por prova
            if (!provaId) {
                resultado.estatisticasPorProva = estatisticas.porProva.map(prova => ({
                    provaId: prova.provaId,
                    nomeProva: prova.nomeProva,
                    tempoTotalEstudado: {
                        minutos: prova.tempoTotalMinutos,
                        formatado: this._formatarTempo(prova.tempoTotalMinutos)
                    },
                    sessoes: {
                        total: prova.totalSessoes
                    },
                    questoes: {
                        total: prova.totalQuestoes,
                        acertadas: prova.totalQuestoesAcertadas,
                        desempenho: Math.round(prova.desempenho * 100) / 100
                    }
                }));
            }

            return resultado;
        } catch (error) {
            throw new Error(`Erro ao buscar estatísticas de sessões: ${error.message}`);
        }
    }

    _formatarTempo(minutos) {
        if (minutos < 60) {
            return `${minutos}min`;
        } else {
            const horas = Math.floor(minutos / 60);
            const minutosRestantes = minutos % 60;
            if (minutosRestantes === 0) {
                return `${horas}h`;
            } else {
                return `${horas}h ${minutosRestantes}min`;
            }
        }
    }
}
