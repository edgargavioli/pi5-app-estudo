import crypto from 'crypto';

export class Prova {
    constructor(id, titulo, descricao, data, horario, local, materiaId = null, filtros = null, materias = []) {
        this.id = id;
        this.titulo = titulo;
        this.descricao = descricao;
        this.data = data;
        this.horario = horario;
        this.local = local;
        this.materiaId = materiaId; // Mantido por compatibilidade
        this.materias = materias; // Array de matérias para relacionamento many-to-many
        this.filtros = filtros;
        // Campos removidos: totalQuestoes e acertos agora estão nas sessões
        this.createdAt = new Date();
        this.updatedAt = new Date();
    }

    static create(titulo, descricao, data, horario, local, materiaId = null, filtros = null, materias = []) {
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

        return new Prova(
            crypto.randomUUID(),
            titulo,
            descricao,
            new Date(data),
            new Date(horario),
            local.trim(),
            materiaId,
            filtros,
            materias
        );
    } update(titulo, descricao, data, horario, local, materiaId, filtros, materias) {
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
        if (materias !== undefined) this.materias = materias;
        if (filtros !== undefined) this.filtros = filtros;
        // Campos removidos: totalQuestoes e acertos não são mais atualizados

        this.updatedAt = new Date();
    }

    // Getters removidos: percentualAcerto e foiRealizada não existem mais
    // Estes dados agora estão nas sessões de estudo
}