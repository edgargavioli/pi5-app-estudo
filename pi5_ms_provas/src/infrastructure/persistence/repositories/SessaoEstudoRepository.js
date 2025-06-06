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
        };

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

        // Conectar evento se fornecido
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
    }

    async findAll() {
        return await prisma.sessaoEstudo.findMany({
            include: {
                materia: true,
                prova: true
            }
        });
    }

    async findById(id) {
        return await prisma.sessaoEstudo.findUnique({
            where: { id },
            include: {
                materia: true,
                prova: true
            }
        });
    }

    async update(id, data) {
        const updateData = { ...data };

        // Converter datas apenas se fornecidas
        if (data.tempoInicio || data.dataInicio) {
            updateData.tempoInicio = new Date(data.tempoInicio || data.dataInicio);
        }

        if (data.tempoFim || data.dataFim) {
            updateData.tempoFim = new Date(data.tempoFim || data.dataFim);
        }

        // Remover campos de data antigos se existirem
        delete updateData.dataInicio;
        delete updateData.dataFim;

        return await prisma.sessaoEstudo.update({
            where: { id },
            data: updateData,
            include: {
                materia: true,
                prova: true
            }
        });
    }

    async delete(id) {
        return await prisma.sessaoEstudo.delete({
            where: { id }
        });
    }

    async finalizar(id) {
        return await prisma.sessaoEstudo.update({
            where: { id },
            data: {
                tempoFim: new Date()
            },
            include: {
                materia: true,
                prova: true
            }
        });
    }

    // 🔒 MÉTODO COM ISOLAMENTO POR USUÁRIO
    async findAllByUserId(userId, filters = {}) {
        const whereCondition = {
            userId: userId // Sempre filtrar por userId
        };

        // Aplicar filtros adicionais se fornecidos
        if (filters.materiaId) {
            whereCondition.materiaId = filters.materiaId;
        }
        if (filters.provaId) {
            whereCondition.provaId = filters.provaId;
        }
        if (filters.finalizada !== undefined) {
            whereCondition.finalizada = filters.finalizada;
        }

        return await prisma.sessaoEstudo.findMany({
            where: whereCondition,
            include: {
                materia: true,
                prova: true
            },
            orderBy: {
                tempoInicio: 'desc'
            }
        });
    }
} 