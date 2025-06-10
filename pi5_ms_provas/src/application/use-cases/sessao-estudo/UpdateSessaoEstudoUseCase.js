export class UpdateSessaoEstudoUseCase {
    constructor(sessaoEstudoRepository) {
        this.sessaoEstudoRepository = sessaoEstudoRepository;
    }

    async execute(id, sessaoData, userId) {
        const sessao = await this.sessaoEstudoRepository.findById(id);
        if (!sessao) {
            throw new Error('Sessão de estudo não encontrada');
        }
        
        // Verificar se a sessão pertence ao usuário
        if (sessao.userId !== userId) {
            throw new Error('Sessão de estudo não encontrada');
        }
        
        const updatedSessao = await this.sessaoEstudoRepository.update(id, sessaoData);
        return updatedSessao;
    }
} 