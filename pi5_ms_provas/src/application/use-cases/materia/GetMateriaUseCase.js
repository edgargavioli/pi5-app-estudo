export class GetMateriaUseCase {
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
        
        return materia;
    }

    async executeAll(userId) {
        return await this.materiaRepository.findByUserId(userId);
    }
} 