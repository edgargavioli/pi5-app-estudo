import { Router } from 'express';
import { EventoController } from '../controllers/EventoController.js';

const router = Router();
const eventoController = new EventoController();

// Listar todos os eventos
router.get('/', async (req, res) => {
    /*
    #swagger.tags = ['Eventos']
    #swagger.summary = 'Listar todos os eventos'
    #swagger.description = 'Retorna uma lista com todos os eventos (públicos e do usuário) incluindo links HATEOAS'
    #swagger.responses[200] = {
        description: 'Lista de eventos retornada com sucesso',
        schema: { 
            type: 'object',
            properties: {
                data: {
                    type: 'array',
                    items: { $ref: '#/components/schemas/Evento' }
                },
                _links: {
                    type: 'object',
                    properties: {
                        self: { type: 'object' },
                        create: { type: 'object' }
                    }
                }
            }
        }
    }
    #swagger.responses[500] = {
        description: 'Erro interno do servidor',
        schema: { $ref: '#/components/schemas/Error' }
    }
    */
    await eventoController.getAll(req, res);
});

// Buscar evento por ID
router.get('/:id', async (req, res) => {
    /*
    #swagger.tags = ['Eventos']
    #swagger.summary = 'Buscar evento por ID'
    #swagger.description = 'Retorna um evento específico incluindo links HATEOAS'
    #swagger.parameters['id'] = {
        in: 'path',
        description: 'ID do evento',
        required: true,
        type: 'string',
        format: 'uuid'
    }
    #swagger.responses[200] = {
        description: 'Evento encontrado com sucesso',
        schema: { 
            type: 'object',
            properties: {
                data: { $ref: '#/components/schemas/Evento' },
                _links: { type: 'object' }
            }
        }
    }
    #swagger.responses[404] = {
        description: 'Evento não encontrado',
        schema: { $ref: '#/components/schemas/Error' }
    }
    */
    await eventoController.getById(req, res);
});

// Criar novo evento
router.post('/', async (req, res) => {
    /*
    #swagger.tags = ['Eventos']
    #swagger.summary = 'Criar novo evento'
    #swagger.description = 'Cria um novo evento retornando links HATEOAS'
    #swagger.requestBody = {
        required: true,
        content: {
            "application/json": {
                schema: {
                    type: 'object',
                    properties: {
                        titulo: { 
                            type: 'string', 
                            example: 'ENEM 2025',
                            description: 'Título do evento'
                        },
                        descricao: { 
                            type: 'string', 
                            example: 'Exame Nacional do Ensino Médio',
                            description: 'Descrição do evento'
                        },
                        tipo: {
                            type: 'string',
                            enum: ['VESTIBULAR', 'CONCURSO_PUBLICO', 'ENEM', 'CERTIFICACAO', 'PROVA_SIMULADA'],
                            example: 'ENEM',
                            description: 'Tipo do evento'
                        },
                        data: {
                            type: 'string',
                            format: 'date',
                            example: '2025-11-15',
                            description: 'Data do evento'
                        },
                        horario: {
                            type: 'string',
                            format: 'date-time',
                            example: '2025-11-15T08:00:00Z',
                            description: 'Horário do evento'
                        },
                        local: {
                            type: 'string',
                            example: 'Campus Universitário',
                            description: 'Local do evento'
                        },
                        materiaId: {
                            type: 'string',
                            format: 'uuid',
                            example: '123e4567-e89b-12d3-a456-426614174000',
                            description: 'ID da matéria relacionada (opcional)'
                        },
                        urlInscricao: {
                            type: 'string',
                            example: 'https://enem.inep.gov.br',
                            description: 'URL para inscrição (opcional)'
                        },
                        taxaInscricao: {
                            type: 'number',
                            example: 85.00,
                            description: 'Taxa de inscrição (opcional)'
                        },
                        dataLimiteInscricao: {
                            type: 'string',
                            format: 'date',
                            example: '2025-05-15',
                            description: 'Data limite para inscrição (opcional)'
                        }
                    },
                    required: ['titulo', 'tipo', 'data', 'horario', 'local']
                }
            }
        }
    }
    #swagger.responses[201] = {
        description: 'Evento criado com sucesso',
        schema: { 
            type: 'object',
            properties: {
                data: { $ref: '#/components/schemas/Evento' },
                _links: { type: 'object' }
            }
        }
    }
    #swagger.responses[400] = {
        description: 'Dados inválidos',
        schema: { $ref: '#/components/schemas/Error' }
    }
    */
    await eventoController.create(req, res);
});

// Atualizar evento
router.put('/:id', async (req, res) => {
    /*
    #swagger.tags = ['Eventos']
    #swagger.summary = 'Atualizar evento'
    #swagger.description = 'Atualiza os dados de um evento existente retornando links HATEOAS'
    #swagger.parameters['id'] = {
        in: 'path',
        description: 'ID do evento',
        required: true,
        type: 'string',
        format: 'uuid'
    }
    #swagger.requestBody = {
        required: true,
        content: {
            "application/json": {
                schema: {
                    type: 'object',
                    properties: {
                        titulo: { type: 'string', example: 'ENEM 2025 - Atualizado' },
                        descricao: { type: 'string', example: 'Exame Nacional do Ensino Médio - Nova descrição' },
                        tipo: { type: 'string', enum: ['VESTIBULAR', 'CONCURSO_PUBLICO', 'ENEM', 'CERTIFICACAO', 'PROVA_SIMULADA'] },
                        data: { type: 'string', format: 'date' },
                        horario: { type: 'string', format: 'date-time' },
                        local: { type: 'string' },
                        materiaId: { type: 'string', format: 'uuid' },
                        urlInscricao: { type: 'string' },
                        taxaInscricao: { type: 'number' },
                        dataLimiteInscricao: { type: 'string', format: 'date' }
                    }
                }
            }
        }
    }
    #swagger.responses[200] = {
        description: 'Evento atualizado com sucesso',
        schema: { 
            type: 'object',
            properties: {
                data: { $ref: '#/components/schemas/Evento' },
                _links: { type: 'object' }
            }
        }
    }
    #swagger.responses[400] = {
        description: 'Dados inválidos',
        schema: { $ref: '#/components/schemas/Error' }
    }
    #swagger.responses[404] = {
        description: 'Evento não encontrado',
        schema: { $ref: '#/components/schemas/Error' }
    }
    */
    await eventoController.update(req, res);
});

// Deletar evento
router.delete('/:id', async (req, res) => {
    /*
    #swagger.tags = ['Eventos']
    #swagger.summary = 'Deletar evento'
    #swagger.description = 'Remove um evento permanentemente'
    #swagger.parameters['id'] = {
        in: 'path',
        description: 'ID do evento',
        required: true,
        type: 'string',
        format: 'uuid'
    }
    #swagger.responses[204] = {
        description: 'Evento deletado com sucesso'
    }
    #swagger.responses[404] = {
        description: 'Evento não encontrado',
        schema: { $ref: '#/components/schemas/Error' }
    }
    */
    await eventoController.delete(req, res);
});

export default router; 