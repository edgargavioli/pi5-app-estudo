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