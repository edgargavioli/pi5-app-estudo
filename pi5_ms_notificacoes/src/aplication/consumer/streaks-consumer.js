import { getChannel } from "../../infrastructure/messaging/rabbitmq.js";
import NotificationPersistence from "../../infrastructure/persistence/notification.js";
import UserPersistence from "../../infrastructure/persistence/user.js";

const STREAK_QUEUE = process.env.STREAK_QUEUE || 'streak.created';
const notificationPersistence = new NotificationPersistence();
const userPersistence = new UserPersistence();

export default async function processStreakCreated(msg, chanel) {
    if (msg === null) {
        console.error('Received null message, skipping processing.');
        return;
    }

    const messageContent = msg.content.toString();
    let messageData;

    try {
        messageData = JSON.parse(messageContent);

        if (!messageData.userId || !messageData.streakData) {
            console.error('Message missing required data, skipping processing.');
            chanel.nack(msg, false, false);
            return;
        }

        await createStreakWarningNotification(messageData.userId, messageData.streakData);
        console.log(`Streak warning notification scheduled for user ${messageData.userId}`);

        chanel.ack(msg);
    } catch (error) {
        console.error('Error processing streak created message:', error);
        chanel.nack(msg, false, false);
    }
}

async function createStreakWarningNotification(userId, streakData) {
    // Agenda notificação para às 20h do mesmo dia
    const today = new Date();
    const warningTime = new Date(today);
    warningTime.setHours(20, 0, 0, 0);

    // Se já passou das 20h hoje, agenda para 20h de amanhã
    if (warningTime <= new Date()) {
        warningTime.setDate(today.getDate() + 1);
    }

    await notificationPersistence.create({
        userId,
        type: 'STREAK_WARNING',
        entityId: streakData.id,
        entityType: 'streak',
        entityData: streakData,
        scheduledFor: warningTime
    });
}

export async function startStreakConsumer() {
    try {
        const chanel = await getChannel();
        await chanel.assertQueue(STREAK_QUEUE, { durable: true });
        console.log('Streak consumer started, waiting for messages...');

        chanel.consume(STREAK_QUEUE, async (msg) => {
            await processStreakCreated(msg, chanel);
        }, { noAck: false });

    } catch (error) {
        console.error('Error starting streak consumer:', error);
        setTimeout(startStreakConsumer, 10000);
    }
}