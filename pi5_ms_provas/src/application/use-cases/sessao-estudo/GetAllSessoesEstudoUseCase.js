import { logger } from '../../utils/logger.js';

export class GetAllSessoesEstudoUseCase {
    constructor(sessaoEstudoRepository) {
        this.sessaoEstudoRepository = sessaoEstudoRepository;
    }

    async execute(userId, filters = {}) {
        try {
            logger.info('Listando todas as sessões de estudo do usuário', { 
                userId, 
                filters 
            });
            
            // 🔒 SEMPRE filtrar por userId (isolamento de dados)
            const sessoes = await this.sessaoEstudoRepository.findAllByUserId(userId, filters);
            
            logger.info('Sessões listadas com sucesso', { 
                userId,
                total: sessoes.length 
            });
            
            return sessoes;
        } catch (error) {
            logger.error('Erro ao listar sessões de estudo', { 
                userId,
                error: error.message 
            });
            throw error;
        }
    }
} 