import { CreateMateriaUseCase } from '../../application/use-cases/materia/CreateMateriaUseCase.js';
import { GetMateriaUseCase } from '../../application/use-cases/materia/GetMateriaUseCase.js';
import { UpdateMateriaUseCase } from '../../application/use-cases/materia/UpdateMateriaUseCase.js';
import { DeleteMateriaUseCase } from '../../application/use-cases/materia/DeleteMateriaUseCase.js';
import { MateriaRepository } from '../../infrastructure/persistence/repositories/MateriaRepository.js';
import { logger } from '../../application/utils/logger.js';
import { HateoasConfig } from '../../infrastructure/hateoas/HateoasConfig.js';

const materiaRepository = new MateriaRepository();

export class MateriaController {
    constructor() {
        this.createUseCase = new CreateMateriaUseCase(materiaRepository);
        this.getUseCase = new GetMateriaUseCase(materiaRepository);
        this.updateUseCase = new UpdateMateriaUseCase(materiaRepository);
        this.deleteUseCase = new DeleteMateriaUseCase(materiaRepository);
    }

    async create(req, res) {
        try {
            logger.info('Iniciando criacao de materia', { materiaData: req.body });
            const materia = await this.createUseCase.execute(req.body, req.userId);
            logger.info('Materia criada com sucesso', { materiaId: materia.id });
            const response = HateoasConfig.wrapResponse(materia, req.baseUrl, 'materias', materia);
            res.status(201).json(response);
        } catch (error) {
            logger.error('Erro ao criar materia', { error: error.message });
            if (error.message.includes('validacao')) {
                const errorResponse = HateoasConfig.wrapErrorResponse(error.message, 400, req.baseUrl);
                return res.status(400).json(errorResponse);
            }
            const errorResponse = HateoasConfig.wrapErrorResponse('Erro interno do servidor', 500, req.baseUrl);
            res.status(500).json(errorResponse);
        }
    }

    async getAll(req, res) {
        try {
            logger.info('Buscando todas as materias');
            const materias = await this.getUseCase.executeAll(req.userId);
            const response = HateoasConfig.wrapCollectionResponse(materias, req.baseUrl, 'materias');
            res.json(response);
        } catch (error) {
            logger.error('Erro ao buscar materias', { error: error.message });
            const errorResponse = HateoasConfig.wrapErrorResponse('Erro interno do servidor', 500, req.baseUrl);
            res.status(500).json(errorResponse);
        }
    }

    async getById(req, res) {
        try {
            logger.info('Buscando materia por ID', { id: req.params.id });
            const materia = await this.getUseCase.execute(req.params.id, req.userId);
            const response = HateoasConfig.wrapResponse(materia, req.baseUrl, 'materias', materia);
            res.json(response);
        } catch (error) {
            logger.error('Erro ao buscar materia', { error: error.message, id: req.params.id });
            if (error.message.includes('nao encontrada')) {
                const errorResponse = HateoasConfig.wrapErrorResponse(error.message, 404, req.baseUrl);
                return res.status(404).json(errorResponse);
            }
            const errorResponse = HateoasConfig.wrapErrorResponse('Erro interno do servidor', 500, req.baseUrl);
            res.status(500).json(errorResponse);
        }
    }

    async update(req, res) {
        try {
            logger.info('Atualizando materia', { id: req.params.id, materiaData: req.body });
            const materia = await this.updateUseCase.execute(req.params.id, req.body, req.userId);
            logger.info('Materia atualizada com sucesso', { materiaId: materia.id });
            const response = HateoasConfig.wrapResponse(materia, req.baseUrl, 'materias', materia);
            res.json(response);
        } catch (error) {
            logger.error('Erro ao atualizar materia', { error: error.message, id: req.params.id });
            if (error.message.includes('nao encontrada')) {
                const errorResponse = HateoasConfig.wrapErrorResponse(error.message, 404, req.baseUrl);
                return res.status(404).json(errorResponse);
            }
            if (error.message.includes('validacao')) {
                const errorResponse = HateoasConfig.wrapErrorResponse(error.message, 400, req.baseUrl);
                return res.status(400).json(errorResponse);
            }
            const errorResponse = HateoasConfig.wrapErrorResponse('Erro interno do servidor', 500, req.baseUrl);
            res.status(500).json(errorResponse);
        }
    }

    async delete(req, res) {
        try {
            logger.info('Deletando materia', { id: req.params.id });
            await this.deleteUseCase.execute(req.params.id, req.userId);
            logger.info('Materia deletada com sucesso', { id: req.params.id });
            res.status(204).send();
        } catch (error) {
            logger.error('Erro ao deletar materia', { error: error.message, id: req.params.id });
            
            // IMPORTANTE: FK constraint deve vir ANTES de "nao encontrada"
            if (error.message.includes('possui provas ou sessoes de estudo associadas')) {
                const errorResponse = HateoasConfig.wrapErrorResponse(error.message, 409, req.baseUrl);
                return res.status(409).json(errorResponse);
            }
            if (error.message.includes('nao encontrada')) {
                const errorResponse = HateoasConfig.wrapErrorResponse(error.message, 404, req.baseUrl);
                return res.status(404).json(errorResponse);
            }
            const errorResponse = HateoasConfig.wrapErrorResponse('Erro interno do servidor', 500, req.baseUrl);
            res.status(500).json(errorResponse);
        }
    }
} 