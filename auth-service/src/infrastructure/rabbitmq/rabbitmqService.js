const amqp = require('amqplib');
require('dotenv').config();

let connection = null;
let channel = null;
const exchangeName = process.env.RABBITMQ_EXCHANGE || 'auth_events';

/**
 * Conecta ao servidor RabbitMQ
 * @returns {Promise<void>}
 */
const connect = async () => {
  try {
    connection = await amqp.connect(process.env.RABBITMQ_URL || 'amqp://localhost:5672');
    channel = await connection.createChannel();
    
    // Declarar um exchange do tipo 'topic' para permitir roteamento por chaves específicas
    await channel.assertExchange(exchangeName, 'topic', {
      durable: true // O exchange sobrevive a reinicializações do broker
    });
    
    console.log('Conectado ao RabbitMQ');
  } catch (error) {
    console.error('Erro ao conectar ao RabbitMQ:', error);
    // Tentar reconectar após um tempo
    setTimeout(connect, 5000);
  }
};

/**
 * Fecha a conexão com o RabbitMQ
 * @returns {Promise<void>}
 */
const close = async () => {
  if (channel) await channel.close();
  if (connection) await connection.close();
  console.log('Conexão com RabbitMQ fechada');
};

/**
 * Publica um evento no exchange
 * @param {string} routingKey - Chave de roteamento (ex: 'user.registered')
 * @param {Object} data - Dados a serem publicados
 * @returns {Promise<boolean>} - True se publicado com sucesso
 */
const publishEvent = async (routingKey, data) => {
  try {
    if (!channel) {
      await connect();
    }
    
    // Converter o objeto para string
    const message = JSON.stringify(data);
    
    // Publicar a mensagem com a routing key específica
    const published = channel.publish(
      exchangeName,
      routingKey,
      Buffer.from(message),
      {
        persistent: true, // Mensagem persistente para sobreviver a reinicializações do broker
        contentType: 'application/json'
      }
    );
    
    console.log(`Evento publicado: ${routingKey}`, data);
    return published;
  } catch (error) {
    console.error(`Erro ao publicar evento '${routingKey}':`, error);
    // Se perdemos a conexão, tentar reconectar
    if (error.message.includes('channel closed')) {
      channel = null;
      await connect();
    }
    throw error;
  }
};

/**
 * Publica um evento de usuário registrado
 * @param {Object} user - Dados do usuário
 * @returns {Promise<boolean>} - True se publicado com sucesso
 */
const publishUserRegistered = async (user) => {
  // Enviar apenas dados essenciais, não sensíveis
  const userData = {
    id: user.id,
    email: user.email,
    status: user.status,
    createdAt: user.createdAt
  };
  
  return publishEvent('user.registered', userData);
};

/**
 * Publica um evento de email verificado
 * @param {string} userId - ID do usuário
 * @param {string} email - Email do usuário
 * @returns {Promise<boolean>} - True se publicado com sucesso
 */
const publishEmailVerified = async (userId, email) => {
  return publishEvent('user.email_verified', { userId, email });
};

/**
 * Publica um evento de senha alterada
 * @param {string} userId - ID do usuário
 * @returns {Promise<boolean>} - True se publicado com sucesso
 */
const publishPasswordChanged = async (userId) => {
  return publishEvent('user.password_changed', { userId });
};

/**
 * Publica um evento de conta bloqueada
 * @param {string} userId - ID do usuário
 * @param {string} reason - Motivo do bloqueio
 * @returns {Promise<boolean>} - True se publicado com sucesso
 */
const publishAccountBlocked = async (userId, reason) => {
  return publishEvent('user.account_blocked', { userId, reason });
};

/**
 * Publica um evento de conta desbloqueada
 * @param {string} userId - ID do usuário
 * @returns {Promise<boolean>} - True se publicado com sucesso
 */
const publishAccountUnblocked = async (userId) => {
  return publishEvent('user.account_unblocked', { userId });
};

module.exports = {
  connect,
  close,
  publishEvent,
  publishUserRegistered,
  publishEmailVerified,
  publishPasswordChanged,
  publishAccountBlocked,
  publishAccountUnblocked
}; 