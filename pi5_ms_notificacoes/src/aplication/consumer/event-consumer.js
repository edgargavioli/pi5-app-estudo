import { getChannel } from "../../infrastructure/messaging/rabbitmq.js";
import NotificationPersistence from "../../infrastructure/persistence/notification.js";
import UserPersistence from "../../infrastructure/persistence/user.js";

const EVENT_QUEUE = process.env.EVENT_QUEUE || 'event.created';
const notificationPersistence = new NotificationPersistence();
const userPersistence = new UserPersistence();

export default async function processEventCreated(msg, chanel) {
    if (msg === null) {
        console.error('Received null message, skipping processing.');
        return;
    }

    const messageContent = msg.content.toString();
    let messageData;

    try {
        messageData = JSON.parse(messageContent);

        if (!messageData.userId || !messageData.eventData) {
            console.error('Message missing required data, skipping processing.');
            chanel.nack(msg, false, false);
            return;
        }

        await createEventNotifications(messageData.userId, messageData.eventData);
        console.log(`Event notifications scheduled for user ${messageData.userId}`);

        chanel.ack(msg);
    } catch (error) {
        console.error('Error processing event created message:', error);
        chanel.nack(msg, false, false);
    }
}

async function createEventNotifications(userId, eventData) {
    const eventDate = new Date(eventData.date);
    const now = new Date();

    // Notificação 3 dias antes
    const threeDaysBefore = new Date(eventDate);
    threeDaysBefore.setDate(eventDate.getDate() - 3);
    
    if (threeDaysBefore > now) {
        await notificationPersistence.create({
            userId,
            type: 'EVENT_REMINDER',
            entityId: eventData.id,
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
            userId,
            type: 'EVENT_TODAY',
            entityId: eventData.id,
            entityType: 'event',
            entityData: eventData,
            scheduledFor: dayOfEvent
        });
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