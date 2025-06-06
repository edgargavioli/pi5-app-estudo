import { Materia } from '../../../domain/entities/Materia.js';

export class CreateMateriaUseCase {
    constructor(materiaRepository) {
        this.materiaRepository = materiaRepository;
    }

    async execute(materiaData, userId) {
        const { nome, descricao } = materiaData;
        
        if (!nome) {
            throw new Error('Nome é obrigatório');
        }

        if (!userId) {
            throw new Error('UserId é obrigatório');
        }

        const materia = await this.materiaRepository.create({
            nome,
            descricao,
            userId
        });

        return materia;
    }
} 