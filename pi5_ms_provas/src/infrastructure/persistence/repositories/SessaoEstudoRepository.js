import prisma from './prismaClient.js';

export class SessaoEstudoRepository {
    async create(data) {
        const createData = {
            userId: data.userId,
            conteudo: data.conteudo,
            topicos: data.topicos,
            materia: {
                connect: { id: data.materiaId }
            }
        };        // Campos para sistema de XP diferenciado
        if (data.isAgendada !== undefined) {
            createData.isAgendada = data.isAgendada;
        }

        if (data.cumpriuPrazo !== undefined) {
            createData.cumpriuPrazo = data.cumpriuPrazo;
        }

        if (data.horarioAgendado) {
            createData.horarioAgendado = new Date(data.horarioAgendado);
        }

        if (data.metaTempo !== undefined) {
            createData.metaTempo = data.metaTempo;
        }

        // Campos para questões
        if (data.questoesAcertadas !== undefined) {
            createData.questoesAcertadas = data.questoesAcertadas;
        }

        if (data.totalQuestoes !== undefined) {
            createData.totalQuestoes = data.totalQuestoes;
        }

        if (data.finalizada !== undefined) {
            createData.finalizada = data.finalizada;
        }

        // Adicionar tempoInicio apenas se fornecido
        if (data.tempoInicio || data.dataInicio) {
            createData.tempoInicio = new Date(data.tempoInicio || data.dataInicio);
        }

        // Adicionar tempoFim apenas se fornecido
        if (data.tempoFim || data.dataFim) {
            createData.tempoFim = new Date(data.tempoFim || data.dataFim);
        }

        // Conectar prova se fornecida
        if (data.provaId) {
            createData.prova = {
                connect: { id: data.provaId }
            };
        }

        // Conectar evento se fornecida
        if (data.eventoId) {
            createData.evento = {
                connect: { id: data.eventoId }
            };
        }

        return await prisma.sessaoEstudo.create({
            data: createData,
            include: {
                materia: true,
                prova: true,
                evento: true
            }
        });
    } async findAll() {
        return await prisma.sessaoEstudo.findMany({
            include: {
                materia: true,
                prova: true,
                evento: true
            }
        });
    }

    async findById(id) {
        return await prisma.sessaoEstudo.findUnique({
            where: { id },
            include: {
                materia: true,
                prova: true,
                evento: true
            }
        });
    } async update(id, data) {
        const updateData = {};        // Copiar campos simples
        const simpleFields = ['conteudo', 'topicos', 'finalizada', 'isAgendada', 'cumpriuPrazo', 'horarioAgendado', 'questoesAcertadas', 'totalQuestoes'];
        simpleFields.forEach(field => {
            if (data[field] !== undefined) {
                updateData[field] = data[field];
            }
        });

        // Converter datas apenas se fornecidas
        if (data.tempoInicio || data.dataInicio) {
            updateData.tempoInicio = new Date(data.tempoInicio || data.dataInicio);
        }

        if (data.tempoFim || data.dataFim) {
            updateData.tempoFim = new Date(data.tempoFim || data.dataFim);
        }

        // Converter horarioAgendado se fornecido
        if (data.horarioAgendado) {
            updateData.horarioAgendado = new Date(data.horarioAgendado);
        }

        // Atualizar relacionamento com matéria se fornecido
        if (data.materiaId) {
            updateData.materia = {
                connect: { id: data.materiaId }
            };
        }

        // Atualizar relacionamento com prova se fornecido
        if (data.provaId) {
            updateData.prova = {
                connect: { id: data.provaId }
            };
        } else if (data.provaId === null) {
            // Desconectar prova se explicitamente definido como null
            updateData.prova = {
                disconnect: true
            };
        }

        // Atualizar relacionamento com evento se fornecido
        if (data.eventoId) {
            updateData.evento = {
                connect: { id: data.eventoId }
            };
        } else if (data.eventoId === null) {
            // Desconectar evento se explicitamente definido como null
            updateData.evento = {
                disconnect: true
            };
        }

        return await prisma.sessaoEstudo.update({
            where: { id },
            data: updateData,
            include: {
                materia: true,
                prova: true,
                evento: true
            }
        });
    }

