import { getChannel } from "../../infrastructure/messaging/rabbitmq.js";
import NotificationPersistence from "../../infrastructure/persistence/notification.js";
import UserPersistence from "../../infrastructure/persistence/user.js";

const EVENT_QUEUE = process.env.EVENT_QUEUE || 'event.created';
const EVENT_UPDATED_QUEUE = process.env.EVENT_UPDATED_QUEUE || 'event.updated';
const EVENT_DELETED_QUEUE = process.env.EVENT_DELETED_QUEUE || 'event.deleted';
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

async function updateEventNotifications(fcmToken, eventData) {
    // Verificar se o usuário existe usando o fcmToken
    let user;
    try {
        user = await userPersistence.findByFcmToken(fcmToken);
    } catch (error) {
        console.error(`User with FCM token ${fcmToken} not found, skipping notification update`);
        return;
    }

    // Remover notificações pendentes antigas do evento
    await notificationPersistence.deleteByEntityId(eventData.id.toString());

    // Criar novas notificações com os dados atualizados
    await createEventNotifications(fcmToken, eventData);
}

async function deleteEventNotifications(eventId) {
    try {
        // Remover todas as notificações relacionadas ao evento
        await notificationPersistence.deleteByEntityId(eventId.toString());
        console.log(`Notifications deleted for event ${eventId}`);
    } catch (error) {
        console.error(`Error deleting notifications for event ${eventId}:`, error);
    }
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

export async function processEventUpdated(msg, chanel) {
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

        await updateEventNotifications(messageData.fcmToken, messageData.eventData);
        console.log(`Event notifications updated for user with FCM token ${messageData.fcmToken}`);

        chanel.ack(msg);
    } catch (error) {
        console.error('Error processing event updated message:', error);
        chanel.nack(msg, false, false);
    }
}

export async function processEventDeleted(msg, chanel) {
    if (msg === null) {
        console.error('Received null message, skipping processing.');
        return;
    }

    const messageContent = msg.content.toString();
    let messageData;

    try {
        messageData = JSON.parse(messageContent);

        if (!messageData.eventId) {
            console.error('Message missing eventId, skipping processing.');
            chanel.nack(msg, false, false);
            return;
        }

        await deleteEventNotifications(messageData.eventId);
        console.log(`Event notifications deleted for event ${messageData.eventId}`);

        chanel.ack(msg);
    } catch (error) {
        console.error('Error processing event deleted message:', error);
        chanel.nack(msg, false, false);
    }
}

export async function startEventConsumer() {
    try {
        const chanel = await getChannel();

        // Consumer para eventos criados
        await chanel.assertQueue(EVENT_QUEUE, { durable: true });
        chanel.consume(EVENT_QUEUE, async (msg) => {
            await processEventCreated(msg, chanel);
        }, { noAck: false });

        // Consumer para eventos editados
        await chanel.assertQueue(EVENT_UPDATED_QUEUE, { durable: true });
        chanel.consume(EVENT_UPDATED_QUEUE, async (msg) => {
            await processEventUpdated(msg, chanel);
        }, { noAck: false });

        // Consumer para eventos excluídos
        await chanel.assertQueue(EVENT_DELETED_QUEUE, { durable: true });
        chanel.consume(EVENT_DELETED_QUEUE, async (msg) => {
            await processEventDeleted(msg, chanel);
        }, { noAck: false });

        console.log('Event consumers started, waiting for messages...');

    } catch (error) {
        console.error('Error starting event consumers:', error);
        setTimeout(startEventConsumer, 10000);
    }
}