import amqp from 'amqplib';
import { logger } from '../../application/utils/logger.js';

/**
 * RabbitMQ Service - PI5 MS Provas
 * Responsável por publicar eventos simples de sessões e provas
 * A lógica de personalização de notificações fica no microsserviço de notificações
 */
class RabbitMQService {
  constructor() {
    this.connection = null;
    this.channel = null;
    this.isConnected = false;
    this.reconnectAttempts = 0;
    this.maxReconnectAttempts = 10;
    this.reconnectDelay = 5000;

    // Configurações do ambiente
    this.config = {
      url: process.env.RABBITMQ_URL || 'amqp://admin:admin123@localhost:5672/',
      exchange: process.env.RABBITMQ_EXCHANGE || 'pi5_events',
      serviceName: process.env.SERVICE_NAME || 'provas-service'
    };

    this.routingKeys = {
      // Eventos que Provas Service PUBLICA
      SESSAO_CRIADA: 'provas.sessao.criada',
      SESSAO_FINALIZADA: 'provas.sessao.finalizada',
      PROVA_FINALIZADA: 'provas.prova.finalizada',

      // Eventos CRUD genéricos - alinhados com as filas do consumer
      EVENT_CREATED: 'event.created',
      EVENT_UPDATED: 'event.updated',
      EVENT_DELETED: 'event.deleted',

      // Eventos de exames
      EXAM_CREATED: 'exam.created',
      EXAM_UPDATED: 'exam.updated',
      EXAM_DELETED: 'exam.deleted',

      // Eventos que Provas Service CONSOME (do User Service)
      PONTOS_ATUALIZADOS: 'user.pontos.atualizados',
      NIVEL_ALTERADO: 'user.nivel.alterado',
      CONQUISTA_DESBLOQUEADA: 'user.conquista.desbloqueada'
    };

    // Filas que este serviço consome e publica
    this.queues = {
      PROVAS_SYNC: `${this.config.serviceName}.sync.updates`,
      EVENT_CREATED: process.env.EVENT_QUEUE || 'event.created',
      EVENT_UPDATED: process.env.EVENT_UPDATED_QUEUE || 'event.updated',
      EVENT_DELETED: process.env.EVENT_DELETED_QUEUE || 'event.deleted',
      EXAM_CREATED: process.env.EXAM_QUEUE || 'exam.created',
      EXAM_UPDATED: process.env.EXAM_UPDATED_QUEUE || 'exam.updated',
      EXAM_DELETED: process.env.EXAM_DELETED_QUEUE || 'exam.deleted',
      SESSAO_CRIADA: process.env.SESSAO_CRIADA_QUEUE || 'sessao.criada',
      SESSAO_FINALIZADA: process.env.SESSAO_FINALIZADA_QUEUE || 'sessao.finalizada'
    };
  }

  /**
   * Conecta ao RabbitMQ com retry automático
   */
  async connect() {
    try {
      logger.info('Tentando conectar ao RabbitMQ...', {
        url: this.config.url.replace(/\/\/.*@/, '//***:***@'),
        attempt: this.reconnectAttempts + 1
      });

      this.connection = await amqp.connect(this.config.url);
      this.channel = await this.connection.createChannel();

      // Configurar tratamento de erros
      this.connection.on('error', this.handleConnectionError.bind(this));
      this.connection.on('close', this.handleConnectionClose.bind(this));
      this.channel.on('error', this.handleChannelError.bind(this));

      // Configurar exchange principal
      await this.channel.assertExchange(this.config.exchange, 'topic', {
        durable: true,
        autoDelete: false
      });

      // Configurar filas se necessário
      await this.setupQueues();

      this.isConnected = true;
      this.reconnectAttempts = 0;

      logger.info('✅ Conectado ao RabbitMQ com sucesso!', {
        exchange: this.config.exchange,
        serviceName: this.config.serviceName
      });

      return true;
    } catch (error) {
      logger.error('❌ Erro ao conectar ao RabbitMQ', {
        error: error.message,
        attempt: this.reconnectAttempts + 1
      });

      await this.handleReconnect();
      return false;
    }
  }

