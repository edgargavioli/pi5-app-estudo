import amqp from 'amqplib';

const url_connection = process.env.RABBITMQ_URL || 'amqp://localhost';

let rabbitMQConnection = null;
let chanel = null;

export default async function connectRabbitMQ() {
    if (rabbitMQConnection && chanel) {
        return { rabbitMQConnection, chanel };
    }

    try {
        rabbitMQConnection = await amqp.connect(url_connection);
        chanel = await rabbitMQConnection.createChannel();
        console.log('RabbitMQ connected successfully.');

        rabbitMQConnection.on('error', (error) => {
            console.error('RabbitMQ connection error:', error);

            rabbitMQConnection = null;
            chanel = null;

            setTimeout(connectRabbitMQ, 5000);
        });

        rabbitMQConnection.on('close', () => {
            console.log('RabbitMQ connection closed, attempting to reconnect...');
            rabbitMQConnection = null;
            chanel = null;

            setTimeout(connectRabbitMQ, 5000);
        });

        return { rabbitMQConnection, chanel };
    } catch (error) {
        console.error('Error connecting to RabbitMQ:', error);

        rabbitMQConnection = null;
        chanel = null;
        setTimeout(connectRabbitMQ, 5000);

        throw error;
    }
};

export async function getChannel() {
    if (!chanel) {
        const connection = await connectRabbitMQ();
        chanel = connection.chanel;
    }
    return chanel;
}