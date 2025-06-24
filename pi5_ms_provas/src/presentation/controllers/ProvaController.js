import { CreateProvaUseCase } from '../../application/use-cases/prova/CreateProvaUseCase.js';
import { GetProvaUseCase } from '../../application/use-cases/prova/GetProvaUseCase.js';
import { UpdateProvaUseCase } from '../../application/use-cases/prova/UpdateProvaUseCase.js';
import { DeleteProvaUseCase } from '../../application/use-cases/prova/DeleteProvaUseCase.js';
import { ProvaRepository } from '../../infrastructure/persistence/repositories/ProvaRepository.js';
import { MateriaRepository } from '../../infrastructure/persistence/repositories/MateriaRepository.js';
import { logger } from '../../application/utils/logger.js';
import { HateoasConfig } from '../../infrastructure/hateoas/HateoasConfig.js';
import rabbitMQService from '../../infrastructure/messaging/RabbitMQService.js';
import { GetEstatisticasProvaUseCase } from '../../application/use-cases/prova/GetEstatisticasProvaUseCase.js';

const provaRepository = new ProvaRepository();
const materiaRepository = new MateriaRepository();

export class ProvaController {
    constructor() {
        this.createUseCase = new CreateProvaUseCase(provaRepository, materiaRepository);
        this.getUseCase = new GetProvaUseCase(provaRepository);
        this.updateUseCase = new UpdateProvaUseCase(provaRepository, materiaRepository);
        this.deleteUseCase = new DeleteProvaUseCase(provaRepository);
        this.getEstatisticasUseCase = new GetEstatisticasProvaUseCase(provaRepository);
    }

    async create(req, res) {
        try {
            logger.info('Iniciando criação de prova', { provaData: req.body });
            const prova = await this.createUseCase.execute(req.body, req.userId);
            logger.info('Prova criada com sucesso', { provaId: prova.id });

            // Publicar evento de exame criado - CORRIGIDO
            try {
                await rabbitMQService.publishExamCreated('prova', prova, req.userId);
                logger.info('📤 Evento de prova criada publicado', { provaId: prova.id });
            } catch (eventError) {
                logger.error('❌ Erro ao publicar evento de prova criada', {
                    provaId: prova.id,
                    error: eventError.message
                });
            }

            const response = HateoasConfig.wrapResponse(prova, req.baseUrl, 'provas', prova.id);
            res.status(201).json(response);
        } catch (error) {
            logger.error('Erro ao criar prova', { error: error.message });
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
            logger.info('Buscando todas as provas');
            const provas = await this.getUseCase.executeAll(req.userId);
            const response = HateoasConfig.wrapCollectionResponse(provas, req.baseUrl, 'provas');
            res.json(response);
        } catch (error) {
            logger.error('Erro ao buscar provas', { error: error.message });
            res.status(500).json({ error: 'Erro interno do servidor' });
        }
    }

    async getById(req, res) {
        try {
            logger.info('Buscando prova por ID', { id: req.params.id });
            const prova = await this.getUseCase.execute(req.params.id, req.userId);
            const response = HateoasConfig.wrapResponse(prova, req.baseUrl, 'provas', prova.id);
            res.json(response);
        } catch (error) {
            logger.error('Erro ao buscar prova', { error: error.message, id: req.params.id });
            if (error.message.includes('não encontrada')) {
                return res.status(404).json({ error: error.message });
            }
            res.status(500).json({ error: 'Erro interno do servidor' });
        }
    }

    async update(req, res) {
        try {
            logger.info('Atualizando prova', { id: req.params.id, provaData: req.body });

            // Buscar dados anteriores para comparação
            const provaAnterior = await this.getUseCase.execute(req.params.id, req.userId);

            const prova = await this.updateUseCase.execute(req.params.id, req.body, req.userId);
            logger.info('Prova atualizada com sucesso', { provaId: prova.id });

            // Publicar evento de exame atualizado - CORRIGIDO
            try {
                await rabbitMQService.publishExamUpdated('prova', prova.id, prova, provaAnterior, req.userId);
                logger.info('📤 Evento de prova atualizada publicado', { provaId: prova.id });
            } catch (eventError) {
                logger.error('❌ Erro ao publicar evento de prova atualizada', {
                    provaId: prova.id,
                    error: eventError.message
                });
            }

            const response = HateoasConfig.wrapResponse(prova, req.baseUrl, 'provas', prova.id);
            res.json(response);
        } catch (error) {
            logger.error('Erro ao atualizar prova', { error: error.message, id: req.params.id });
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
            logger.info('Deletando prova', { id: req.params.id });

            // Buscar dados da prova antes de deletar
            const provaParaDeletar = await this.getUseCase.execute(req.params.id, req.userId);

            await this.deleteUseCase.execute(req.params.id, req.userId);
            logger.info('Prova deletada com sucesso', { id: req.params.id });

            // Publicar evento de exame deletado - CORRIGIDO
            try {
                await rabbitMQService.publishExamDeleted('prova', req.params.id, provaParaDeletar, req.userId);
                logger.info('📤 Evento de prova deletada publicado', { provaId: req.params.id });
            } catch (eventError) {
                logger.error('❌ Erro ao publicar evento de prova deletada', {
                    provaId: req.params.id,
                    error: eventError.message
                });
            }

            res.status(204).send();
        } catch (error) {
            logger.error('Erro ao deletar prova', { error: error.message, id: req.params.id });
            if (error.message.includes('não encontrada')) {
                return res.status(404).json({ error: error.message });
            }
            res.status(500).json({ error: 'Erro interno do servidor' });
        }
    }

