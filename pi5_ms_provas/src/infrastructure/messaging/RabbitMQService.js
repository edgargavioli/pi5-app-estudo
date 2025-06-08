import amqp from 'amqplib';
import { logger } from '../../application/utils/logger.js';

/**
 * RabbitMQ Service - PI5 MS Provas
 * Responsável por publicar eventos de sessões e provas
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
      
      // Eventos que Provas Service CONSOME (do User Service)
      PONTOS_ATUALIZADOS: 'user.pontos.atualizados',
      NIVEL_ALTERADO: 'user.nivel.alterado',
      CONQUISTA_DESBLOQUEADA: 'user.conquista.desbloqueada'
    };

    // Filas que este serviço consome
    this.queues = {
      PROVAS_SYNC: `${this.config.serviceName}.sync.updates`
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
    // Por enquanto, este serviço só publica eventos
    // Mas pode consumir eventos de sincronização no futuro
    await this.channel.assertQueue(this.queues.PROVAS_SYNC, {
      durable: true,
      arguments: {
        'x-dead-letter-exchange': 'pi5_dead_letter',
        'x-dead-letter-routing-key': 'dead',
        'x-max-retries': 3
      }
    });

    logger.info('🔧 Filas RabbitMQ configuradas', {
      queues: Object.keys(this.queues)
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
   * Publica uma mensagem genérica
   */
  async publish(routingKey, message, options = {}) {
    if (!this.isConnected || !this.channel) {
      logger.warn('⚠️ RabbitMQ não conectado, pulando publicação', { routingKey });
      return false;
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
        logger.info('📤 Evento publicado', {
          routingKey,
          messageId: JSON.parse(messageBuffer.toString()).messageId
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

// Singleton instance
const rabbitMQService = new RabbitMQService();
export default rabbitMQService; 