  /**
   * Configura filas necessárias (se houver)
   */
  async setupQueues() {
    // Configurar filas CRUD - removendo argumentos específicos que podem causar conflito
    for (const [queueName, queueKey] of Object.entries(this.queues)) {
      try {
        await this.channel.assertQueue(queueKey, {
          durable: true
          // Removidos argumentos específicos para evitar conflitos com filas existentes
        });
      } catch (error) {
        logger.warn(`⚠️ Erro ao configurar fila ${queueKey}, tentando sem argumentos`, {
          error: error.message
        });

        // Tentar criar fila básica sem argumentos adicionais
        await this.channel.assertQueue(queueKey, {
          durable: true
        });
      }
    }

    logger.info('🔧 Filas RabbitMQ configuradas', {
      queues: Object.values(this.queues)
    });
  }

  /**
   * Publica evento de sessão criada
   */
  async publishSessaoCriada(sessaoData) {
    const event = {
      data: {
        userId: sessaoData.userId || 'user-default', // TODO: Implementar autenticação
        sessaoId: sessaoData.id,
        materiaId: sessaoData.materiaId,
        provaId: sessaoData.provaId,
        tempoInicio: sessaoData.tempoInicio,
        conteudo: sessaoData.conteudo,
        topicos: sessaoData.topicos
      }
    };

    return this.publish(this.routingKeys.SESSAO_CRIADA, event);
  }

  /**
   * Publica evento de sessão finalizada
   */
  async publishSessaoFinalizada(sessaoData) {
    // Calcular tempo de estudo em minutos
    const tempoInicioMs = new Date(sessaoData.tempoInicio).getTime();
    const tempoFimMs = new Date(sessaoData.tempoFim).getTime();
    const tempoEstudoMinutos = Math.floor((tempoFimMs - tempoInicioMs) / (1000 * 60));

    const event = {
      data: {
        userId: sessaoData.userId || 'user-default', // TODO: Implementar autenticação
        sessaoId: sessaoData.id,
        materiaId: sessaoData.materiaId,
        provaId: sessaoData.provaId,
        tempoEstudo: tempoEstudoMinutos,
        tempoInicio: sessaoData.tempoInicio,
        tempoFim: sessaoData.tempoFim,
        conteudo: sessaoData.conteudo,
        questoesAcertadas: sessaoData.questoesAcertadas || 0,
        totalQuestoes: sessaoData.totalQuestoes || 0
      }
    };

    return this.publish(this.routingKeys.SESSAO_FINALIZADA, event);
  }

  /**
   * Publica evento de prova finalizada
   */
  async publishProvaFinalizada(provaData) {
    const event = {
      data: {
        userId: provaData.userId || 'user-default', // TODO: Implementar autenticação
        provaId: provaData.id,
        materiaId: provaData.materiaId,
        questoesAcertadas: provaData.questoesAcertadas,
        totalQuestoes: provaData.totalQuestoes,
        percentualAcerto: provaData.percentualAcerto,
        dataRealizacao: provaData.dataRealizacao || new Date().toISOString()
      }
    };

    return this.publish(this.routingKeys.PROVA_FINALIZADA, event);
  }

  /**
   * Publica evento de entidade criada
   */
  async publishEntityCreated(entityType, entityData, userId = null) {
    const event = {
      data: {
        entityType,
        entityId: entityData.id,
        entityData,
        userId: userId || entityData.userId || 'user-default',
        action: 'CREATED'
      }
    };

    return this.publish(this.routingKeys.EVENT_CREATED, event);
  }

