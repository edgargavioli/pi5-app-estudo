import crypto from 'crypto';

export class SessaoEstudo {
    constructor(id, materiaId, provaId, conteudo, topicos, tempoInicio, tempoFim = null) {
        this.id = id;
        this.materiaId = materiaId;
        this.provaId = provaId;
        this.conteudo = conteudo;
        this.topicos = topicos;
        this.tempoInicio = tempoInicio;
        this.tempoFim = tempoFim;
        this.createdAt = new Date();
        this.updatedAt = new Date();
    }

    static create(materiaId, provaId, conteudo, topicos, tempoInicio = null) {
        if (!materiaId) {
            throw new Error('Matéria é obrigatória');
        }
        if (!conteudo || conteudo.trim().length === 0) {
            throw new Error('Conteúdo é obrigatório');
        }
        if (!topicos || !Array.isArray(topicos) || topicos.length === 0) {
            throw new Error('Tópicos são obrigatórios e devem ser um array não vazio');
        }

        return new SessaoEstudo(
            crypto.randomUUID(),
            materiaId,
            provaId,
            conteudo.trim(),
            topicos,
            tempoInicio
        );
    }

    finalizar() {
        if (this.tempoFim) {
            throw new Error('Sessão já foi finalizada');
        }
        this.tempoFim = new Date();
        this.updatedAt = new Date();
    }

    update(conteudo, topicos) {
        if (conteudo !== null && conteudo !== undefined) {
            if (conteudo.trim().length === 0) {
                throw new Error('Conteúdo não pode ser vazio');
            }
            this.conteudo = conteudo.trim();
        }
        if (topicos) {
            if (!Array.isArray(topicos) || topicos.length === 0) {
                throw new Error('Tópicos devem ser um array não vazio');
            }
            this.topicos = topicos;
        }
        this.updatedAt = new Date();
    }

    getDuracao() {
        if (!this.tempoFim || !this.tempoInicio) {
            return null;
        }
        return this.tempoFim - this.tempoInicio;
    }
} 