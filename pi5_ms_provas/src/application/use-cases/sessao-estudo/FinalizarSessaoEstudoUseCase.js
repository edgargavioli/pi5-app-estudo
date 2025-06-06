import { logger } from '../../utils/logger.js';
import rabbitMQService from '../../../infrastructure/messaging/RabbitMQService.js';

export class FinalizarSessaoEstudoUseCase {
    constructor(sessaoEstudoRepository) {
        this.sessaoEstudoRepository = sessaoEstudoRepository;
    }

    async execute(sessaoId, dadosFinalizacao = {}, userId) {
        try {
            logger.info('Finalizando sessão de estudo', { sessaoId, dadosFinalizacao, userId });

            // Buscar sessão atual
            const sessao = await this.sessaoEstudoRepository.findById(sessaoId);
            if (!sessao) {
                throw new Error('Sessão não encontrada');
            }

            // Verificar se a sessão pertence ao usuário
            if (sessao.userId !== userId) {
                throw new Error('Sessão não encontrada');
            }

            // Verificar se a sessão já foi finalizada
            if (sessao.finalizada) {
                throw new Error('Sessão já foi finalizada');
            }

            // Atualizar dados de finalização
            const sessaoAtualizada = await this.sessaoEstudoRepository.update(sessaoId, {
                tempoFim: new Date(),
                finalizada: true,
                questoesAcertadas: dadosFinalizacao.questoesAcertadas || 0,
                totalQuestoes: dadosFinalizacao.totalQuestoes || 0,
                ...dadosFinalizacao
            });

            logger.info('Sessão finalizada com sucesso', { sessaoId, userId });

            // 🚀 PUBLICAR EVENTO DE SESSÃO FINALIZADA
            try {
                await rabbitMQService.publishSessaoFinalizada(sessaoAtualizada);
                logger.info('📤 Evento de sessão finalizada publicado', { sessaoId, userId });
            } catch (eventError) {
                logger.error('❌ Erro ao publicar evento de sessão finalizada', { 
                    sessaoId,
                    userId,
                    error: eventError.message 
                });
                // Não falhar a finalização por erro de evento
            }

            return sessaoAtualizada;
        } catch (error) {
            logger.error('Erro ao finalizar sessão de estudo', { 
                sessaoId, 
                userId,
                error: error.message 
            });
            throw error;
        }
    }
} 