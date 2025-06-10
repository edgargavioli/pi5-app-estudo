import { Router } from 'express';
import { SessaoEstudoController } from '../controllers/SessaoEstudoController.js';

const router = Router();
const sessaoController = new SessaoEstudoController();

// Listar todas as sessões de estudo
router.get('/', async (req, res) => {
    /*
    #swagger.tags = ['Sessões de Estudo']
    #swagger.summary = 'Listar todas as sessões de estudo'
    #swagger.description = 'Retorna uma lista com todas as sessões de estudo cadastradas incluindo links HATEOAS'
    #swagger.responses[200] = {
        description: 'Lista de sessões retornada com sucesso',
        schema: { 
            type: 'object',
            properties: {
                data: {
                    type: 'array',
                    items: { $ref: '#/components/schemas/SessaoEstudo' }
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
    await sessaoController.getAll(req, res);
});

// Buscar uma sessão de estudo específica
router.get('/:id', async (req, res) => {
    /*
    #swagger.tags = ['Sessões de Estudo']
    #swagger.summary = 'Buscar sessão por ID'
    #swagger.description = 'Retorna uma sessão de estudo específica pelo seu ID incluindo links HATEOAS'
    #swagger.parameters['id'] = {
        in: 'path',
        description: 'ID da sessão de estudo',
        required: true,
        type: 'string',
        format: 'uuid'
    }
    #swagger.responses[200] = {
        description: 'Sessão encontrada',
        schema: { 
            type: 'object',
            properties: {
                data: { $ref: '#/components/schemas/SessaoEstudo' },
                _links: {
                    type: 'object',
                    properties: {
                        self: { type: 'object' },
                        update: { type: 'object' },
                        delete: { type: 'object' },
                        materia: { type: 'object' },
                        prova: { type: 'object' },
                        finalizar: { type: 'object' }
                    }
                }
            }
        }
    }
    #swagger.responses[404] = {
        description: 'Sessão não encontrada',
        schema: { $ref: '#/components/schemas/Error' }
    }
    */
    await sessaoController.getById(req, res);
});

// Criar uma nova sessão de estudo
router.post('/', async (req, res) => {
    /*
    #swagger.tags = ['Sessões de Estudo']
    #swagger.summary = 'Criar nova sessão de estudo'
    #swagger.description = 'Cria uma nova sessão de estudo no sistema com links HATEOAS. ⚠️ ATENÇÃO: O materiaId deve ser de uma matéria existente!'
    #swagger.requestBody = {
        required: true,
        content: {
            "application/json": {
                schema: {
                    type: 'object',
                    required: ['materiaId', 'conteudo', 'topicos', 'tempoInicio'],
                    properties: {
                        materiaId: { 
                            type: 'string', 
                            format: 'uuid',
                            example: '123e4567-e89b-12d3-a456-426614174000',
                            description: '🔗 ID da matéria (deve existir no sistema)'
                        },
                        provaId: { 
                            type: 'string', 
                            format: 'uuid',
                            example: '123e4567-e89b-12d3-a456-426614174001',
                            description: '🔗 ID da prova (opcional, se for estudo para prova específica)'
                        },
                        conteudo: { 
                            type: 'string', 
                            example: 'Estudando álgebra linear para o vestibular',
                            description: 'Descrição do conteúdo estudado'
                        },
                        topicos: { 
                            type: 'array',
                            items: { type: 'string' },
                            example: ['Matrizes', 'Determinantes', 'Sistemas lineares'],
                            description: 'Lista de tópicos estudados'
                        },
                        tempoInicio: { 
                            type: 'string', 
                            format: 'date-time',
                            example: '2024-12-25T14:00:00Z',
                            description: 'Horário de início da sessão (ISO 8601)'
                        }
                    }
                }
            }
        }
    }
    #swagger.responses[201] = {
        description: 'Sessão criada com sucesso',
        schema: { 
            type: 'object',
            properties: {
                data: { $ref: '#/components/schemas/SessaoEstudo' },
                _links: {
                    type: 'object',
                    properties: {
                        self: { type: 'object' },
                        update: { type: 'object' },
                        delete: { type: 'object' },
                        materia: { type: 'object' },
                        finalizar: { type: 'object' }
                    }
                }
            }
        }
    }
    #swagger.responses[400] = {
        description: 'Dados inválidos',
        schema: { $ref: '#/components/schemas/Error' }
    }
    */
    await sessaoController.create(req, res);
});

