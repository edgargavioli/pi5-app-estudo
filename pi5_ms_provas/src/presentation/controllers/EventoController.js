import { CreateEventoUseCase } from '../../application/use-cases/evento/CreateEventoUseCase.js';
import { GetEventoUseCase } from '../../application/use-cases/evento/GetEventoUseCase.js';
import { UpdateEventoUseCase } from '../../application/use-cases/evento/UpdateEventoUseCase.js';
import { DeleteEventoUseCase } from '../../application/use-cases/evento/DeleteEventoUseCase.js';
import { EventoRepository } from '../../infrastructure/persistence/repositories/EventoRepository.js';
import { logger } from '../../application/utils/logger.js';
import { HateoasConfig } from '../../infrastructure/hateoas/HateoasConfig.js';
import rabbitMQService from '../../infrastructure/messaging/RabbitMQService.js';

const eventoRepository = new EventoRepository();

export class EventoController {
    constructor() {
        this.createUseCase = new CreateEventoUseCase(eventoRepository);
        this.getUseCase = new GetEventoUseCase(eventoRepository);
        this.updateUseCase = new UpdateEventoUseCase(eventoRepository);
        this.deleteUseCase = new DeleteEventoUseCase(eventoRepository);
    }

    async create(req, res) {
        try {
            logger.info('Iniciando criação de evento', { eventoData: req.body });
            const evento = await this.createUseCase.execute(req.body, req.userId);
            logger.info('Evento criado com sucesso', { eventoId: evento.id });

            // Publicar evento de criação
            await rabbitMQService.publishEntityCreated('evento', evento, req.userId);

            const response = HateoasConfig.wrapResponse(evento, req.baseUrl, 'eventos', evento.id);
            res.status(201).json(response);
        } catch (error) {
            logger.error('Erro ao criar evento', { error: error.message });
            if (error.message.includes('validação')) {
                return res.status(400).json({ error: error.message });
            }
            if (error.message.includes('não encontrada')) {
                return res.status(404).json({ error: error.message });
            }
            res.status(500).json({ error: 'Erro interno do servidor' });
        }
    }

    async getAll(req, res) {
        try {
            logger.info('Buscando todos os eventos');
            const eventos = await this.getUseCase.executeAll(req.userId);
            const response = HateoasConfig.wrapCollectionResponse(eventos, req.baseUrl, 'eventos');
            res.json(response);
        } catch (error) {
            logger.error('Erro ao buscar eventos', { error: error.message });
            res.status(500).json({ error: 'Erro interno do servidor' });
        }
    }

    async getById(req, res) {
        try {
            logger.info('Buscando evento por ID', { id: req.params.id });
            const evento = await this.getUseCase.execute(req.params.id, req.userId);
            const response = HateoasConfig.wrapResponse(evento, req.baseUrl, 'eventos', evento.id);
            res.json(response);
        } catch (error) {
            logger.error('Erro ao buscar evento', { error: error.message, id: req.params.id });
            if (error.message.includes('não encontrada')) {
                return res.status(404).json({ error: error.message });
            }
            res.status(500).json({ error: 'Erro interno do servidor' });
        }
    }

    async update(req, res) {
        try {
            logger.info('Atualizando evento', { id: req.params.id, eventoData: req.body });

            // Buscar dados anteriores para comparação
            const eventoAnterior = await this.getUseCase.execute(req.params.id, req.userId);

            const evento = await this.updateUseCase.execute(req.params.id, req.body, req.userId);
            logger.info('Evento atualizado com sucesso', { eventoId: evento.id });

            // Publicar evento de atualização
            await rabbitMQService.publishEntityUpdated('evento', evento.id, evento, eventoAnterior, req.userId);

            const response = HateoasConfig.wrapResponse(evento, req.baseUrl, 'eventos', evento.id);
            res.json(response);
        } catch (error) {
            logger.error('Erro ao atualizar evento', { error: error.message, id: req.params.id });
            if (error.message.includes('não encontrada')) {
                return res.status(404).json({ error: error.message });
            }
            if (error.message.includes('validação')) {
                return res.status(400).json({ error: error.message });
            }
            res.status(500).json({ error: 'Erro interno do servidor' });
        }
    }

    async delete(req, res) {
        try {
            logger.info('Deletando evento', { id: req.params.id });

            // Buscar dados do evento antes de deletar
            const eventoParaDeletar = await this.getUseCase.execute(req.params.id, req.userId);

            await this.deleteUseCase.execute(req.params.id, req.userId);
            logger.info('Evento deletado com sucesso', { id: req.params.id });

            // Publicar evento de exclusão
            await rabbitMQService.publishEntityDeleted('evento', req.params.id, eventoParaDeletar, req.userId);

            res.status(204).send();
        } catch (error) {
            logger.error('Erro ao deletar evento', { error: error.message, id: req.params.id });
            if (error.message.includes('não encontrada')) {
                return res.status(404).json({ error: error.message });
            }
            res.status(500).json({ error: 'Erro interno do servidor' });
        }
    }
}