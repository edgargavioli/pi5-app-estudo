import { SessaoEstudoValidator } from '../../validators/SessaoEstudoValidator.js';
import { logger } from '../../utils/logger.js';
import rabbitMQService from '../../../infrastructure/messaging/RabbitMQService.js';
import { SessaoEstudo } from '../../../domain/entities/SessaoEstudo.js';

export class CreateSessaoEstudoUseCase {
    constructor(sessaoEstudoRepository) {
        this.sessaoEstudoRepository = sessaoEstudoRepository;
    }

    async execute(sessaoData, userId) {
        try {
            logger.info('Iniciando criação de sessão de estudo', { 
                sessaoData: { ...sessaoData, userId },
                userId 
            });
            
            // 🔒 SEMPRE incluir userId nos dados (isolamento de dados)
            const dadosComUserId = {
                ...sessaoData,
                userId: userId // Garantir que userId vem do JWT validado
            };
            
            const validatedData = SessaoEstudoValidator.validate(dadosComUserId);
            const sessao = await this.sessaoEstudoRepository.create(validatedData);
            
            logger.info('Sessão de estudo criada com sucesso', { 
                sessaoId: sessao.id,
                userId: sessao.userId 
            });

            // 🚀 PUBLICAR EVENTO DE SESSÃO CRIADA (com userId real)
            try {
                await rabbitMQService.publishSessaoCriada(sessao);
                logger.info('📤 Evento de sessão criada publicado', { 
                    sessaoId: sessao.id,
                    userId: sessao.userId 
                });
            } catch (eventError) {
                logger.error('❌ Erro ao publicar evento de sessão criada', { 
                    sessaoId: sessao.id,
                    userId: sessao.userId,
                    error: eventError.message 
                });
                // Não falhar a criação da sessão por erro de evento
            }
            
            return sessao;
        } catch (error) {
            logger.error('Erro ao criar sessão de estudo', { 
                error: error.message,
                userId 
            });
            throw error;
        }
    }
} 