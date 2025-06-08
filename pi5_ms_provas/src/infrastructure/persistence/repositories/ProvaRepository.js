import { IProvaRepository } from '../../../domain/repositories/IProvaRepository.js';
import prisma from './prismaClient.js';

export class ProvaRepository extends IProvaRepository {
    // Helper para adicionar campos calculados
    _addComputedFields(prova) {
        if (!prova) return prova;
        
        // Adicionar percentualAcerto se tiver dados para calcular
        if (prova.totalQuestoes && prova.acertos !== null) {
            prova.percentualAcerto = Math.round((prova.acertos / prova.totalQuestoes) * 100);
        } else {
            prova.percentualAcerto = null;
        }
        
        // Adicionar foiRealizada
        prova.foiRealizada = prova.acertos !== null;
        
        return prova;
    }

    // Helper para processar lista de provas
    _processProvas(provas) {
        return provas.map(prova => this._addComputedFields(prova));
    }

    async create(prova) {
        const result = await prisma.prova.create({
            data: {
                id: prova.id,
                titulo: prova.titulo,
                descricao: prova.descricao,
                data: prova.data,
                horario: prova.horario,
                local: prova.local,
                materiaId: prova.materiaId,
                userId: prova.userId,
                filtros: prova.filtros,
                totalQuestoes: prova.totalQuestoes,
                acertos: prova.acertos,
                createdAt: prova.createdAt,
                updatedAt: prova.updatedAt
            },
            include: { materia: true }
        });
        return this._addComputedFields(result);
    }

    async findById(id) {
        const result = await prisma.prova.findUnique({
            where: { id },
            include: { materia: true }
        });
        return this._addComputedFields(result);
    }

    async findAll() {
        const results = await prisma.prova.findMany({
            include: { materia: true }
        });
        return this._processProvas(results);
    }

    async findByUserId(userId) {
        const results = await prisma.prova.findMany({
            where: { userId },
            include: { materia: true }
        });
        return this._processProvas(results);
    }

    async findByMateriaId(materiaId) {
        const results = await prisma.prova.findMany({
            where: { materiaId },
            include: { materia: true }
        });
        return this._processProvas(results);
    }

    async findByTitulo(titulo) {
        const results = await prisma.prova.findMany({
            where: { 
                titulo: {
                    contains: titulo,
                    mode: 'insensitive'
                }
            },
            include: { materia: true }
        });
        return this._processProvas(results);
    }

    async update(id, data) {
        const updateData = {};
        
        if (data.titulo !== undefined) updateData.titulo = data.titulo;
        if (data.descricao !== undefined) updateData.descricao = data.descricao;
        if (data.data !== undefined) updateData.data = data.data;
        if (data.horario !== undefined) updateData.horario = data.horario;
        if (data.local !== undefined) updateData.local = data.local;
        if (data.materiaId !== undefined) updateData.materiaId = data.materiaId;
        if (data.filtros !== undefined) updateData.filtros = data.filtros;
        if (data.totalQuestoes !== undefined) updateData.totalQuestoes = data.totalQuestoes;
        if (data.acertos !== undefined) updateData.acertos = data.acertos;
        
        updateData.updatedAt = new Date();

        const result = await prisma.prova.update({
            where: { id },
            data: updateData,
            include: { materia: true }
        });
        return this._addComputedFields(result);
    }

    async delete(id) {
        return await prisma.prova.delete({
            where: { id }
        });
    }

    async search(filtros) {
        const where = {};
        
        if (filtros.titulo) where.titulo = { 
            contains: filtros.titulo, 
            mode: 'insensitive' 
        };
        if (filtros.materiaId) where.materiaId = filtros.materiaId;
        if (filtros.dataInicio) where.data = { gte: new Date(filtros.dataInicio) };
        if (filtros.dataFim) where.data = { ...where.data, lte: new Date(filtros.dataFim) };
        
        const results = await prisma.prova.findMany({
            where,
            include: { materia: true }
        });
        return this._processProvas(results);
    }
} 