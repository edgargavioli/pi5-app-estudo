import { CreateSessaoEstudoUseCase } from '../../application/use-cases/sessao-estudo/CreateSessaoEstudoUseCase.js';
import { GetSessaoEstudoUseCase } from '../../application/use-cases/sessao-estudo/GetSessaoEstudoUseCase.js';
import { UpdateSessaoEstudoUseCase } from '../../application/use-cases/sessao-estudo/UpdateSessaoEstudoUseCase.js';
import { DeleteSessaoEstudoUseCase } from '../../application/use-cases/sessao-estudo/DeleteSessaoEstudoUseCase.js';
import { FinalizarSessaoEstudoUseCase } from '../../application/use-cases/sessao-estudo/FinalizarSessaoEstudoUseCase.js';
import { GetAllSessoesEstudoUseCase } from '../../application/use-cases/sessao-estudo/GetAllSessoesEstudoUseCase.js';
import { SessaoEstudoRepository } from '../../infrastructure/persistence/repositories/SessaoEstudoRepository.js';
import { HateoasConfig } from '../../infrastructure/hateoas/HateoasConfig.js';
import { logger } from '../../application/utils/logger.js';
import rabbitMQService from '../../infrastructure/messaging/RabbitMQService.js';

export class SessaoEstudoController {
    constructor() {
        const repository = new SessaoEstudoRepository();
        this.createUseCase = new CreateSessaoEstudoUseCase(repository);
        this.getUseCase = new GetSessaoEstudoUseCase(repository);
        this.getAllUseCase = new GetAllSessoesEstudoUseCase(repository);
        this.updateUseCase = new UpdateSessaoEstudoUseCase(repository);
        this.deleteUseCase = new DeleteSessaoEstudoUseCase(repository);
        this.finalizarUseCase = new FinalizarSessaoEstudoUseCase(repository);
    }

    async create(req, res) {
        try {
            // 🔒 userId já foi validado pelo jwtValidationMiddleware
            const userId = req.userId;

            logger.info('Iniciando criação de sessão de estudo', {
                sessaoData: req.body,
                userId
            });

            const sessao = await this.createUseCase.execute(req.body, userId);

            logger.info('Sessão de estudo criada com sucesso', {
                sessaoId: sessao.id,
                userId
            });

            // Publicar evento de sessão criada
            await rabbitMQService.publishSessaoCriada({
                ...sessao,
                userId
            });

            // Publicar evento genérico de entidade criada
            await rabbitMQService.publishEntityCreated('sessao', sessao, userId);

            const response = HateoasConfig.wrapResponse(sessao, req.baseUrl, 'sessoes', sessao.id);
            res.status(201).json(response);
        } catch (error) {
            logger.error('Erro ao criar sessão de estudo', {
                error: error.message,
                userId: req.userId
            });
            if (error.message.includes('validação')) {
                return res.status(400).json({ error: error.message });
            }
            res.status(500).json({ error: 'Erro interno do servidor' });
        }
    }

    async getAll(req, res) {
        try {
            // 🔒 Listar apenas sessões do usuário autenticado
            const userId = req.userId;

            logger.info('Listando sessões de estudo do usuário', { userId });

            const sessoes = await this.getAllUseCase.execute(userId, req.query);

            logger.info('Sessões listadas com sucesso', {
                total: sessoes.length,
                userId
            });

            const response = HateoasConfig.wrapCollectionResponse(sessoes, req.baseUrl, 'sessoes');
            res.json(response);
        } catch (error) {
            logger.error('Erro ao listar sessões de estudo', {
                error: error.message,
                userId: req.userId
            });
            res.status(500).json({ error: 'Erro interno do servidor' });
        }
    }

    async getById(req, res) {
        try {
            // 🔒 Buscar apenas se pertence ao usuário
            const userId = req.userId;
            const sessaoId = req.params.id;

            logger.info('Buscando sessão de estudo por ID', {
                sessaoId,
                userId
            });

            const sessao = await this.getUseCase.execute(sessaoId, userId);

            const response = HateoasConfig.wrapResponse(sessao, req.baseUrl, 'sessoes', sessao.id);
            res.json(response);
        } catch (error) {
            logger.error('Erro ao buscar sessão de estudo', {
                error: error.message,
                sessaoId: req.params.id,
                userId: req.userId
            });
            if (error.message.includes('não encontrada') || error.message.includes('Acesso negado')) {
                return res.status(404).json({ error: 'Sessão não encontrada' });
            }
            res.status(500).json({ error: 'Erro interno do servidor' });
        }
    }

