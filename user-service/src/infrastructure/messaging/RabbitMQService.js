const amqp = require('amqplib');
const logger = require('../utils/logger');

/**
 * RabbitMQ Service - Infrastructure Layer
 * Gerencia conexões, canais, filas e exchanges do RabbitMQ
 * Implementa retry, dead letter queues e alta disponibilidade
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
      url: process.env.RABBITMQ || process.env.RABBITMQ_URL || 'amqp://admin:admin123@localhost:5672/',
      exchange: process.env.RABBITMQ_EXCHANGE || 'pi5_events',
      serviceName: process.env.SERVICE_NAME || 'user-service'
    };

    // Definição de filas e routing keys
    this.queues = {
      // User Service Queues
      USER_POINTS_UPDATES: `${this.config.serviceName}.points.updates`,
      USER_ACHIEVEMENTS: `${this.config.serviceName}.achievements`,

      // Dead Letter Queue
      DEAD_LETTER: `${this.config.serviceName}.dead_letter`
    };

    this.routingKeys = {
      // Eventos que User Service CONSOME (de Provas Service)
      SESSAO_CRIADA: 'provas.sessao.criada',
      SESSAO_FINALIZADA: 'provas.sessao.finalizada',
      PROVA_FINALIZADA: 'provas.prova.finalizada',

      // Eventos que User Service PUBLICA
      PONTOS_ATUALIZADOS: 'user.pontos.atualizados',
      NIVEL_ALTERADO: 'user.nivel.alterado',
      CONQUISTA_DESBLOQUEADA: 'user.conquista.desbloqueada'
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

      // Configurar filas
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
   * Configura todas as filas necessárias
   */
  async setupQueues() {
    // Dead Letter Exchange
    await this.channel.assertExchange('pi5_dead_letter', 'direct', {
      durable: true
    });

    // Dead Letter Queue
    await this.channel.assertQueue(this.queues.DEAD_LETTER, {
      durable: true,
      arguments: {
        'x-message-ttl': 24 * 60 * 60 * 1000 // 24 horas
      }
    });

    await this.channel.bindQueue(
      this.queues.DEAD_LETTER,
      'pi5_dead_letter',
      'dead'
    );

    // Fila de atualizações de pontos
    await this.channel.assertQueue(this.queues.USER_POINTS_UPDATES, {
      durable: true,
      arguments: {
        'x-dead-letter-exchange': 'pi5_dead_letter',
        'x-dead-letter-routing-key': 'dead',
        'x-max-retries': 3
      }
    });

    // Fila de conquistas
    await this.channel.assertQueue(this.queues.USER_ACHIEVEMENTS, {
      durable: true,
      arguments: {
        'x-dead-letter-exchange': 'pi5_dead_letter',
        'x-dead-letter-routing-key': 'dead',
        'x-max-retries': 3
      }
    });

    // Bind das filas aos routing keys
    await this.channel.bindQueue(
      this.queues.USER_POINTS_UPDATES,
      this.config.exchange,
      this.routingKeys.SESSAO_CRIADA
    );

    await this.channel.bindQueue(
      this.queues.USER_POINTS_UPDATES,
      this.config.exchange,
      this.routingKeys.SESSAO_FINALIZADA
    );

    await this.channel.bindQueue(
      this.queues.USER_POINTS_UPDATES,
      this.config.exchange,
      this.routingKeys.PROVA_FINALIZADA
    );

    logger.info('🔧 Filas RabbitMQ configuradas com sucesso', {
      queues: Object.keys(this.queues),
      routingKeys: Object.keys(this.routingKeys)
    });
  }

  /**
   * Publica uma mensagem
   */
  async publish(routingKey, message, options = {}) {
    if (!this.isConnected || !this.channel) {
      throw new Error('RabbitMQ não está conectado');
    }

    try {
      const messageBuffer = Buffer.from(JSON.stringify({
        ...message,
        timestamp: new Date().toISOString(),
        service: this.config.serviceName,
        messageId: `${Date.now()}-${Math.random().toString(36).substr(2, 9)}`
      }));

      const publishOptions = {
        persistent: true,
        timestamp: Date.now(),
        ...options
      };

      const published = this.channel.publish(
        this.config.exchange,
        routingKey,
        messageBuffer,
        publishOptions
      );

      if (published) {
        logger.info('📤 Mensagem publicada', {
          routingKey,
          messageId: JSON.parse(messageBuffer.toString()).messageId
        });
      }

      return published;
    } catch (error) {
      logger.error('❌ Erro ao publicar mensagem', {
        routingKey,
        error: error.message
      });
      throw error;
    }
  }

  /**
   * Consome mensagens de uma fila
   */
  async consume(queueName, handler, options = {}) {
    if (!this.isConnected || !this.channel) {
      throw new Error('RabbitMQ não está conectado');
    }

    try {
      await this.channel.consume(queueName, async (message) => {
        if (!message) return;

        try {
          const content = JSON.parse(message.content.toString());

          logger.info('📥 Mensagem recebida', {
            queue: queueName,
            routingKey: message.fields.routingKey,
            messageId: content.messageId
          });

          // Executar handler
          await handler(content, message);

          // Acknowledge da mensagem
          this.channel.ack(message);

          logger.info('✅ Mensagem processada com sucesso', {
            messageId: content.messageId
          });

        } catch (error) {
          logger.error('❌ Erro ao processar mensagem', {
            error: error.message,
            messageId: message.properties?.messageId
          });

          // Reject e requeue (será enviado para dead letter após max retries)
          this.channel.nack(message, false, false);
        }
      }, {
        noAck: false,
        ...options
      });

      logger.info(`👂 Consumindo fila: ${queueName}`);
    } catch (error) {
      logger.error('❌ Erro ao configurar consumer', {
        queue: queueName,
        error: error.message
      });
      throw error;
    }
  }

  /**
   * Manipula erros de conexão
   */
  handleConnectionError(error) {
    logger.error('❌ Erro de conexão RabbitMQ', { error: error.message });
    this.isConnected = false;
  }

  /**
   * Manipula fechamento de conexão
   */
  async handleConnectionClose() {
    logger.warn('⚠️ Conexão RabbitMQ fechada');
    this.isConnected = false;
    await this.handleReconnect();
  }

  /**
   * Manipula erros de canal
   */
  handleChannelError(error) {
    logger.error('❌ Erro de canal RabbitMQ', { error: error.message });
  }

  /**
   * Gerencia reconexão automática
   */
  async handleReconnect() {
    if (this.reconnectAttempts >= this.maxReconnectAttempts) {
      logger.error('💀 Máximo de tentativas de reconexão atingido');
      return;
    }

    this.reconnectAttempts++;

    logger.info(`🔄 Tentativa de reconexão ${this.reconnectAttempts}/${this.maxReconnectAttempts}...`);

    setTimeout(async () => {
      await this.connect();
    }, this.reconnectDelay);
  }

  /**
   * Fecha conexão graciosamente
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
      logger.info('🔒 Conexão RabbitMQ fechada');
    } catch (error) {
      logger.error('❌ Erro ao fechar conexão RabbitMQ', { error: error.message });
    }
  }

  /**
   * Verifica se está conectado
   */
  isHealthy() {
    return this.isConnected && this.connection && !this.connection.connection.stream.destroyed;
  }
}

module.exports = new RabbitMQService(); 