const logger = require('../utils/logger');
const GamificationService = require('../services/GamificationService');
const rabbitMQService = require('./RabbitMQService');

/**
 * Event Handler - Processa eventos recebidos via RabbitMQ
 * Responsável por atualizar pontos, achievements e estatísticas
 */
class EventHandler {
  constructor() {
    this.gamificationService = new GamificationService();
  }

  /**
   * Inicia o consumo de eventos
   */
  async startConsumers() {
    try {
      // Consumer para atualizações de pontos
      await rabbitMQService.consume(
        rabbitMQService.queues.USER_POINTS_UPDATES,
        this.handlePointsUpdate.bind(this)
      );

      logger.info('🎮 Event Handlers iniciados com sucesso');
    } catch (error) {
      logger.error('❌ Erro ao iniciar Event Handlers', { error: error.message });
      throw error;
    }
  }
  /**
   * Processa eventos de atualização de pontos
   */
  async handlePointsUpdate(message, rawMessage) {
    const { routingKey } = rawMessage.fields;

    try {
      logger.info('🎯 Processando evento de pontos', {
        routingKey,
        messageId: message.messageId
      });

      switch (routingKey) {
        case rabbitMQService.routingKeys.SESSAO_CRIADA:
          // DESABILITADO: Não processar XP na criação, apenas na finalização
          logger.info('📚 Sessão criada detectada, mas XP será processado apenas na finalização');
          break;

        case rabbitMQService.routingKeys.SESSAO_FINALIZADA:
          await this.handleSessaoFinalizada(message);
          break;

        case rabbitMQService.routingKeys.PROVA_FINALIZADA:
          await this.handleProvaFinalizada(message);
          break;

        default:
          logger.warn('⚠️ Routing key não reconhecido', { routingKey });
      }

    } catch (error) {
      logger.error('❌ Erro ao processar evento de pontos', {
        error: error.message,
        messageId: message.messageId,
        routingKey
      });
      throw error; // Vai para dead letter queue
    }
  }/**
   * Processa criação de sessão de estudo
   */
  async handleSessaoCriada(message) {
    // Debug: log da mensagem completa
    logger.info('🔍 DEBUG - Mensagem recebida para sessão criada', {
      messageComplete: message,
      messageData: message.data,
      userId: message.data?.userId,
      userIdNested: message.data?.data?.userId
    });

    // Verificar se os dados estão aninhados ou não
    let userData;
    if (message.data?.data?.userId) {
      // Estrutura aninhada: message.data.data.*
      userData = message.data.data;
      logger.info('🔍 Usando estrutura aninhada (data.data)');
    } else if (message.data?.userId) {
      // Estrutura direta: message.data.*
      userData = message.data;
      logger.info('🔍 Usando estrutura direta (data)');
    } else {
      logger.error('❌ Estrutura de mensagem não reconhecida', { message });
      throw new Error('Estrutura de mensagem inválida');
    } const { userId, sessaoId, materiaId, provaId } = userData;

    logger.info('🔍 Dados extraídos da mensagem', {
      userId: userId,
      typeOfUserId: typeof userId,
      sessaoId,
      materiaId,
      provaId,
      userData: userData
    });

    logger.info('📚 Processando sessão criada', {
      userId,
      sessaoId,
      materiaId,
      provaId
    });

    // Gamificação: +10 XP por criar sessão
    const xpGanho = 10;

    await this.gamificationService.adicionarXP(userId, xpGanho, {
      tipo: 'SESSAO_CRIADA',
      referencia: sessaoId,
      descricao: 'Sessão de estudo criada'
    });

    // Publicar evento de pontos atualizados
    await this.publishPontosAtualizados(userId, xpGanho, 'SESSAO_CRIADA');

    logger.info('✅ Sessão criada processada', {
      userId,
      xpGanho,
      sessaoId
    });
  }  /**
   * Processa finalização de sessão de estudo
   * ATUALIZADO: Usar GamificationService para consistência
   */
  async handleSessaoFinalizada(message) {
    // Verificar se os dados estão aninhados ou não
    let userData;
    if (message.data?.data?.userId) {
      // Estrutura aninhada: message.data.data.*
      userData = message.data.data;
      logger.info('🔍 Usando estrutura aninhada (data.data) para sessão finalizada');
    } else if (message.data?.userId) {
      // Estrutura direta: message.data.*
      userData = message.data;
      logger.info('🔍 Usando estrutura direta (data) para sessão finalizada');
    } else {
      logger.error('❌ Estrutura de mensagem não reconhecida', { message });
      throw new Error('Estrutura de mensagem inválida');
    }

    const {
      userId,
      sessaoId,
      materiaId,
      provaId,
      tempoEstudo, // em minutos
      questoesAcertadas = 0,
      totalQuestoes = 0,
      isAgendada = false,
      cumpriuPrazo = null
    } = userData;

    logger.info('🏁 Processando sessão finalizada', {
      userId,
      sessaoId,
      tempoEstudo,
      questoesAcertadas,
      totalQuestoes,
      isAgendada,
      cumpriuPrazo
    });

    // Usar GamificationService para cálculo consistente
    const resultado = await this.gamificationService.processarFinalizacaoSessao(userId, {
      id: sessaoId,
      tempoEstudoMinutos: tempoEstudo,
      isAgendada,
      cumpriuPrazo,
      questoesAcertadas,
      totalQuestoes
    });

    // Publicar evento de pontos atualizados
    await this.publishPontosAtualizados(userId, resultado.xpGanho, 'SESSAO_FINALIZADA');

    logger.info('✅ Sessão finalizada processada via EventHandler', {
      userId,
      sessaoId,
      xpGanho: resultado.xpGanho,
      xpTotal: resultado.xpTotal,
      nivel: resultado.nivel,
      subiumLevel: resultado.subiumLevel
    });
  }
    });    // Verificar conquistas relacionadas a sessões
    await this.verificarConquistasSessao(userId, tempoEstudo);

    // Atualizar streak se a sessão teve tempo suficiente (> 10 segundos)
    if (tempoEstudo > 0.17) { // 0.17 minutos = ~10 segundos
      try {
        const StreakController = require('../../presentation/controllers/StreakController');
        await StreakController.updateStreakFromEvent(userId, tempoEstudo);
        logger.info('✅ Streak atualizada via evento', {
          userId,
          tempoEstudo,
          sessaoId
        });
      } catch (error) {
        logger.error('❌ Erro ao atualizar streak via evento', {
          error: error.message,
          userId,
          sessaoId
        });
      }
    }

    // Publicar evento de pontos atualizados
    await this.publishPontosAtualizados(userId, xpTotal, 'SESSAO_FINALIZADA');

    logger.info('✅ Sessão finalizada processada', {
      userId,
      xpTotal,
      breakdown: { xpBase, xpTempo, xpQuestoes, xpBonus },
      sessaoId
    });
  }

  /**
   * Processa finalização de prova
   */
  async handleProvaFinalizada(message) {
    const {
      userId,
      provaId,
      questoesAcertadas,
      totalQuestoes,
      materiaId
    } = message.data;

    logger.info('🎓 Processando prova finalizada', {
      userId,
      provaId,
      questoesAcertadas,
      totalQuestoes
    });

    let xpTotal = 0;

    // 1. XP base por finalizar prova
    const xpBase = 50;
    xpTotal += xpBase;

    // 2. XP por questões acertadas
    const xpQuestoes = questoesAcertadas * 5;
    xpTotal += xpQuestoes;

    // 3. Bônus por desempenho
    const percentualAcerto = (questoesAcertadas / totalQuestoes) * 100;
    const xpBonus = this.calcularBonusDesempenho(percentualAcerto);
    xpTotal += xpBonus;

    await this.gamificationService.adicionarXP(userId, xpTotal, {
      tipo: 'PROVA_FINALIZADA',
      referencia: provaId,
      descricao: `Prova finalizada: ${questoesAcertadas}/${totalQuestoes}`,
      detalhes: {
        xpBase,
        xpQuestoes,
        xpBonus,
        percentualAcerto,
        questoesAcertadas,
        totalQuestoes
      }
    });

    // Verificar conquistas relacionadas a provas
    await this.verificarConquistasProva(userId, percentualAcerto);

    // Publicar evento de pontos atualizados
    await this.publishPontosAtualizados(userId, xpTotal, 'PROVA_FINALIZADA');

    logger.info('✅ Prova finalizada processada', {
      userId,
      xpTotal,
      percentualAcerto,
      breakdown: { xpBase, xpQuestoes, xpBonus },
      provaId
    });
  }

  /**
   * Calcula bônus de desempenho baseado no percentual de acerto
   */
  calcularBonusDesempenho(percentual) {
    if (percentual >= 90) return 30; // Excelente
    if (percentual >= 80) return 20; // Muito bom
    if (percentual >= 70) return 10; // Bom
    if (percentual >= 60) return 5;  // Regular
    return 0; // Abaixo de 60%
  }

  /**
   * Verifica conquistas relacionadas a sessões
   */
  async verificarConquistasSessao(userId, tempoEstudo) {
    try {
      const stats = await this.gamificationService.obterEstatisticas(userId);

      // Conquista: Primeira sessão
      if (stats.totalSessoes === 1) {
        await this.desbloquearConquista(userId, 'PRIMEIRA_SESSAO', 'Primeira sessão de estudo!');
      }

      // Conquista: Sessão longa (mais de 60 minutos)
      if (tempoEstudo >= 60) {
        await this.desbloquearConquista(userId, 'SESSAO_LONGA', 'Estudou por mais de 1 hora!');
      }

      // Conquista: 10 sessões
      if (stats.totalSessoes === 10) {
        await this.desbloquearConquista(userId, 'DEZ_SESSOES', '10 sessões de estudo!');
      }

    } catch (error) {
      logger.error('❌ Erro ao verificar conquistas de sessão', {
        userId,
        error: error.message
      });
    }
  }

  /**
   * Verifica conquistas relacionadas a provas
   */
  async verificarConquistasProva(userId, percentualAcerto) {
    try {
      const stats = await this.gamificationService.obterEstatisticas(userId);

      // Conquista: Primeira prova
      if (stats.provasRealizadas === 1) {
        await this.desbloquearConquista(userId, 'PRIMEIRA_PROVA', 'Primeira prova realizada!');
      }

      // Conquista: Nota perfeita
      if (percentualAcerto === 100) {
        await this.desbloquearConquista(userId, 'NOTA_PERFEITA', 'Acertou 100% das questões!');
      }

      // Conquista: 5 provas
      if (stats.provasRealizadas === 5) {
        await this.desbloquearConquista(userId, 'CINCO_PROVAS', '5 provas realizadas!');
      }

    } catch (error) {
      logger.error('❌ Erro ao verificar conquistas de prova', {
        userId,
        error: error.message
      });
    }
  }

  /**
   * Desbloqueia uma conquista
   */
  async desbloquearConquista(userId, tipo, descricao) {
    try {
      const achievement = await this.gamificationService.desbloquearConquista(userId, {
        tipo,
        descricao,
        dataDesbloqueio: new Date()
      });

      if (achievement) {
        // Publicar evento de conquista desbloqueada
        await rabbitMQService.publish(
          rabbitMQService.routingKeys.CONQUISTA_DESBLOQUEADA,
          {
            data: {
              userId,
              conquista: achievement
            }
          }
        );

        logger.info('🏆 Conquista desbloqueada', {
          userId,
          tipo,
          descricao
        });
      }

    } catch (error) {
      logger.error('❌ Erro ao desbloquear conquista', {
        userId,
        tipo,
        error: error.message
      });
    }
  }

  /**
   * Publica evento de pontos atualizados
   */
  async publishPontosAtualizados(userId, xpGanho, tipo) {
    try {
      const stats = await this.gamificationService.obterEstatisticas(userId);

      await rabbitMQService.publish(
        rabbitMQService.routingKeys.PONTOS_ATUALIZADOS,
        {
          data: {
            userId,
            xpGanho,
            xpTotal: stats.xpTotal,
            nivel: stats.nivel,
            progressoNivel: stats.progressoNivel,
            tipo
          }
        }
      );

      logger.debug('📊 Evento de pontos publicado', {
        userId,
        xpGanho,
        tipo
      });

    } catch (error) {
      logger.error('❌ Erro ao publicar pontos atualizados', {
        userId,
        error: error.message
      });
    }
  }
}

module.exports = EventHandler; 