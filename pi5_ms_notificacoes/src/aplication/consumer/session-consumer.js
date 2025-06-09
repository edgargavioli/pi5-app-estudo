import { getChannel } from "../../infrastructure/messaging/rabbitmq.js";
import NotificationPersistence from "../../infrastructure/persistence/notification.js";
import UserPersistence from "../../infrastructure/persistence/user.js";

const SESSION_CREATED_QUEUE = process.env.SESSAO_CRIADA_QUEUE || 'sessao.criada';
const SESSION_FINISHED_QUEUE = process.env.SESSAO_FINALIZADA_QUEUE || 'sessao.finalizada';
const notificationPersistence = new NotificationPersistence();
const userPersistence = new UserPersistence();

async function createSessionNotification(fcmToken, sessionData) {
    let user;
    try {
        user = await userPersistence.findByFcmToken(fcmToken);
    } catch (error) {
        console.error(`User with FCM token ${fcmToken} not found, skipping notification creation`);
        return;
    }

    const now = new Date();

    // Notificação imediata para sessão criada
    await notificationPersistence.create({
        userId: user.id,
        type: 'SESSION_CREATED',
        entityId: sessionData.id.toString(),
        entityType: 'session',
        entityData: sessionData,
        scheduledFor: now
    });
}

async function createSessionFinishedNotification(fcmToken, sessionData) {
    let user;
    try {
        user = await userPersistence.findByFcmToken(fcmToken);
    } catch (error) {
        console.error(`User with FCM token ${fcmToken} not found, skipping notification creation`);
        return;
    }

    const now = new Date();

    // Notificação imediata para sessão finalizada
    await notificationPersistence.create({
        userId: user.id,
        type: 'SESSION_FINISHED',
        entityId: sessionData.id.toString(),
        entityType: 'session',
        entityData: sessionData,
        scheduledFor: now
    });
}

export async function processSessionCreated(msg, chanel) {
    if (msg === null) {
        console.error('Received null message, skipping processing.');
        return;
    }

    const messageContent = msg.content.toString();
    let messageData;

    try {
        messageData = JSON.parse(messageContent);

        if (!messageData.fcmToken || !messageData.sessionData) {
            console.error('Message missing required data, skipping processing.');
            chanel.nack(msg, false, false);
            return;
        }

        await createSessionNotification(messageData.fcmToken, messageData.sessionData);
        console.log(`Session created notification scheduled for user with FCM token ${messageData.fcmToken}`);

        chanel.ack(msg);
    } catch (error) {
        console.error('Error processing session created message:', error);
        chanel.nack(msg, false, false);
    }
}

export async function processSessionFinished(msg, chanel) {
    if (msg === null) {
        console.error('Received null message, skipping processing.');
        return;
    }

    const messageContent = msg.content.toString();
    let messageData;

    try {
        messageData = JSON.parse(messageContent);

        if (!messageData.fcmToken || !messageData.sessionData) {
            console.error('Message missing required data, skipping processing.');
            chanel.nack(msg, false, false);
            return;
        }

        await createSessionFinishedNotification(messageData.fcmToken, messageData.sessionData);
        console.log(`Session finished notification scheduled for user with FCM token ${messageData.fcmToken}`);

        chanel.ack(msg);
    } catch (error) {
        console.error('Error processing session finished message:', error);
        chanel.nack(msg, false, false);
    }
}

export async function startSessionConsumer() {
    try {
        const chanel = await getChannel();

        // Consumer para sessões criadas
        await chanel.assertQueue(SESSION_CREATED_QUEUE, { durable: true });
        chanel.consume(SESSION_CREATED_QUEUE, async (msg) => {
            await processSessionCreated(msg, chanel);
        }, { noAck: false });

        // Consumer para sessões finalizadas
        await chanel.assertQueue(SESSION_FINISHED_QUEUE, { durable: true });
        chanel.consume(SESSION_FINISHED_QUEUE, async (msg) => {
            await processSessionFinished(msg, chanel);
        }, { noAck: false });

        console.log('Session consumers started, waiting for messages...');

    } catch (error) {
        console.error('Error starting session consumers:', error);
        setTimeout(startSessionConsumer, 10000);
    }
}
