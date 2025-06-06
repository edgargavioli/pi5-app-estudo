import { Router } from 'express';
import { ProvaController } from '../controllers/ProvaController.js';

const router = Router();
const provaController = new ProvaController();

// Listar todas as provas
router.get('/', async (req, res) => {
    /*
    #swagger.tags = ['Provas']
    #swagger.summary = 'Listar todas as provas'
    #swagger.description = 'Retorna uma lista com todas as provas cadastradas incluindo links HATEOAS'
    #swagger.responses[200] = {
        description: 'Lista de provas retornada com sucesso',
        schema: { 
            type: 'object',
            properties: {
                data: {
                    type: 'array',
                    items: { $ref: '#/components/schemas/Prova' }
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
    await provaController.getAll(req, res);
});

// Buscar uma prova específica
router.get('/:id', async (req, res) => {
    /*
    #swagger.tags = ['Provas']
    #swagger.summary = 'Buscar prova por ID'
    #swagger.description = 'Retorna uma prova específica pelo seu ID incluindo links HATEOAS para recursos relacionados'
    #swagger.parameters['id'] = {
        in: 'path',
        description: 'ID da prova',
        required: true,
        type: 'string',
        format: 'uuid'
    }
    #swagger.responses[200] = {
        description: 'Prova encontrada',
        schema: { 
            type: 'object',
            properties: {
                data: { $ref: '#/components/schemas/Prova' },
                _links: {
                    type: 'object',
                    properties: {
                        self: { type: 'object' },
                        update: { type: 'object' },
                        delete: { type: 'object' },
                        materia: { type: 'object' },
                        sessoes: { type: 'object' }
                    }
                }
            }
        }
    }
    #swagger.responses[404] = {
        description: 'Prova não encontrada',
        schema: { $ref: '#/components/schemas/Error' }
    }
    */
    await provaController.getById(req, res);
});

// Criar uma nova prova
router.post('/', async (req, res) => {
    /*
    #swagger.tags = ['Provas']
    #swagger.summary = 'Criar nova prova'
    #swagger.description = 'Cria uma nova prova no sistema com links HATEOAS. ⚠️ ATENÇÃO: O materiaId deve ser de uma matéria existente!'
    #swagger.requestBody = {
        required: true,
        content: {
            "application/json": {
                schema: {
                    type: 'object',
                    required: ['titulo', 'data', 'horario', 'local', 'materiaId'],
                    properties: {
                        titulo: { 
                            type: 'string', 
                            example: 'Prova de Matemática',
                            description: 'Título da prova'
                        },
                        descricao: { 
                            type: 'string', 
                            example: 'Prova sobre álgebra linear e cálculo',
                            description: 'Descrição detalhada da prova'
                        },
                        data: { 
                            type: 'string', 
                            format: 'date',
                            example: '2024-12-25',
                            description: 'Data da prova (YYYY-MM-DD)'
                        },
                        horario: { 
                            type: 'string', 
                            format: 'date-time',
                            example: '2024-12-25T10:00:00Z',
                            description: 'Horário da prova (ISO 8601)'
                        },
                        local: { 
                            type: 'string', 
                            example: 'Sala 101',
                            description: 'Local onde será realizada a prova'
                        },
                        materiaId: { 
                            type: 'string', 
                            format: 'uuid',
                            example: '123e4567-e89b-12d3-a456-426614174000',
                            description: '🔗 ID da matéria (deve existir no sistema)'
                        },
                        totalQuestoes: {
                            type: 'integer',
                            minimum: 1,
                            example: 10,
                            description: 'Número total de questões da prova (opcional)'
                        },
                        filtros: {
                            type: 'object',
                            description: 'Filtros adicionais (opcional)',
                            example: { "tipo": "vestibular", "nivel": "medio" }
                        }
                    }
                }
            }
        }
    }
    #swagger.responses[201] = {
        description: 'Prova criada com sucesso',
        schema: { 
            type: 'object',
            properties: {
                data: { $ref: '#/components/schemas/Prova' },
                _links: {
                    type: 'object',
                    properties: {
                        self: { type: 'object' },
                        update: { type: 'object' },
                        delete: { type: 'object' },
                        materia: { type: 'object' },
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
    */
    await provaController.create(req, res);
});

