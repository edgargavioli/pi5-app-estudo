export class DeleteMateriaUseCase {
    constructor(materiaRepository) {
        this.materiaRepository = materiaRepository;
    }

    async execute(id, userId) {
        const materia = await this.materiaRepository.findById(id);
        if (!materia) {
            throw new Error('Matéria não encontrada');
        }

        // Verificar se a matéria pertence ao usuário
        if (materia.userId !== userId) {
            throw new Error('Matéria não encontrada');
        }

        try {
            await this.materiaRepository.delete(id);
            return true;
        } catch (error) {
            // Verifica se é erro de foreign key constraint
            if (error.code === 'P2003' || error.message.includes('foreign key constraint')) {
                throw new Error('Não é possível deletar a matéria pois ela possui provas ou sessões de estudo associadas');
            }
            
            // Se não é FK constraint, relança o erro original
            throw error;
        }
    }
} 