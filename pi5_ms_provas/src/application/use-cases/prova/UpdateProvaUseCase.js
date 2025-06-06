export class UpdateProvaUseCase {
    constructor(provaRepository) {
        this.provaRepository = provaRepository;
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
        
        const updatedProva = await this.provaRepository.update(id, provaData);
        return updatedProva;
    }
} 