  /**
   * Publica evento de entidade editada
   */
  async publishEntityUpdated(entityType, entityId, updatedData, previousData = null, userId = null) {
    const event = {
      data: {
        entityType,
        entityId,
        updatedData,
        previousData,
        userId: userId || updatedData.userId || 'user-default',
        action: 'UPDATED'
      }
    };

    return this.publish(this.routingKeys.EVENT_UPDATED, event);
  }

  /**
   * Publica evento de entidade deletada
   */
  async publishEntityDeleted(entityType, entityId, deletedData = null, userId = null) {
    const event = {
      data: {
        entityType,
        entityId,
        deletedData,
        userId: userId || deletedData?.userId || 'user-default',
        action: 'DELETED'
      }
    };

    return this.publish(this.routingKeys.EVENT_DELETED, event);
  }
  /**
   * Publica evento de prova criada
   */
  async publishExamCreated(examType, examData, userId = null) {
    const event = {
      data: examData
    };

    // Usar a routing key específica para notificações de prova
    return this.publish('notificacao.prova.criada', event);
  }

  /**
   * Publica evento de exame editado
   */
  async publishExamUpdated(examType, examId, updatedData, previousData = null, userId = null) {
    const event = {
      data: {
        examType,
        examId,
        updatedData,
        previousData,
        userId: userId || updatedData.userId || 'user-default',
        action: 'UPDATED'
      }
    };

    return this.publish(this.queues.EXAM_UPDATED, event);
  }

  /**
   * Publica evento de exame deletado
   */
  async publishExamDeleted(examType, examId, deletedData = null, userId = null) {
    const event = {
      data: {
        examType,
        examId,
        deletedData,
        userId: userId || deletedData?.userId || 'user-default',
        action: 'DELETED'
      }
    };

    return this.publish(this.routingKeys.EXAM_DELETED, event);
  }

  /**
   * Producer genérico para eventos CRUD
   * @param {string} action - 'created', 'updated' ou 'deleted'
   * @param {string} entityType - Tipo da entidade (ex: 'prova', 'sessao', 'questao')
   * @param {string} entityId - ID da entidade
   * @param {Object} data - Dados da entidade
   * @param {Object} options - Opções adicionais (userId, previousData, etc.)
   */
  async publishCrudEvent(action, entityType, entityId, data, options = {}) {
    const routingKeyMap = {
      created: this.routingKeys.EVENT_CREATED,
      updated: this.routingKeys.EVENT_UPDATED,
      deleted: this.routingKeys.EVENT_DELETED
    };

    const routingKey = routingKeyMap[action.toLowerCase()];
    if (!routingKey) {
      logger.error('❌ Ação CRUD inválida', { action, validActions: Object.keys(routingKeyMap) });
      return false;
    }

    const event = {
      data: {
        entityType,
        entityId,
        entityData: data,
        userId: options.userId || data?.userId || 'user-default',
        action: action.toUpperCase(),
        ...(action === 'updated' && options.previousData && { previousData: options.previousData }),
        ...(options.metadata && { metadata: options.metadata })
      }
    };

    return this.publish(routingKey, event);
  }

  /**
   * Producer genérico para eventos de exames
   * @param {string} action - 'created', 'updated' ou 'deleted'
   * @param {string} examType - Tipo do exame (ex: 'prova', 'simulado', 'teste')
   * @param {string} examId - ID do exame
   * @param {Object} data - Dados do exame
   * @param {Object} options - Opções adicionais (userId, previousData, etc.)
   */
  async publishExamEvent(action, examType, examId, data, options = {}) {
    const routingKeyMap = {
      created: this.routingKeys.EXAM_CREATED,
      updated: this.routingKeys.EXAM_UPDATED,
      deleted: this.routingKeys.EXAM_DELETED
    };

    const routingKey = routingKeyMap[action.toLowerCase()];
    if (!routingKey) {
      logger.error('❌ Ação de exame inválida', { action, validActions: Object.keys(routingKeyMap) });
      return false;
    }

    const event = {
      data: {
        examType,
        examId,
        examData: data,
        userId: options.userId || data?.userId || 'user-default',
        action: action.toUpperCase(),
        ...(action === 'updated' && options.previousData && { previousData: options.previousData }),
        ...(options.metadata && { metadata: options.metadata })
      }
    };

    return this.publish(routingKey, event);
  }

