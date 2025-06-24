import { IProvaRepository } from '../../../domain/repositories/IProvaRepository.js';
import prisma from './prismaClient.js';

export class ProvaRepository extends IProvaRepository {    // Helper para adicionar campos calculados
    _addComputedFields(prova) {
        if (!prova) return prova;

        // Campos removidos: percentualAcerto e foiRealizada não são mais calculados
        // Estes dados agora estão nas sessões de estudo

        return prova;
    }

    // Helper para processar lista de provas
    _processProvas(provas) {
        return provas.map(prova => this._addComputedFields(prova));
    } async create(prova) {
        // Criar dados básicos da prova (sem os campos removidos)
        const provaData = {
            id: prova.id,
            titulo: prova.titulo,
            descricao: prova.descricao,
            data: prova.data,
            horario: prova.horario,
            local: prova.local,
            userId: prova.userId,
            filtros: prova.filtros,
            createdAt: prova.createdAt,
            updatedAt: prova.updatedAt
        };

        // Só incluir materiaId se existir (compatibilidade)
        if (prova.materiaId) {
            provaData.materiaId = prova.materiaId;
        }

        const result = await prisma.prova.create({
            data: provaData,
            include: {
                materia: true,
                provaMaterias: {
                    include: {
                        materia: true
                    }
                }
            }
        });

        // Se houver matérias para vincular, criar os relacionamentos
        if (prova.materias && prova.materias.length > 0) {
            await this.addMateriasToProva(prova.id, prova.materias.map(m => m.id || m));
            // Buscar novamente com as matérias incluídas
            return this.findById(prova.id);
        }

        return this._addComputedFields(result);
    } async findById(id) {
        const result = await prisma.prova.findUnique({
            where: { id },
            include: {
                materia: true,
                provaMaterias: {
                    include: {
                        materia: true
                    }
                }
            }
        }); if (result) {
            // Adicionar array de matérias para compatibilidade
            result.materias = result.provaMaterias.map(pm => pm.materia);
            // Adicionar array de IDs das matérias
            result.materiasIds = result.provaMaterias.map(pm => pm.materiaId);
        }
        return this._addComputedFields(result);
    } async findAll() {
        const results = await prisma.prova.findMany({
            include: {
                materia: true,
                provaMaterias: {
                    include: {
                        materia: true
                    }
                }
            }
        });
        results.forEach(result => {
            result.materias = result.provaMaterias.map(pm => pm.materia);
            result.materiasIds = result.provaMaterias.map(pm => pm.materiaId);
        });
        return this._processProvas(results);
    } async findByUserId(userId) {
        const results = await prisma.prova.findMany({
            where: { userId },
            include: {
                materia: true,
                provaMaterias: {
                    include: {
                        materia: true
                    }
                }
            }
        });
        results.forEach(result => {
            result.materias = result.provaMaterias.map(pm => pm.materia);
            result.materiasIds = result.provaMaterias.map(pm => pm.materiaId);
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
    } async update(id, data) {
        const updateData = {};

        if (data.titulo !== undefined) updateData.titulo = data.titulo;
        if (data.descricao !== undefined) updateData.descricao = data.descricao;
        if (data.data !== undefined) updateData.data = data.data;
        if (data.horario !== undefined) updateData.horario = data.horario;
        if (data.local !== undefined) updateData.local = data.local;
        if (data.materiaId !== undefined) updateData.materiaId = data.materiaId;
        if (data.filtros !== undefined) updateData.filtros = data.filtros;
        // Campos removidos: totalQuestoes e acertos não são mais atualizados

        updateData.updatedAt = new Date();

        const result = await prisma.prova.update({
            where: { id },
            data: updateData,
            include: {
                materia: true,
                provaMaterias: {
                    include: {
                        materia: true
                    }
                }
            }
        }); if (result) {
            result.materias = result.provaMaterias.map(pm => pm.materia);
            result.materiasIds = result.provaMaterias.map(pm => pm.materiaId);
        }

        // Se houver novas matérias para atualizar
        if (data.materias !== undefined) {
            await this.updateMateriasToProva(id, data.materias.map(m => m.id || m));
            return this.findById(id);
        }

        return this._addComputedFields(result);
    } async delete(id) {
        return await prisma.prova.delete({
            where: { id }
        });
    }

    // Métodos para gerenciar relacionamento many-to-many
    async addMateriasToProva(provaId, materiaIds) {
        const data = materiaIds.map(materiaId => ({
            provaId,
            materiaId
        }));

        return await prisma.provaMateria.createMany({
            data,
            skipDuplicates: true
        });
    }

    async removeMateriaFromProva(provaId, materiaId) {
        return await prisma.provaMateria.deleteMany({
            where: {
                provaId,
                materiaId
            }
        });
    }

    async updateMateriasToProva(provaId, materiaIds) {
        // Remove todas as matérias existentes
        await prisma.provaMateria.deleteMany({
            where: { provaId }
        });

        // Adiciona as novas matérias
        if (materiaIds.length > 0) {
            await this.addMateriasToProva(provaId, materiaIds);
        }
    }

    async getMateriasFromProva(provaId) {
        const provaMateria = await prisma.provaMateria.findMany({
            where: { provaId },
            include: { materia: true }
        });

        return provaMateria.map(pm => pm.materia);
    } async search(filtros) {
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

    async updateStatus(id, status) {
        const result = await prisma.prova.update({
            where: { id },
            data: {
                status,
                updatedAt: new Date()
            },
            include: {
                materia: true,
                provaMaterias: {
                    include: {
                        materia: true
                    }
                }
            }
        });

        return this._addComputedFields(result);
    }
}