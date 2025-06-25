import crypto from 'crypto';

export class Materia {
    constructor(id, nome, disciplina) {
        this.id = id;
        this.nome = nome;
        this.disciplina = disciplina;
        this.createdAt = new Date();
        this.updatedAt = new Date();
    }

    static create(nome, disciplina) {
        if (!nome || nome.trim().length === 0) {
            throw new Error('Nome da matéria é obrigatório');
        }
        if (!disciplina || disciplina.trim().length === 0) {
            throw new Error('Disciplina é obrigatória');
        }
        return new Materia(
            crypto.randomUUID(),
            nome.trim(),
            disciplina.trim()
        );
    }

    update(nome, disciplina) {
        if (nome) {
            if (nome.trim().length === 0) {
                throw new Error('Nome da matéria não pode ser vazio');
            }
            this.nome = nome.trim();
        }
        if (disciplina) {
            if (disciplina.trim().length === 0) {
                throw new Error('Disciplina não pode ser vazia');
            }
            this.disciplina = disciplina.trim();
        }
        this.updatedAt = new Date();
    }
} 