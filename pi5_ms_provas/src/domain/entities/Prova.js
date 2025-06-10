import crypto from 'crypto';

export class Prova {
    constructor(id, titulo, descricao, data, horario, local, materiaId, filtros = null, totalQuestoes = null, acertos = null) {
        this.id = id;
        this.titulo = titulo;
        this.descricao = descricao;
        this.data = data;
        this.horario = horario;
        this.local = local;
        this.materiaId = materiaId;
        this.filtros = filtros;
        this.totalQuestoes = totalQuestoes;
        this.acertos = acertos;
        this.createdAt = new Date();
        this.updatedAt = new Date();
    }

    static create(titulo, descricao, data, horario, local, materiaId, filtros = null, totalQuestoes = null) {
        if (!titulo) {
            throw new Error('Título da prova é obrigatório');
        }
        if (!data) {
            throw new Error('Data da prova é obrigatória');
        }
        if (!horario) {
            throw new Error('Horário da prova é obrigatório');
        }
        if (!local || local.trim().length === 0) {
            throw new Error('Local da prova é obrigatório');
        }
        if (!materiaId) {
            throw new Error('Matéria é obrigatória');
        }
        if (totalQuestoes !== null && totalQuestoes <= 0) {
            throw new Error('Número total de questões deve ser maior que zero');
        }

        return new Prova(
            crypto.randomUUID(),
            titulo,
            descricao,
            new Date(data),
            new Date(horario),
            local.trim(),
            materiaId,
            filtros,
            totalQuestoes
        );
    }

    update(titulo, descricao, data, horario, local, materiaId, filtros, totalQuestoes, acertos) {
        if (titulo) this.titulo = titulo;
        if (descricao !== undefined) this.descricao = descricao;
        if (data) this.data = new Date(data);
        if (horario) this.horario = new Date(horario);
        if (local) {
            if (local.trim().length === 0) {
                throw new Error('Local da prova não pode ser vazio');
            }
            this.local = local.trim();
        }
        if (materiaId) this.materiaId = materiaId;
        if (filtros !== undefined) this.filtros = filtros;
        if (totalQuestoes !== undefined) {
            if (totalQuestoes !== null && totalQuestoes <= 0) {
                throw new Error('Número total de questões deve ser maior que zero');
            }
            this.totalQuestoes = totalQuestoes;
        }
        if (acertos !== undefined) {
            if (acertos !== null) {
                if (acertos < 0) {
                    throw new Error('Número de acertos não pode ser negativo');
                }
                if (this.totalQuestoes && acertos > this.totalQuestoes) {
                    throw new Error('Número de acertos não pode ser maior que o total de questões');
                }
            }
            this.acertos = acertos;
        }
        
        this.updatedAt = new Date();
    }

    get percentualAcerto() {
        if (this.totalQuestoes && this.acertos !== null) {
            return Math.round((this.acertos / this.totalQuestoes) * 100);
        }
        return null;
    }

    get foiRealizada() {
        return this.acertos !== null;
    }
} 