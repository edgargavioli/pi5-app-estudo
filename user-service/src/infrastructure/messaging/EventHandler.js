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
  }

  /**
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

    // 2. XP por questões acertadas (10 XP por questão)
    const xpQuestoes = questoesAcertadas * 10;
    xpTotal += xpQuestoes;

    // 3. Bônus por desempenho
    const percentualAcerto = (questoesAcertadas / totalQuestoes) * 100;
    const xpBonus = this.calcularBonusDesempenho(percentualAcerto);
    xpTotal += xpBonus;

    await this.gamificationService.adicionarXP(userId, xpTotal, {
      tipo: 'PROVA_FINALIZADA',
      referencia: provaId,
      descricao: `Prova finalizada: ${percentualAcerto.toFixed(1)}%`,
      detalhes: {
        xpBase,
        xpQuestoes,
        xpBonus,
        questoesAcertadas,
        totalQuestoes,
        percentualAcerto
      }
    });

    // Verificar conquistas relacionadas a provas
    await this.verificarConquistasProva(userId, percentualAcerto);

    // Publicar evento de pontos atualizados
    await this.publishPontosAtualizados(userId, xpTotal, 'PROVA_FINALIZADA');

    logger.info('✅ Prova finalizada processada', {
      userId,
      xpGanho: xpTotal,
      percentualAcerto,
      provaId
    });
  }

  /**
   * Calcula bônus baseado no percentual de acerto
   */
  calcularBonusDesempenho(percentual) {
    if (percentual >= 90) return 50;
    if (percentual >= 80) return 30;
    if (percentual >= 70) return 20;
    if (percentual >= 60) return 10;
    return 0;
  }

  /**
   * Verifica e desbloqueia conquistas relacionadas a sessões
   */
  async verificarConquistasSessao(userId, tempoEstudo) {
    try {
      // Conquista: Maratonista (3+ horas de estudo)
      if (tempoEstudo >= 180) { // 3 horas = 180 minutos
        await this.desbloquearConquista(
          userId,
          'MARATONISTA',
          '3+ horas de estudo em uma sessão'
        );
      }

      // Conquista: Dedicado (estudo consistente)
      // TODO: Implementar lógica para tracking de sessões consecutivas

      logger.info('✅ Conquistas de sessão verificadas', { userId, tempoEstudo });
    } catch (error) {
      logger.error('❌ Erro ao verificar conquistas de sessão', {
        userId,
        error: error.message
      });
    }
  }

  /**
   * Verifica e desbloqueia conquistas relacionadas a provas
   */
  async verificarConquistasProva(userId, percentualAcerto) {
    try {
      // Conquista: Expert (90%+ de acerto)
      if (percentualAcerto >= 90) {
        await this.desbloquearConquista(
          userId,
          'EXPERT',
          '90%+ de acertos em uma prova'
        );
      }

      logger.info('✅ Conquistas de prova verificadas', {
        userId,
        percentualAcerto
      });
    } catch (error) {
      logger.error('❌ Erro ao verificar conquistas de prova', {
        userId,
        error: error.message
      });
    }
  }

  /**
   * Desbloqueia uma conquista específica
   */
  async desbloquearConquista(userId, tipo, descricao) {
    try {
      // TODO: Verificar se a conquista já foi desbloqueada antes
      // Para evitar duplicadas

      await this.gamificationService.desbloquearConquista(userId, tipo, {
        descricao,
        timestamp: new Date()
      });

      logger.info('🏆 Conquista desbloqueada', {
        userId,
        tipo,
        descricao
      });

      // Publicar evento de conquista desbloqueada
      // TODO: Implementar se necessário

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
      const eventData = {
        messageId: `${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
        timestamp: new Date().toISOString(),
        data: {
          userId,
          xpGanho,
          tipo,
          timestamp: new Date()
        }
      };

      await rabbitMQService.publish(
        rabbitMQService.exchanges.USER_POINTS,
        rabbitMQService.routingKeys.PONTOS_ATUALIZADOS,
        eventData
      );

      logger.info('📤 Evento de pontos publicado', {
        userId,
        xpGanho,
        tipo,
        messageId: eventData.messageId
      });

    } catch (error) {
      logger.error('❌ Erro ao publicar evento de pontos', {
        userId,
        error: error.message
      });
    }
  }
}

module.exports = EventHandler;