    async delete(id) {
        return await prisma.sessaoEstudo.delete({
            where: { id }
        });
    } async finalizar(id) {
        return await prisma.sessaoEstudo.update({
            where: { id },
            data: {
                tempoFim: new Date()
            },
            include: {
                materia: true,
                prova: true,
                evento: true
            }
        });
    }

    // 🔒 MÉTODO COM ISOLAMENTO POR USUÁRIO
    async findAllByUserId(userId, filters = {}) {
        const whereCondition = {
            userId: userId // Sempre filtrar por userId
        };        // Aplicar filtros adicionais se fornecidos
        if (filters.materiaId) {
            whereCondition.materiaId = filters.materiaId;
        }
        if (filters.provaId) {
            whereCondition.provaId = filters.provaId;
        }
        if (filters.finalizada !== undefined) {
            whereCondition.finalizada = filters.finalizada;
        }
        if (filters.isAgendada !== undefined) {
            whereCondition.isAgendada = filters.isAgendada;
        } return await prisma.sessaoEstudo.findMany({
            where: whereCondition,
            include: {
                materia: true,
                prova: true,
                evento: true
            },
            orderBy: {
                tempoInicio: 'desc'
            }
        });
    }

    async getEstatisticasPorProva(userId, provaId = null) {
        const whereCondition = {
            userId: userId,
            finalizada: true // Apenas sessões finalizadas
        };

        // Se provaId for fornecido, filtrar por essa prova específica
        if (provaId) {
            whereCondition.provaId = provaId;
        }

        // Buscar todas as sessões finalizadas do usuário (ou da prova específica)
        const sessoes = await prisma.sessaoEstudo.findMany({
            where: whereCondition,
            select: {
                id: true,
                tempoInicio: true,
                tempoFim: true,
                questoesAcertadas: true,
                totalQuestoes: true,
                provaId: true, prova: {
                    select: {
                        id: true,
                        titulo: true
                    }
                }
            }
        });

        // Calcular estatísticas agregadas
        let tempoTotalMinutos = 0;
        let totalSessoes = sessoes.length;
        let totalQuestoes = 0;
        let totalQuestoesAcertadas = 0;

        // Estatísticas por prova (se não filtrou por prova específica)
        const estatisticasPorProva = {};

        sessoes.forEach(sessao => {
            // Calcular tempo da sessão em minutos
            if (sessao.tempoInicio && sessao.tempoFim) {
                const inicio = new Date(sessao.tempoInicio);
                const fim = new Date(sessao.tempoFim);
                const duracaoMinutos = Math.floor((fim - inicio) / (1000 * 60));
                tempoTotalMinutos += duracaoMinutos;

                // Agrupar por prova se não filtrou por prova específica
                if (!provaId && sessao.provaId) {
                    if (!estatisticasPorProva[sessao.provaId]) {
                        estatisticasPorProva[sessao.provaId] = {
                            provaId: sessao.provaId,
                            nomeProva: sessao.prova?.titulo || 'Prova sem título',
                            tempoTotalMinutos: 0,
                            totalSessoes: 0,
                            totalQuestoes: 0,
                            totalQuestoesAcertadas: 0
                        };
                    }
                    estatisticasPorProva[sessao.provaId].tempoTotalMinutos += duracaoMinutos;
                    estatisticasPorProva[sessao.provaId].totalSessoes += 1;
                    estatisticasPorProva[sessao.provaId].totalQuestoes += sessao.totalQuestoes || 0;
                    estatisticasPorProva[sessao.provaId].totalQuestoesAcertadas += sessao.questoesAcertadas || 0;
                }
            }

            // Somar questões globais
            totalQuestoes += sessao.totalQuestoes || 0;
            totalQuestoesAcertadas += sessao.questoesAcertadas || 0;
        });

        // Calcular desempenho geral
        const desempenhoGeral = totalQuestoes > 0 ? (totalQuestoesAcertadas / totalQuestoes) * 100 : 0;

        // Calcular desempenho por prova
        Object.values(estatisticasPorProva).forEach(estatistica => {
            estatistica.desempenho = estatistica.totalQuestoes > 0
                ? (estatistica.totalQuestoesAcertadas / estatistica.totalQuestoes) * 100
                : 0;
        });

        return {
            geral: {
                tempoTotalMinutos,
                totalSessoes,
                totalQuestoes,
                totalQuestoesAcertadas,
                desempenho: desempenhoGeral
            },
            porProva: Object.values(estatisticasPorProva)
        };
    }
}