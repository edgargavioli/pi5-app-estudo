export class DeleteEventoUseCase {
    constructor(eventoRepository) {
        this.eventoRepository = eventoRepository;
    }

    async execute(id, userId) {
        const evento = await this.eventoRepository.findById(id);
        if (!evento) {
            throw new Error('Evento não encontrada');
        }
        
        // Verificar se o evento pertence ao usuário
        if (evento.userId !== userId) {
            throw new Error('Evento não encontrada');
        }
        
        await this.eventoRepository.delete(id);
        return true;
    }
} 