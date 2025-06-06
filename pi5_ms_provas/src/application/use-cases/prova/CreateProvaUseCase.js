import { Prova } from '../../../domain/entities/Prova.js';

export class CreateProvaUseCase {
    constructor(provaRepository, materiaRepository) {
        this.provaRepository = provaRepository;
        this.materiaRepository = materiaRepository;
    }

    async execute(provaData, userId) {
        const { titulo, descricao, data, horario, local, materiaId, filtros = null, totalQuestoes = null } = provaData;
        
        if (!userId) {
            throw new Error('UserId é obrigatório');
        }

        // Verifica se a matéria existe e pertence ao usuário
        const materia = await this.materiaRepository.findById(materiaId);
        if (!materia) {
            throw new Error('Matéria não encontrada');
        }

        if (materia.userId !== userId) {
            throw new Error('Matéria não encontrada');
        }

        const prova = Prova.create(titulo, descricao, data, horario, local, materiaId, filtros, totalQuestoes);
        
        // Adicionar userId à prova
        const provaComUserId = {
            ...prova,
            userId
        };
        
        return await this.provaRepository.create(provaComUserId);
    }
} 