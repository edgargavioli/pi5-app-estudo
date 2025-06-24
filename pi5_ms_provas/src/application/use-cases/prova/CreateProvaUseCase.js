import { Prova } from '../../../domain/entities/Prova.js';

export class CreateProvaUseCase {
    constructor(provaRepository, materiaRepository) {
        this.provaRepository = provaRepository;
        this.materiaRepository = materiaRepository;
    } async execute(provaData, userId) {
        const { titulo, descricao, data, horario, local, materiaId, materias = [], filtros = null } = provaData;

        if (!userId) {
            throw new Error('UserId é obrigatório');
        }

        // Verifica se a matéria existe e pertence ao usuário (apenas se materiaId foi fornecido - compatibilidade)
        if (materiaId) {
            const materia = await this.materiaRepository.findById(materiaId);
            if (!materia) {
                throw new Error('Matéria não encontrada');
            }

            if (materia.userId !== userId) {
                throw new Error('Matéria não encontrada');
            }
        }

        // Validar matérias no relacionamento many-to-many
        const materiasValidadas = [];
        if (materias && materias.length > 0) {
            for (const materiaIdOrObj of materias) {
                const materiaIdValue = typeof materiaIdOrObj === 'string' ? materiaIdOrObj : materiaIdOrObj.id;
                const materia = await this.materiaRepository.findById(materiaIdValue);

                if (!materia) {
                    throw new Error(`Matéria com ID ${materiaIdValue} não encontrada`);
                }

                if (materia.userId !== userId) {
                    throw new Error(`Matéria com ID ${materiaIdValue} não encontrada`);
                }

                materiasValidadas.push(materia);
            }
        }

        const prova = Prova.create(titulo, descricao, data, horario, local, materiaId, filtros, materiasValidadas);

        // Adicionar userId à prova
        const provaComUserId = {
            ...prova,
            userId
        };

        return await this.provaRepository.create(provaComUserId);
    }
} 