// Atualizar uma prova
router.put('/:id', async (req, res) => {
    /*
    #swagger.tags = ['Provas']
    #swagger.summary = 'Atualizar prova'
    #swagger.description = 'Atualiza os dados de uma prova existente retornando links HATEOAS'
    #swagger.parameters['id'] = {
        in: 'path',
        description: 'ID da prova',
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
                        titulo: { 
                            type: 'string', 
                            example: 'Prova de Física',
                            description: 'Título da prova'
                        },
                        descricao: { 
                            type: 'string', 
                            example: 'Prova sobre mecânica clássica',
                            description: 'Descrição da prova'
                        },
                        data: { 
                            type: 'string', 
                            format: 'date',
                            example: '2024-12-30',
                            description: 'Data da prova'
                        },
                        horario: { 
                            type: 'string', 
                            format: 'date-time',
                            example: '2024-12-30T14:00:00Z',
                            description: 'Horário da prova'
                        },
                        local: { 
                            type: 'string', 
                            example: 'Sala 102',
                            description: 'Local da prova'
                        },
                        totalQuestoes: {
                            type: 'integer',
                            minimum: 1,
                            example: 15,
                            description: 'Número total de questões da prova'
                        },
                        filtros: {
                            type: 'object',
                            description: 'Filtros adicionais',
                            example: { "tipo": "vestibular", "area": "exatas" }
                        }
                    }
                }
            }
        }
    }
    #swagger.responses[200] = {
        description: 'Prova atualizada com sucesso',
        schema: { 
            type: 'object',
            properties: {
                data: { $ref: '#/components/schemas/Prova' },
                _links: { type: 'object' }
            }
        }
    }
    #swagger.responses[400] = {
        description: 'Dados inválidos',
        schema: { $ref: '#/components/schemas/Error' }
    }
    #swagger.responses[404] = {
        description: 'Prova não encontrada',
        schema: { $ref: '#/components/schemas/Error' }
    }
    */
    await provaController.update(req, res);
});

// Registrar resultado da prova
router.patch('/:id/resultado', async (req, res) => {
    /*
    #swagger.tags = ['Provas']
    #swagger.summary = 'Registrar resultado da prova'
    #swagger.description = 'Registra o número de acertos do usuário em uma prova específica para calcular desempenho'
    #swagger.parameters['id'] = {
        in: 'path',
        description: 'ID da prova',
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
                    required: ['acertos'],
                    properties: {
                        acertos: { 
                            type: 'integer', 
                            minimum: 0,
                            example: 8,
                            description: 'Número de questões acertadas pelo usuário'
                        }
                    }
                }
            }
        }
    }
    #swagger.responses[200] = {
        description: 'Resultado registrado com sucesso',
        schema: { 
            type: 'object',
            properties: {
                data: { 
                    allOf: [
                        { $ref: '#/components/schemas/Prova' },
                        {
                            type: 'object',
                            properties: {
                                acertos: { type: 'integer', example: 8 },
                                percentualAcerto: { type: 'integer', example: 80 },
                                foiRealizada: { type: 'boolean', example: true }
                            }
                        }
                    ]
                },
                _links: { type: 'object' }
            }
        }
    }
    #swagger.responses[400] = {
        description: 'Dados inválidos ou prova sem total de questões definido',
        schema: { 
            type: 'object',
            properties: {
                error: { 
                    type: 'string',
                    example: 'Número de acertos (12) não pode ser maior que o total de questões (10)'
                }
            }
        }
    }
    #swagger.responses[404] = {
        description: 'Prova não encontrada',
        schema: { $ref: '#/components/schemas/Error' }
    }
    */
    await provaController.registrarResultado(req, res);
});

// Deletar uma prova
router.delete('/:id', async (req, res) => {
    /*
    #swagger.tags = ['Provas']
    #swagger.summary = 'Deletar prova'
    #swagger.description = 'Remove uma prova do sistema'
    #swagger.parameters['id'] = {
        in: 'path',
        description: 'ID da prova',
        required: true,
        type: 'string',
        format: 'uuid'
    }
    #swagger.responses[204] = {
        description: 'Prova deletada com sucesso'
    }
    #swagger.responses[404] = {
        description: 'Prova não encontrada',
        schema: { $ref: '#/components/schemas/Error' }
    }
    #swagger.responses[500] = {
        description: 'Erro interno do servidor',
        schema: { $ref: '#/components/schemas/Error' }
    }
    */
    await provaController.delete(req, res);
});

export default router; 