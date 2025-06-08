import { getChannel } from "../../infrastructure/messaging/rabbitmq.js";
import NotificationPersistence from "../../infrastructure/persistence/notification.js";
import UserPersistence from "../../infrastructure/persistence/user.js";

const EVENT_QUEUE = process.env.EVENT_QUEUE || 'event.created';
const notificationPersistence = new NotificationPersistence();
const userPersistence = new UserPersistence();

async function createEventNotifications(fcmToken, eventData) {
    // Verificar se o usuário existe usando o fcmToken
    let user;
    try {
        user = await userPersistence.findByFcmToken(fcmToken);
    } catch (error) {
        console.error(`User with FCM token ${fcmToken} not found, skipping notification creation`);
        return;
    }

    const eventDate = new Date(eventData.date);
    const now = new Date();

    // Notificação 3 dias antes
    const threeDaysBefore = new Date(eventDate);
    threeDaysBefore.setDate(eventDate.getDate() - 3);

    console.log(
        user.id,
    )

    if (threeDaysBefore > now) {
        await notificationPersistence.create({
            userId: user.id, // ✅ Usar o ID do usuário encontrado
            type: 'EVENT_REMINDER',
            entityId: eventData.id.toString(),
            entityType: 'event',
            entityData: eventData,
            scheduledFor: threeDaysBefore
        });
    }

    // Notificação no dia do evento
    const dayOfEvent = new Date(eventDate);
    dayOfEvent.setHours(8, 0, 0, 0);

    if (dayOfEvent > now) {
        await notificationPersistence.create({
            userId: user.id, // ✅ Usar o ID do usuário encontrado
            type: 'EVENT_TODAY',
            entityId: eventData.id.toString(),
            entityType: 'event',
            entityData: eventData,
            scheduledFor: dayOfEvent
        });
    }

    // Notificação imediata (criada agora)
    await notificationPersistence.create({
        userId: user.id,
        type: 'EVENT_CREATED',
        entityId: eventData.id.toString(),
        entityType: 'event',
        entityData: eventData,
        scheduledFor: now
    });
}

export default async function processEventCreated(msg, chanel) {
    if (msg === null) {
        console.error('Received null message, skipping processing.');
        return;
    }

    const messageContent = msg.content.toString();
    let messageData;

    try {
        messageData = JSON.parse(messageContent);

        if (!messageData.fcmToken || !messageData.eventData) {
            console.error('Message missing required data, skipping processing.');
            chanel.nack(msg, false, false);
            return;
        }

        await createEventNotifications(messageData.fcmToken, messageData.eventData);
        console.log(`Event notifications scheduled for user with FCM token ${messageData.fcmToken}`);

        chanel.ack(msg);
    } catch (error) {
        console.error('Error processing event created message:', error);
        chanel.nack(msg, false, false);
    }
}

export async function startEventConsumer() {
    try {
        const chanel = await getChannel();
        await chanel.assertQueue(EVENT_QUEUE, { durable: true });
        console.log('Event consumer started, waiting for messages...');

        chanel.consume(EVENT_QUEUE, async (msg) => {
            await processEventCreated(msg, chanel);
        }, { noAck: false });

    } catch (error) {
        console.error('Error starting event consumer:', error);
        setTimeout(startEventConsumer, 10000);
    }
}