    async update(req, res) {
        try {
            // 🔒 Atualizar apenas se pertence ao usuário
            const userId = req.userId;
            const sessaoId = req.params.id;

            logger.info('Atualizando sessão de estudo', {
                sessaoId,
                userId,
                sessaoData: req.body
            });

            // Buscar dados anteriores para comparação
            const sessaoAnterior = await this.getUseCase.execute(sessaoId, userId);

            const sessao = await this.updateUseCase.execute(sessaoId, req.body, userId);

            logger.info('Sessão de estudo atualizada com sucesso', {
                sessaoId,
                userId
            });

            // Publicar evento de entidade atualizada
            await rabbitMQService.publishEntityUpdated('sessao', sessaoId, sessao, sessaoAnterior, userId);

            const response = HateoasConfig.wrapResponse(sessao, req.baseUrl, 'sessoes', sessao.id);
            res.json(response);
        } catch (error) {
            logger.error('Erro ao atualizar sessão de estudo', {
                error: error.message,
                sessaoId: req.params.id,
                userId: req.userId
            });
            if (error.message.includes('não encontrada') || error.message.includes('Acesso negado')) {
                return res.status(404).json({ error: 'Sessão não encontrada' });
            }
            if (error.message.includes('validação')) {
                return res.status(400).json({ error: error.message });
            }
            res.status(500).json({ error: 'Erro interno do servidor' });
        }
    }

    async delete(req, res) {
        try {
            // 🔒 Deletar apenas se pertence ao usuário
            const userId = req.userId;
            const sessaoId = req.params.id;

            logger.info('Deletando sessão de estudo', {
                sessaoId,
                userId
            });

            // Buscar dados da sessão antes de deletar
            const sessaoParaDeletar = await this.getUseCase.execute(sessaoId, userId);

            await this.deleteUseCase.execute(sessaoId, userId);

            logger.info('Sessão de estudo deletada com sucesso', {
                sessaoId,
                userId
            });

            // Publicar evento de entidade deletada
            await rabbitMQService.publishEntityDeleted('sessao', sessaoId, sessaoParaDeletar, userId);

            res.status(204).send();
        } catch (error) {
            logger.error('Erro ao deletar sessão de estudo', {
                error: error.message,
                sessaoId: req.params.id,
                userId: req.userId
            });
            if (error.message.includes('não encontrada') || error.message.includes('Acesso negado')) {
                return res.status(404).json({ error: 'Sessão não encontrada' });
            }
            res.status(500).json({ error: 'Erro interno do servidor' });
        }
    }

    async finalizar(req, res) {
        try {
            // 🔒 Finalizar apenas se pertence ao usuário
            const userId = req.userId;
            const sessaoId = req.params.id;

            logger.info('Finalizando sessão de estudo', {
                sessaoId,
                userId,
                dadosFinalizacao: req.body
            });

            // Buscar dados anteriores para comparação
            const sessaoAnterior = await this.getUseCase.execute(sessaoId, userId);

            const sessao = await this.finalizarUseCase.execute(sessaoId, req.body, userId);

            logger.info('Sessão de estudo finalizada com sucesso', {
                sessaoId,
                userId
            });

            // Publicar evento de sessão finalizada
            await rabbitMQService.publishSessaoFinalizada({
                ...sessao,
                userId
            });

            // Publicar evento genérico de entidade atualizada
            await rabbitMQService.publishEntityUpdated('sessao', sessaoId, sessao, sessaoAnterior, userId);

            const response = HateoasConfig.wrapResponse(sessao, req.baseUrl, 'sessoes', sessao.id);
            res.json(response);
        } catch (error) {
            logger.error('Erro ao finalizar sessão de estudo', {
                error: error.message,
                sessaoId: req.params.id,
                userId: req.userId
            });
            if (error.message.includes('não encontrada') || error.message.includes('Acesso negado')) {
                return res.status(404).json({ error: 'Sessão não encontrada' });
            }
            if (error.message.includes('já foi finalizada')) {
                return res.status(400).json({ error: error.message });
            }
            res.status(500).json({ error: 'Erro interno do servidor' });
        }
    }
}