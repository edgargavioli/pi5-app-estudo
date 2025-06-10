import { getChannel } from "../../infrastructure/messaging/rabbitmq.js";
import UserPersistence from "../../infrastructure/persistence/user.js";

const USER_QUEUE = process.env.USER_QUEUE;
const userPersistence = new UserPersistence();

export default async function processUserCreated(msg, chanel) {
    if (msg === null) {
        console.error('Received null message, skipping processing.');
        return;
    }

    const messageContent = msg.content.toString();
    let messageData;

    try {
        messageData = JSON.parse(messageContent);
        messageData = messageData.data || messageData;

        if (!messageData.fcmToken) {
            console.error('FCM token is missing in the message data:', messageData);
            chanel.nack(msg, false, false);
            return;
        }

        // Verificar se o usuário já existe
        try {
            const existingUser = await userPersistence.findByFcmToken(messageData.fcmToken);
            console.log(`User with FCM token ${messageData.fcmToken} already exists, skipping creation.`);
            chanel.ack(msg); // Marcar como processado
            return;
        } catch (error) {
            // Se não encontrar o usuário (erro esperado), criar um novo
            console.log(`Creating new user with FCM token ${messageData.fcmToken}`);
        }

        // Criar novo usuário
        const user = await userPersistence.create({
            id: messageData.userId,  // ✅ Direto, não como objeto aninhado
            fcmToken: messageData.fcmToken,  // ✅ Direto, não como objeto aninhado
        });

        chanel.ack(msg);
        console.log(`✅ User with FCM token ${messageData.fcmToken} created successfully.`);
    } catch (error) {
        console.error('Error processing user created message:', error);
        chanel.nack(msg, false, false);
    }
}

export async function startUserConsumer() {
    try {
        const chanel = await getChannel();
        await chanel.assertQueue(USER_QUEUE, { durable: true });
        console.log('User consumer started, waiting for messages...');

        chanel.consume(USER_QUEUE, async (msg) => {
            await processUserCreated(msg, chanel);
        }, { noAck: false });

    } catch (error) {
        console.error('Error starting user consumer:', error);
        setTimeout(startUserConsumer, 10000);
    }
}