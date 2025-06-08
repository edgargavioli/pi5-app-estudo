export class UpdateMateriaUseCase {
    constructor(materiaRepository) {
        this.materiaRepository = materiaRepository;
    }

    async execute(id, materiaData, userId) {
        const { nome, descricao } = materiaData;
        
        const materia = await this.materiaRepository.findById(id);
        if (!materia) {
            throw new Error('Matéria não encontrada');
        }

        // Verificar se a matéria pertence ao usuário
        if (materia.userId !== userId) {
            throw new Error('Matéria não encontrada');
        }

        const updatedMateria = await this.materiaRepository.update(id, {
            nome: nome || materia.nome,
            descricao: descricao || materia.descricao
        });

        return updatedMateria;
    }
} 