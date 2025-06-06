export class GetEventoUseCase {
    constructor(eventoRepository) {
        this.eventoRepository = eventoRepository;
    }

    async execute(id, userId) {
        const evento = await this.eventoRepository.findById(id);
        if (!evento) {
            throw new Error('Evento não encontrada');
        }
        
        // Verificar se o evento pertence ao usuário (ou é público)
        if (evento.userId && evento.userId !== userId) {
            throw new Error('Evento não encontrada');
        }
        
        return evento;
    }

    async executeAll(userId) {
        // Buscar eventos públicos e do usuário
        return await this.eventoRepository.findByUserIdOrPublic(userId);
    }
} 