    async registrarResultado(req, res) {
        try {
            const { id } = req.params;
            const { acertos } = req.body;

            logger.info('Registrando resultado da prova', { provaId: id, acertos });

            // Buscar a prova atual
            const prova = await this.getUseCase.execute(id, req.userId);
            if (!prova) {
                return res.status(404).json({ error: 'Prova não encontrada' });
            }

            // Verificar se a prova tem totalQuestoes definido
            if (!prova.totalQuestoes) {
                return res.status(400).json({
                    error: 'Esta prova não possui número total de questões definido. Não é possível registrar resultado.'
                });
            }

            // Validar se acertos não é maior que total de questões
            if (acertos > prova.totalQuestoes) {
                return res.status(400).json({
                    error: `Número de acertos (${acertos}) não pode ser maior que o total de questões (${prova.totalQuestoes})`
                });
            }

            if (acertos < 0) {
                return res.status(400).json({
                    error: 'Número de acertos não pode ser negativo'
                });
            }

            // Buscar dados anteriores para comparação
            const provaAnterior = { ...prova };

            // Atualizar apenas o campo acertos
            const provaAtualizada = await this.updateUseCase.execute(id, { acertos }, req.userId);

            // Publicar evento de prova finalizada (resultado registrado)
            await rabbitMQService.publishProvaFinalizada({
                ...provaAtualizada,
                questoesAcertadas: acertos,
                totalQuestoes: prova.totalQuestoes,
                percentualAcerto: provaAtualizada.percentualAcerto,
                materiaId: prova.materiaId,
                userId: req.userId
            });

            // Também publicar evento de exame atualizado
            await rabbitMQService.publishExamUpdated('prova', id, provaAtualizada, provaAnterior, req.userId);

            logger.info('Resultado da prova registrado com sucesso', {
                provaId: id,
                acertos,
                totalQuestoes: prova.totalQuestoes,
                percentual: provaAtualizada.percentualAcerto
            });

            const response = HateoasConfig.wrapResponse(provaAtualizada, req.baseUrl, 'provas', provaAtualizada.id);
            res.json(response);
        } catch (error) {
            logger.error('Erro ao registrar resultado da prova', { error: error.message, id: req.params.id });
            res.status(500).json({ error: 'Erro interno do servidor' });
        }
    }

    // Adicionar matéria a uma prova
    async addMateria(req, res) {
        try {
            const { id } = req.params;
            const { materiaId } = req.body;

            // Verificar se a prova existe e pertence ao usuário
            const prova = await this.getUseCase.execute(id, req.userId);
            if (!prova) {
                return res.status(404).json({ error: 'Prova não encontrada' });
            }

            // Verificar se a matéria existe e pertence ao usuário
            const materia = await materiaRepository.findById(materiaId);
            if (!materia || materia.userId !== req.userId) {
                return res.status(404).json({ error: 'Matéria não encontrada' });
            }

            // Adicionar a matéria à prova
            await provaRepository.addMateriasToProva(id, [materiaId]);

            // Buscar a prova atualizada
            const provaAtualizada = await this.getUseCase.execute(id, req.userId);

            logger.info('Matéria adicionada à prova com sucesso', { provaId: id, materiaId });

            const response = HateoasConfig.wrapResponse(provaAtualizada, req.baseUrl, 'provas', provaAtualizada.id);
            res.json(response);
        } catch (error) {
            logger.error('Erro ao adicionar matéria à prova', { error: error.message });
            res.status(500).json({ error: 'Erro interno do servidor' });
        }
    }    // Remover matéria de uma prova
    async removeMateria(req, res) {
        try {
            const { id, materiaId } = req.params;

            // Verificar se a prova existe e pertence ao usuário
            const prova = await this.getUseCase.execute(id, req.userId);
            if (!prova) {
                return res.status(404).json({ error: 'Prova não encontrada' });
            }

            // Remover a matéria da prova
            await provaRepository.removeMateriaFromProva(id, materiaId);

            // Buscar a prova atualizada
            const provaAtualizada = await this.getUseCase.execute(id, req.userId);

            logger.info('Matéria removida da prova com sucesso', { provaId: id, materiaId });

            const response = HateoasConfig.wrapResponse(provaAtualizada, req.baseUrl, 'provas', provaAtualizada.id);
            res.json(response);
        } catch (error) {
            logger.error('Erro ao remover matéria da prova', { error: error.message });
            res.status(500).json({ error: 'Erro interno do servidor' });
        }
    }

