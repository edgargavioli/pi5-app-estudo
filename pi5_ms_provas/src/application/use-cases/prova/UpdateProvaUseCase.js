export class UpdateProvaUseCase {
    constructor(provaRepository, materiaRepository) {
        this.provaRepository = provaRepository;
        this.materiaRepository = materiaRepository;
    }

    async execute(id, provaData, userId) {
        const prova = await this.provaRepository.findById(id);
        if (!prova) {
            throw new Error('Prova não encontrada');
        }

        // Verificar se a prova pertence ao usuário
        if (prova.userId !== userId) {
            throw new Error('Prova não encontrada');
        }

        // Se houver matérias para atualizar, validá-las
        if (provaData.materias && provaData.materias.length > 0) {
            for (const materiaIdOrObj of provaData.materias) {
                const materiaIdValue = typeof materiaIdOrObj === 'string' ? materiaIdOrObj : materiaIdOrObj.id;
                const materia = await this.materiaRepository.findById(materiaIdValue);

                if (!materia) {
                    throw new Error(`Matéria com ID ${materiaIdValue} não encontrada`);
                }

                if (materia.userId !== userId) {
                    throw new Error(`Matéria com ID ${materiaIdValue} não encontrada`);
                }
            }
        }

        const updatedProva = await this.provaRepository.update(id, provaData);
        return updatedProva;
    }
}