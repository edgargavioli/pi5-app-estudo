const amqp = require('amqplib');
const LoggingService = require('./LoggingService');

class QueueService {
  constructor() {
    this.connection = null;
    this.channel = null;
    this.queues = {
      USER_CREATED: 'user_created_queue'
    };
  }

  async connect() {
    try {
      const rabbitmqUrl = process.env.RABBITMQ || 'amqp://localhost:5672';
      this.connection = await amqp.connect(rabbitmqUrl);
      this.channel = await this.connection.createChannel();

      // Declare queues to ensure they exist
      await this.channel.assertQueue(this.queues.USER_CREATED, {
        durable: true // Messages will survive broker restart
      });

      LoggingService.info('Connected to RabbitMQ successfully');
    } catch (error) {
      LoggingService.error('Failed to connect to RabbitMQ', { error: error.message });
      throw error;
    }
  }

  async disconnect() {
    try {
      if (this.channel) {
        await this.channel.close();
      }
      if (this.connection) {
        await this.connection.close();
      }
      LoggingService.info('Disconnected from RabbitMQ');
    } catch (error) {
      LoggingService.error('Error disconnecting from RabbitMQ', { error: error.message });
    }
  }

  async publishUserCreated(userData) {
    try {
      if (!this.channel) {
        await this.connect();
      }

      const message = {
        eventType: 'USER_CREATED',
        timestamp: new Date().toISOString(),
        data: {
          userId: userData.id,
          email: userData.email,
          name: userData.name,
          fcmToken: userData.fcmToken,
          createdAt: userData.createdAt
        }
      };

      const messageBuffer = Buffer.from(JSON.stringify(message));

      const published = this.channel.sendToQueue(
        this.queues.USER_CREATED,
        messageBuffer,
        {
          persistent: true // Message will survive broker restart
        }
      );

      if (published) {
        LoggingService.info('User created message published successfully', {
          userId: userData.id,
          queue: this.queues.USER_CREATED
        });
      } else {
        throw new Error('Failed to publish message to queue');
      }

      return published;
    } catch (error) {
      LoggingService.error('Failed to publish user created message', {
        error: error.message,
        userId: userData.id
      });
      throw error;
    }
  }

  async publishMessage(queueName, message) {
    try {
      if (!this.channel) {
        await this.connect();
      }

      const messageBuffer = Buffer.from(JSON.stringify(message));

      const published = this.channel.sendToQueue(queueName, messageBuffer, {
        persistent: true
      });

      LoggingService.info('Message published successfully', {
        queue: queueName,
        messageType: message.eventType
      });

      return published;
    } catch (error) {
      LoggingService.error('Failed to publish message', {
        error: error.message,
        queue: queueName
      });
      throw error;
    }
  }
}

module.exports = new QueueService();