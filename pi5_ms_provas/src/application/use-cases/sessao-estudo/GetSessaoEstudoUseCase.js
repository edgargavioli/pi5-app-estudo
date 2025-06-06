export class GetSessaoEstudoUseCase {
    constructor(sessaoEstudoRepository) {
        this.sessaoEstudoRepository = sessaoEstudoRepository;
    }

    async execute(id, userId) {
        const sessao = await this.sessaoEstudoRepository.findById(id);
        if (!sessao) {
            throw new Error('Sessão de estudo não encontrada');
        }
        
        // Verificar se a sessão pertence ao usuário
        if (sessao.userId !== userId) {
            throw new Error('Sessão de estudo não encontrada');
        }
        
        return sessao;
    }

    async executeAll(userId) {
        return await this.sessaoEstudoRepository.findAllByUserId(userId);
    }
} 