import { Router } from 'express';
import { MateriaController } from '../controllers/MateriaController.js';

const router = Router();
const materiaController = new MateriaController();

// Listar todas as matérias
router.get('/', async (req, res) => {
    /*
    #swagger.tags = ['Matérias']
    #swagger.summary = 'Listar todas as matérias'
    #swagger.description = 'Retorna uma lista com todas as matérias cadastradas incluindo links HATEOAS'
    #swagger.responses[200] = {
        description: 'Lista de matérias retornada com sucesso',
        schema: { 
            type: 'object',
            properties: {
                data: {
                    type: 'array',
                    items: { $ref: '#/components/schemas/Materia' }
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
    await materiaController.getAll(req, res);
});

// Listar matérias não utilizadas (que não estão associadas a nenhuma prova)
router.get('/nao-utilizadas', async (req, res) => {
    /*
    #swagger.tags = ['Matérias']
    #swagger.summary = 'Listar matérias não utilizadas'
    #swagger.description = 'Retorna uma lista com todas as matérias que não estão associadas a nenhuma prova'
    #swagger.responses[200] = {
        description: 'Lista de matérias não utilizadas retornada com sucesso',
        schema: { 
            type: 'object',
            properties: {
                data: {
                    type: 'array',
                    items: { $ref: '#/components/schemas/Materia' }
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
    */    await materiaController.getUnused(req, res);
});

// Listar matérias utilizadas (que estão associadas a provas)
router.get('/utilizadas', async (req, res) => {
    /*
    #swagger.tags = ['Matérias']
    #swagger.summary = 'Listar matérias utilizadas'
    #swagger.description = 'Retorna uma lista com todas as matérias que estão associadas a pelo menos uma prova'
    #swagger.responses[200] = {
        description: 'Lista de matérias utilizadas retornada com sucesso',
        schema: { 
            type: 'object',
            properties: {
                data: {
                    type: 'array',
                    items: { $ref: '#/components/schemas/Materia' }
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
    await materiaController.getUsed(req, res);
});

// Buscar uma matéria específica
router.get('/:id', async (req, res) => {
    /*
    #swagger.tags = ['Matérias']
    #swagger.summary = 'Buscar matéria por ID'
    #swagger.description = 'Retorna uma matéria específica pelo seu ID incluindo links HATEOAS para recursos relacionados'
    #swagger.parameters['id'] = {
        in: 'path',
        description: 'ID da matéria',
        required: true,
        type: 'string',
        format: 'uuid'
    }
    #swagger.responses[200] = {
        description: 'Matéria encontrada',
        schema: { 
            type: 'object',
            properties: {
                data: { $ref: '#/components/schemas/Materia' },
                _links: {
                    type: 'object',
                    properties: {
                        self: { type: 'object' },
                        update: { type: 'object' },
                        delete: { type: 'object' },
                        provas: { type: 'object' },
                        sessoes: { type: 'object' }
                    }
                }
            }
        }
    }
    #swagger.responses[404] = {
        description: 'Matéria não encontrada',
        schema: { $ref: '#/components/schemas/Error' }
    }
    */
    await materiaController.getById(req, res);
});

// Criar uma nova matéria
router.post('/', async (req, res) => {
    /*
    #swagger.tags = ['Matérias']
    #swagger.summary = 'Criar nova matéria'
    #swagger.description = 'Cria uma nova matéria no sistema com links HATEOAS'
    #swagger.requestBody = {
        required: true,
        content: {
            "application/json": {
                schema: {
                    type: 'object',
                    required: ['nome', 'disciplina'],
                    properties: {
                        nome: { 
                            type: 'string', 
                            example: 'Matemática',
                            description: 'Nome da matéria'
                        },
                        disciplina: { 
                            type: 'string', 
                            example: 'Exatas',
                            description: 'Disciplina à qual a matéria pertence'
                        }
                    }
                }
            }
        }
    }
    #swagger.responses[201] = {
        description: 'Matéria criada com sucesso',
        schema: { 
            type: 'object',
            properties: {
                data: { $ref: '#/components/schemas/Materia' },
                _links: {
                    type: 'object',
                    properties: {
                        self: { type: 'object' },
                        update: { type: 'object' },
                        delete: { type: 'object' },
                        provas: { type: 'object' },
                        sessoes: { type: 'object' }
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
    await materiaController.create(req, res);
});

// Atualizar uma matéria
router.put('/:id', async (req, res) => {
    /*
    #swagger.tags = ['Matérias']
    #swagger.summary = 'Atualizar matéria'
    #swagger.description = 'Atualiza os dados de uma matéria existente retornando links HATEOAS'
    #swagger.parameters['id'] = {
        in: 'path',
        description: 'ID da matéria',
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
                        nome: { 
                            type: 'string', 
                            example: 'Física',
                            description: 'Nome da matéria'
                        },
                        disciplina: { 
                            type: 'string', 
                            example: 'Exatas',
                            description: 'Disciplina à qual a matéria pertence'
                        }
                    }
                }
            }
        }
    }
    #swagger.responses[200] = {
        description: 'Matéria atualizada com sucesso',
        schema: { 
            type: 'object',
            properties: {
                data: { $ref: '#/components/schemas/Materia' },
                _links: { type: 'object' }
            }
        }
    }
    #swagger.responses[400] = {
        description: 'Dados inválidos',
        schema: { $ref: '#/components/schemas/Error' }
    }
    #swagger.responses[404] = {
        description: 'Matéria não encontrada',
        schema: { $ref: '#/components/schemas/Error' }
    }
    */
    await materiaController.update(req, res);
});

// Deletar uma matéria
router.delete('/:id', async (req, res) => {
    /*
    #swagger.tags = ['Matérias']
    #swagger.summary = 'Deletar matéria'
    #swagger.description = 'Remove uma matéria do sistema. ⚠️ ATENÇÃO: Não é possível deletar matérias que possuem provas ou sessões associadas (FK constraint - retorna 409)'
    #swagger.parameters['id'] = {
        in: 'path',
        description: 'ID da matéria',
        required: true,
        type: 'string',
        format: 'uuid'
    }
    #swagger.responses[204] = {
        description: 'Matéria deletada com sucesso'
    }
    #swagger.responses[404] = {
        description: 'Matéria não encontrada',
        schema: { 
            type: 'object',
            properties: {
                error: { 
                    type: 'string',
                    example: 'Matéria não encontrada'
                }
            }
        }
    }
    #swagger.responses[409] = {
        description: 'Conflito - Matéria possui relacionamentos (FK Constraint)',
        schema: { 
            type: 'object',
            properties: {
                error: { 
                    type: 'string',
                    example: 'Não é possível deletar a matéria pois ela possui provas ou sessões de estudo associadas'
                }
            }
        }
    }
    #swagger.responses[500] = {
        description: 'Erro interno do servidor',
        schema: { $ref: '#/components/schemas/Error' }
    }
    */
    await materiaController.delete(req, res);
});

export default router;