    // Atualizar status da prova
    async updateStatus(req, res) {
        try {
            const { id } = req.params;
            const { status } = req.body;

            logger.info('Atualizando status da prova', { provaId: id, status, userId: req.userId });

            // Validar status
            const statusValidos = ['PENDENTE', 'CONCLUIDA', 'CANCELADA'];
            if (!status || !statusValidos.includes(status)) {
                return res.status(400).json({
                    error: 'Status inválido. Valores aceitos: PENDENTE, CONCLUIDA, CANCELADA'
                });
            }

            // Verificar se a prova existe e pertence ao usuário
            const prova = await this.getUseCase.execute(id, req.userId);
            if (!prova) {
                return res.status(404).json({ error: 'Prova não encontrada' });
            }

            // Atualizar o status da prova
            const provaAtualizada = await provaRepository.updateStatus(id, status);

            logger.info('Status da prova atualizado com sucesso', {
                provaId: id,
                statusAnterior: prova.status,
                novoStatus: status
            });

            // Publicar evento de status atualizado
            try {
                await rabbitMQService.publishEntityUpdated('prova', id, provaAtualizada, prova, req.userId);
                logger.info('📤 Evento de status da prova atualizado publicado', { provaId: id, status });
            } catch (eventError) {
                logger.error('❌ Erro ao publicar evento de status da prova', {
                    provaId: id,
                    error: eventError.message
                });
            }

            const response = HateoasConfig.wrapResponse(provaAtualizada, req.baseUrl, 'provas', provaAtualizada.id);
            res.json(response);
        } catch (error) {
            logger.error('Erro ao atualizar status da prova', {
                error: error.message,
                provaId: req.params.id,
                userId: req.userId
            });

            if (error.message.includes('não encontrada') || error.message.includes('Acesso negado')) {
                return res.status(404).json({ error: 'Prova não encontrada' });
            }

            res.status(500).json({ error: 'Erro interno do servidor' });
        }
    }

    // Obter estatísticas das provas por status
    async getEstatisticas(req, res) {
        try {
            logger.info('Obtendo estatísticas de provas', { userId: req.userId });

            const estatisticas = await this.getEstatisticasUseCase.execute(req.userId);

            logger.info('Estatísticas de provas obtidas com sucesso', {
                userId: req.userId,
                total: estatisticas.total,
                concluidas: estatisticas.concluidas
            });

            res.json({
                success: true,
                data: estatisticas
            });
        } catch (error) {
            logger.error('Erro ao obter estatísticas de provas', {
                error: error.message,
                userId: req.userId
            });

            res.status(500).json({
                success: false,
                error: 'Erro interno do servidor'
            });
        }
    }

    // Obter estatísticas das provas por status
    async obterEstatisticasPorStatus(req, res) {
        try {
            const { userId } = req.query;

            if (!userId) {
                return res.status(400).json({
                    success: false,
                    error: 'userId é obrigatório'
                });
            }

            logger.info('Obtendo estatísticas das provas por status', { userId });

            // Usar o repository diretamente para obter as provas
            const provas = await provaRepository.findByUserId(userId);

            // Calcular estatísticas por status
            const total = provas.length;
            const pendentes = provas.filter(prova => prova.status === 'PENDENTE').length;
            const concluidas = provas.filter(prova => prova.status === 'CONCLUIDA').length;
            const canceladas = provas.filter(prova => prova.status === 'CANCELADA').length;

            // Calcular percentuais
            const percentualConcluidas = total > 0 ? (concluidas / total) * 100 : 0;
            const percentualPendentes = total > 0 ? (pendentes / total) * 100 : 0;
            const percentualCanceladas = total > 0 ? (canceladas / total) * 100 : 0;

            const estatisticas = {
                total,
                pendentes,
                concluidas,
                canceladas,
                percentualConcluidas: Math.round(percentualConcluidas * 100) / 100,
                percentualPendentes: Math.round(percentualPendentes * 100) / 100,
                percentualCanceladas: Math.round(percentualCanceladas * 100) / 100,
            };

            logger.info('Estatísticas obtidas com sucesso', { userId, estatisticas });

            res.status(200).json(estatisticas);
        } catch (error) {
            logger.error('Erro ao obter estatísticas das provas por status', {
                error: error.message,
                userId: req.query.userId
            });

            res.status(500).json({
                success: false,
                error: 'Erro interno do servidor'
            });
        }
    }
}