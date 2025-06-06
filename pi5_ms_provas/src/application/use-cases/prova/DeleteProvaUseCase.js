export class DeleteProvaUseCase {
    constructor(provaRepository) {
        this.provaRepository = provaRepository;
    }

    async execute(id, userId) {
        const prova = await this.provaRepository.findById(id);
        if (!prova) {
            throw new Error('Prova não encontrada');
        }
        
        // Verificar se a prova pertence ao usuário
        if (prova.userId !== userId) {
            throw new Error('Prova não encontrada');
        }
        
        await this.provaRepository.delete(id);
        return true;
    }
} 