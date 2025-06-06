import { Evento } from '../../../domain/entities/Evento.js';

export class CreateEventoUseCase {
    constructor(eventoRepository) {
        this.eventoRepository = eventoRepository;
    }

    async execute(eventoData, userId) {
        const { titulo, descricao, tipo, data, horario, local, materiaId, urlInscricao, taxaInscricao, dataLimiteInscricao } = eventoData;
        
        if (!titulo) {
            throw new Error('Título é obrigatório');
        }
        
        if (!tipo) {
            throw new Error('Tipo do evento é obrigatório');
        }
        
        if (!data) {
            throw new Error('Data é obrigatória');
        }
        
        if (!horario) {
            throw new Error('Horário é obrigatório');
        }
        
        if (!local) {
            throw new Error('Local é obrigatório');
        }
        
        if (!userId) {
            throw new Error('UserId é obrigatório');
        }

        const evento = Evento.create(titulo, descricao, tipo, data, horario, local, materiaId, urlInscricao, taxaInscricao, dataLimiteInscricao);
        
        // Adicionar userId ao evento
        const eventoComUserId = {
            ...evento,
            userId
        };
        
        return await this.eventoRepository.create(eventoComUserId);
    }
} 