// Atualizar uma sessão de estudo
router.put('/:id', async (req, res) => {
    /*
    #swagger.tags = ['Sessões de Estudo']
    #swagger.summary = 'Atualizar sessão de estudo'
    #swagger.description = 'Atualiza os dados de uma sessão de estudo existente retornando links HATEOAS'
    #swagger.parameters['id'] = {
        in: 'path',
        description: 'ID da sessão de estudo',
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
                        conteudo: { 
                            type: 'string', 
                            example: 'Sessão de revisão de física quântica',
                            description: 'Descrição do conteúdo'
                        },
                        topicos: { 
                            type: 'array',
                            items: { type: 'string' },
                            example: ['Efeito fotoelétrico', 'Princípio da incerteza'],
                            description: 'Tópicos estudados'
                        }
                    }
                }
            }
        }
    }
    #swagger.responses[200] = {
        description: 'Sessão atualizada com sucesso',
        schema: { 
            type: 'object',
            properties: {
                data: { $ref: '#/components/schemas/SessaoEstudo' },
                _links: { type: 'object' }
            }
        }
    }
    #swagger.responses[400] = {
        description: 'Dados inválidos',
        schema: { $ref: '#/components/schemas/Error' }
    }
    #swagger.responses[404] = {
        description: 'Sessão não encontrada',
        schema: { $ref: '#/components/schemas/Error' }
    }
    */
    await sessaoController.update(req, res);
});

// Deletar uma sessão de estudo
router.delete('/:id', async (req, res) => {
    /*
    #swagger.tags = ['Sessões de Estudo']
    #swagger.summary = 'Deletar sessão de estudo'
    #swagger.description = 'Remove uma sessão de estudo do sistema'
    #swagger.parameters['id'] = {
        in: 'path',
        description: 'ID da sessão de estudo',
        required: true,
        type: 'string',
        format: 'uuid'
    }
    #swagger.responses[204] = {
        description: 'Sessão deletada com sucesso'
    }
    #swagger.responses[404] = {
        description: 'Sessão não encontrada',
        schema: { $ref: '#/components/schemas/Error' }
    }
    #swagger.responses[500] = {
        description: 'Erro interno do servidor',
        schema: { $ref: '#/components/schemas/Error' }
    }
    */
    await sessaoController.delete(req, res);
});

// Finalizar uma sessão de estudo
router.post('/:id/finalizar', async (req, res) => {
    /*
    #swagger.tags = ['Sessões de Estudo']
    #swagger.summary = 'Finalizar sessão de estudo'
    #swagger.description = 'Finaliza uma sessão de estudo em andamento, definindo o tempo de fim e retornando links HATEOAS'
    #swagger.parameters['id'] = {
        in: 'path',
        description: 'ID da sessão de estudo',
        required: true,
        type: 'string',
        format: 'uuid'
    }
    #swagger.responses[200] = {
        description: 'Sessão finalizada com sucesso',
        schema: { 
            type: 'object',
            properties: {
                data: { $ref: '#/components/schemas/SessaoEstudo' },
                _links: {
                    type: 'object',
                    properties: {
                        self: { type: 'object' },
                        update: { type: 'object' },
                        delete: { type: 'object' },
                        materia: { type: 'object' }
                    }
                }
            }
        }
    }
    #swagger.responses[400] = {
        description: 'Sessão já foi finalizada',
        schema: { 
            type: 'object',
            properties: {
                error: { 
                    type: 'string',
                    example: 'Sessão já foi finalizada'
                }
            }
        }
    }
    #swagger.responses[404] = {
        description: 'Sessão não encontrada',
        schema: { $ref: '#/components/schemas/Error' }
    }
    #swagger.responses[500] = {
        description: 'Erro interno do servidor',
        schema: { $ref: '#/components/schemas/Error' }
    }
    */
    await sessaoController.finalizar(req, res);
});

export default router; 