  /**
   * Método básico para publicar eventos
   */
  async publish(routingKey, data, options = {}) {
    if (!this.isConnected || !this.channel) {
      logger.error('❌ RabbitMQ não conectado para publicar evento', { routingKey });
      return false;
    }

    try {
      const message = {
        messageId: `${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
        timestamp: new Date().toISOString(),
        source: this.config.serviceName,
        routingKey,
        data
      };

      const messageBuffer = Buffer.from(JSON.stringify(message));

      const published = await this.channel.publish(
        this.config.exchange,
        routingKey,
        messageBuffer,
        {
          persistent: true,
          timestamp: Date.now(),
          ...options
        }
      );

      if (published) {
        logger.info('📤 Evento publicado com sucesso', {
          routingKey,
          messageId: message.messageId,
          exchange: this.config.exchange
        });
      }

      return published;
    } catch (error) {
      logger.error('❌ Erro ao publicar evento', {
        routingKey,
        error: error.message
      });
      return false;
    }
  }

  /**
   * Publica evento simples de notificação para evento criado
   */
  async publishEventoNotificacao(eventoData) {
    const event = {
      data: {
        ...eventoData,
        userId: eventoData.userId || 'user-default'
      }
    };

    return this.publish('notificacao.evento.criado', event);
  }

  /**
   * Publica evento simples de notificação para sessão criada
   */
  async publishSessaoNotificacao(sessaoData) {
    const event = {
      data: {
        ...sessaoData,
        userId: sessaoData.userId || 'user-default'
      }
    };

    return this.publish('notificacao.sessao.criada', event);
  }

  /**
   * Tratamento de erro de conexão
   */
  handleConnectionError(error) {
    logger.error('❌ Erro na conexão RabbitMQ', { error: error.message });
    this.isConnected = false;
  }

  /**
   * Tratamento de fechamento de conexão
   */
  async handleConnectionClose() {
    logger.warn('⚠️ Conexão RabbitMQ fechada. Tentando reconectar...');
    this.isConnected = false;
    await this.handleReconnect();
  }

  /**
   * Tratamento de erro de canal
   */
  handleChannelError(error) {
    logger.error('❌ Erro no canal RabbitMQ', { error: error.message });
    this.isConnected = false;
  }

  /**
   * Lógica de reconexão automática
   */
  async handleReconnect() {
    if (this.reconnectAttempts >= this.maxReconnectAttempts) {
      logger.error('❌ Máximo de tentativas de reconexão atingido');
      return;
    }

    this.reconnectAttempts++;
    logger.info(`🔄 Tentativa de reconexão ${this.reconnectAttempts}/${this.maxReconnectAttempts} em ${this.reconnectDelay}ms...`);

    setTimeout(() => {
      this.connect();
    }, this.reconnectDelay);
  }

  /**
   * Fecha a conexão
   */
  async close() {
    try {
      if (this.channel) {
        await this.channel.close();
      }
      if (this.connection) {
        await this.connection.close();
      }
      this.isConnected = false;
      logger.info('✅ Conexão RabbitMQ fechada com sucesso');
    } catch (error) {
      logger.error('❌ Erro ao fechar conexão RabbitMQ', { error: error.message });
    }
  }
  /**
   * Verifica se a conexão está saudável
   */
  isHealthy() {
    return this.isConnected && this.connection && this.channel;
  }
}

// Singleton - criar única instância do serviço
const rabbitMQServiceInstance = new RabbitMQService();

export default rabbitMQServiceInstance;
