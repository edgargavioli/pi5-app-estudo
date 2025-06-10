import { getChannel } from "../../infrastructure/messaging/rabbitmq.js";
import UserPersistence from "../../infrastructure/persistence/user.js";

const FCM_TOKEN_UPDATED_QUEUE = process.env.FCM_TOKEN_UPDATED_QUEUE || 'fcm_token_updated_queue';
const userPersistence = new UserPersistence();

export default async function processFcmTokenUpdated(msg, chanel) {
    if (msg === null) {
        console.error('Received null message, skipping processing.');
        return;
    }

    const messageContent = msg.content.toString();
    let messageData;

    try {
        messageData = JSON.parse(messageContent);
        const eventData = messageData.data || messageData;

        console.log('📱 Processing FCM token update:', eventData);

        if (!eventData.userId || !eventData.fcmToken) {
            console.error('Message missing required data (userId or fcmToken), skipping processing.', eventData);
            chanel.nack(msg, false, false);
            return;
        }

        // Atualizar FCM token do usuário
        await userPersistence.updateFcmToken(eventData.userId, eventData.fcmToken);

        console.log(`✅ FCM token updated successfully for user ${eventData.userId}`);
        chanel.ack(msg);
    } catch (error) {
        console.error('❌ Error processing FCM token updated message:', error);
        chanel.nack(msg, false, false);
    }
}

export async function startFcmTokenConsumer() {
    try {
        const chanel = await getChannel();
        await chanel.assertQueue(FCM_TOKEN_UPDATED_QUEUE, { durable: true });
        console.log('FCM Token consumer started, waiting for messages...');

        chanel.consume(FCM_TOKEN_UPDATED_QUEUE, async (msg) => {
            await processFcmTokenUpdated(msg, chanel);
        }, { noAck: false });

    } catch (error) {
        console.error('Error starting FCM token consumer:', error);
        setTimeout(startFcmTokenConsumer, 10000);
    }
}
