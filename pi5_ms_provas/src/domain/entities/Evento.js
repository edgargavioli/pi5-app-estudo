import crypto from 'crypto';

export class Evento {
    constructor(id, titulo, descricao, tipo, data, horario, local, materiaId, urlInscricao, taxaInscricao, dataLimiteInscricao) {
        this.id = id;
        this.titulo = titulo;
        this.descricao = descricao;
        this.tipo = tipo;
        this.data = data;
        this.horario = horario;
        this.local = local;
        this.materiaId = materiaId;
        this.urlInscricao = urlInscricao;
        this.taxaInscricao = taxaInscricao;
        this.dataLimiteInscricao = dataLimiteInscricao;
        this.createdAt = new Date();
        this.updatedAt = new Date();
    }

    static create(titulo, descricao, tipo, data, horario, local, materiaId = null, urlInscricao = null, taxaInscricao = null, dataLimiteInscricao = null) {
        if (!titulo || titulo.trim().length === 0) {
            throw new Error('Título do evento é obrigatório');
        }
        if (!tipo) {
            throw new Error('Tipo do evento é obrigatório');
        }
        if (!data) {
            throw new Error('Data do evento é obrigatória');
        }
        if (!horario) {
            throw new Error('Horário do evento é obrigatório');
        }
        if (!local || local.trim().length === 0) {
            throw new Error('Local do evento é obrigatório');
        }

        return new Evento(
            crypto.randomUUID(),
            titulo.trim(),
            descricao ? descricao.trim() : null,
            tipo,
            new Date(data),
            new Date(horario),
            local.trim(),
            materiaId,
            urlInscricao,
            taxaInscricao,
            dataLimiteInscricao ? new Date(dataLimiteInscricao) : null
        );
    }

    update(titulo, descricao, tipo, data, horario, local, materiaId, urlInscricao, taxaInscricao, dataLimiteInscricao) {
        if (titulo !== undefined) {
            if (!titulo || titulo.trim().length === 0) {
                throw new Error('Título do evento não pode ser vazio');
            }
            this.titulo = titulo.trim();
        }
        if (descricao !== undefined) {
            this.descricao = descricao ? descricao.trim() : null;
        }
        if (tipo !== undefined) {
            if (!tipo) {
                throw new Error('Tipo do evento não pode ser vazio');
            }
            this.tipo = tipo;
        }
        if (data !== undefined) {
            this.data = new Date(data);
        }
        if (horario !== undefined) {
            this.horario = new Date(horario);
        }
        if (local !== undefined) {
            if (!local || local.trim().length === 0) {
                throw new Error('Local do evento não pode ser vazio');
            }
            this.local = local.trim();
        }
        if (materiaId !== undefined) {
            this.materiaId = materiaId;
        }
        if (urlInscricao !== undefined) {
            this.urlInscricao = urlInscricao;
        }
        if (taxaInscricao !== undefined) {
            this.taxaInscricao = taxaInscricao;
        }
        if (dataLimiteInscricao !== undefined) {
            this.dataLimiteInscricao = dataLimiteInscricao ? new Date(dataLimiteInscricao) : null;
        }
        this.updatedAt = new Date();
    }
} 