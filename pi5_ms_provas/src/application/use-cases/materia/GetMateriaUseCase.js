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
    }    /**
     * Busca todas as matérias não utilizadas de um usuário
     * (matérias que não estão associadas a nenhuma prova)
     * @param {string} userId - ID do usuário
     * @returns {Promise<Array>} Lista de matérias não utilizadas
     */
    async executeUnused(userId) {
        return await this.materiaRepository.findUnusedByUserId(userId);
    }

    /**
     * Busca todas as matérias utilizadas de um usuário
     * (matérias que estão associadas a pelo menos uma prova)
     * @param {string} userId - ID do usuário
     * @returns {Promise<Array>} Lista de matérias utilizadas
     */
    async executeUsed(userId) {
        return await this.materiaRepository.findUsedByUserId(userId);
    }
}