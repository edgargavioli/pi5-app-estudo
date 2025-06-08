import { logger } from '../../utils/logger.js';
import rabbitMQService from '../../../infrastructure/messaging/RabbitMQService.js';

export class FinalizarProvaUseCase {
    constructor(provaRepository) {
        this.provaRepository = provaRepository;
    }

    async execute(provaId, dadosFinalizacao) {
        try {
            logger.info('Finalizando prova', { provaId, dadosFinalizacao });

            const { questoesAcertadas, totalQuestoes } = dadosFinalizacao;

            // Validações básicas
            if (!questoesAcertadas || !totalQuestoes) {
                throw new Error('Dados de finalização incompletos');
            }

            if (questoesAcertadas > totalQuestoes) {
                throw new Error('Questões acertadas não podem ser maiores que o total');
            }

            // Buscar prova
            const prova = await this.provaRepository.findById(provaId);
            if (!prova) {
                throw new Error('Prova não encontrada');
            }

            // Calcular percentual de acerto
            const percentualAcerto = Math.round((questoesAcertadas / totalQuestoes) * 100);

            // Atualizar prova com dados de finalização
            const provaAtualizada = await this.provaRepository.update(provaId, {
                questoesAcertadas,
                totalQuestoes,
                percentualAcerto,
                dataRealizacao: new Date(),
                finalizada: true
            });

            logger.info('Prova finalizada com sucesso', { 
                provaId, 
                questoesAcertadas, 
                totalQuestoes, 
                percentualAcerto 
            });

            // 🚀 PUBLICAR EVENTO DE PROVA FINALIZADA
            try {
                await rabbitMQService.publishProvaFinalizada(provaAtualizada);
                logger.info('📤 Evento de prova finalizada publicado', { provaId });
            } catch (eventError) {
                logger.error('❌ Erro ao publicar evento de prova finalizada', { 
                    provaId,
                    error: eventError.message 
                });
                // Não falhar a finalização por erro de evento
            }

            return provaAtualizada;
        } catch (error) {
            logger.error('Erro ao finalizar prova', { 
                provaId, 
                error: error.message 
            });
            throw error;
        }
    }
} 