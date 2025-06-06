import prisma from './prismaClient.js';

export class EventoRepository {
    async create(data) {
        const createData = {
            titulo: data.titulo,
            descricao: data.descricao,
            tipo: data.tipo,
            data: new Date(data.data),
            horario: new Date(data.horario),
            local: data.local,
            userId: data.userId,
            urlInscricao: data.urlInscricao,
            taxaInscricao: data.taxaInscricao,
            dataLimiteInscricao: data.dataLimiteInscricao ? new Date(data.dataLimiteInscricao) : null
        };

        // Conectar matéria se fornecida
        if (data.materiaId) {
            createData.materia = {
                connect: { id: data.materiaId }
            };
        }

        return await prisma.evento.create({
            data: createData,
            include: {
                materia: true
            }
        });
    }

    async findById(id) {
        return await prisma.evento.findUnique({
            where: { id },
            include: {
                materia: true
            }
        });
    }

    async findByUserId(userId) {
        return await prisma.evento.findMany({
            where: { userId },
            include: {
                materia: true
            },
            orderBy: { data: 'asc' }
        });
    }

    async findByUserIdOrPublic(userId) {
        return await prisma.evento.findMany({
            where: {
                OR: [
                    { userId },
                    { userId: null } // Eventos públicos
                ]
            },
            include: {
                materia: true
            },
            orderBy: { data: 'asc' }
        });
    }

    async update(id, data) {
        const updateData = {};
        
        if (data.titulo !== undefined) updateData.titulo = data.titulo;
        if (data.descricao !== undefined) updateData.descricao = data.descricao;
        if (data.tipo !== undefined) updateData.tipo = data.tipo;
        if (data.data !== undefined) updateData.data = new Date(data.data);
        if (data.horario !== undefined) updateData.horario = new Date(data.horario);
        if (data.local !== undefined) updateData.local = data.local;
        if (data.urlInscricao !== undefined) updateData.urlInscricao = data.urlInscricao;
        if (data.taxaInscricao !== undefined) updateData.taxaInscricao = data.taxaInscricao;
        if (data.dataLimiteInscricao !== undefined) {
            updateData.dataLimiteInscricao = data.dataLimiteInscricao ? new Date(data.dataLimiteInscricao) : null;
        }

        return await prisma.evento.update({
            where: { id },
            data: updateData,
            include: {
                materia: true
            }
        });
    }

    async delete(id) {
        return await prisma.evento.delete({
            where: { id }
        });
    }
} 