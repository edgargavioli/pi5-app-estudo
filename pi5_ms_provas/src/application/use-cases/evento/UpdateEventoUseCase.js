export class UpdateEventoUseCase {
    constructor(eventoRepository) {
        this.eventoRepository = eventoRepository;
    }

    async execute(id, eventoData, userId) {
        const evento = await this.eventoRepository.findById(id);
        if (!evento) {
            throw new Error('Evento não encontrada');
        }
        
        // Verificar se o evento pertence ao usuário
        if (evento.userId !== userId) {
            throw new Error('Evento não encontrada');
        }
        
        const updatedEvento = await this.eventoRepository.update(id, eventoData);
        return updatedEvento;
    }
} 