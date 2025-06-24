import prisma from './prismaClient.js';

export class MateriaRepository {
    async create(data) {
        return await prisma.materia.create({
            data
        });
    }

    async findById(id) {
        return await prisma.materia.findUnique({
            where: { id }
        });
    }

    async findAll() {
        return await prisma.materia.findMany();
    }

    async findByUserId(userId) {
        return await prisma.materia.findMany({
            where: { userId }
        });
    }    /**
     * Busca todas as matérias não utilizadas de um usuário
     * (matérias que não possuem nenhuma prova associada)
     * @param {string} userId - ID do usuário
     * @returns {Promise<Array>} Lista de matérias sem provas associadas
     */
    async findUnusedByUserId(userId) {
        return await prisma.materia.findMany({
            where: {
                userId,
                AND: [
                    {
                        provas: {
                            none: {}
                        }
                    },
                    {
                        provaMaterias: {
                            none: {}
                        }
                    }
                ]
            }
        });
    }

    /**
     * Busca todas as matérias utilizadas de um usuário
     * (matérias que possuem pelo menos uma prova associada)
     * @param {string} userId - ID do usuário
     * @returns {Promise<Array>} Lista de matérias com provas associadas (incluindo dados das provas)
     */
    async findUsedByUserId(userId) {
        return await prisma.materia.findMany({
            where: {
                userId,
                OR: [
                    {
                        provas: {
                            some: {}
                        }
                    },
                    {
                        provaMaterias: {
                            some: {}
                        }
                    }
                ]
            },
            include: {
                provas: {
                    select: {
                        id: true,
                        titulo: true,
                        data: true
                    }
                },
                provaMaterias: {
                    include: {
                        prova: {
                            select: {
                                id: true,
                                titulo: true,
                                data: true
                            }
                        }
                    }
                }
            }
        });
    }

    async update(id, data) {
        return await prisma.materia.update({
            where: { id },
            data
        });
    }

    async delete(id) {
        return await prisma.materia.delete({
            where: { id }
        });
    }
}