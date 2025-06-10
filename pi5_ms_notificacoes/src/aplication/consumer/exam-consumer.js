import { getChannel } from "../../infrastructure/messaging/rabbitmq.js";
import NotificationPersistence from "../../infrastructure/persistence/notification.js";
import UserPersistence from "../../infrastructure/persistence/user.js";

const EXAM_QUEUE = process.env.EXAM_QUEUE || 'exam.created';
const EXAM_UPDATED_QUEUE = process.env.EXAM_UPDATED_QUEUE || 'exam.updated';
const EXAM_DELETED_QUEUE = process.env.EXAM_DELETED_QUEUE || 'exam.deleted';
const notificationPersistence = new NotificationPersistence();
const userPersistence = new UserPersistence();

async function createExamNotifications(userId, examData) {
    // Usar diretamente o userId do evento
    console.log(`Creating exam notifications for user: ${userId}`);

    let user;
    try {
        user = await userPersistence.findById(userId);
        if (!user) {
            console.error(`User ${userId} not found, skipping notification creation`);
            return;
        }
    } catch (error) {
        console.error(`Error finding user ${userId}, skipping notification creation:`, error);
        return;
    }

    const examDate = new Date(examData.data || examData.date);
    const now = new Date();

    console.log(`📅 Exam date: ${examDate}, Now: ${now}`);

    // Notificação 1 semana antes
    const oneWeekBefore = new Date(examDate);
    oneWeekBefore.setDate(examDate.getDate() - 7);

    if (oneWeekBefore > now) {
        await notificationPersistence.create({
            userId: user.id,
            type: 'EXAM_WEEK_REMINDER',
            entityId: examData.id?.toString() || examData.examId?.toString(),
            entityType: 'exam',
            entityData: examData,
            scheduledFor: oneWeekBefore
        });
        console.log(`📅 Scheduled week reminder for ${oneWeekBefore}`);
    }

    // Notificação 3 dias antes
    const threeDaysBefore = new Date(examDate);
    threeDaysBefore.setDate(examDate.getDate() - 3);

    if (threeDaysBefore > now) {
        await notificationPersistence.create({
            userId: user.id,
            type: 'EXAM_REMINDER',
            entityId: examData.id?.toString() || examData.examId?.toString(),
            entityType: 'exam',
            entityData: examData,
            scheduledFor: threeDaysBefore
        });
        console.log(`📅 Scheduled 3-day reminder for ${threeDaysBefore}`);
    }

    // Notificação no dia da prova
    const dayOfExam = new Date(examDate);
    dayOfExam.setHours(7, 0, 0, 0);

    if (dayOfExam > now) {
        await notificationPersistence.create({
            userId: user.id,
            type: 'EXAM_TODAY',
            entityId: examData.id?.toString() || examData.examId?.toString(),
            entityType: 'exam',
            entityData: examData,
            scheduledFor: dayOfExam
        });
        console.log(`📅 Scheduled day-of reminder for ${dayOfExam}`);
    }

    // Notificação imediata (criada agora)
    await notificationPersistence.create({
        userId: user.id,
        type: 'EXAM_CREATED',
        entityId: examData.id?.toString() || examData.examId?.toString(),
        entityType: 'exam',
        entityData: examData,
        scheduledFor: now
    });
    console.log(`📅 Scheduled immediate notification`);
}

async function updateExamNotifications(fcmToken, examData) {
    let user;
    try {
        user = await userPersistence.findByFcmToken(fcmToken);
    } catch (error) {
        console.error(`User with FCM token ${fcmToken} not found, skipping notification update`);
        return;
    }

    // Remover notificações pendentes antigas da prova
    await notificationPersistence.deleteByEntityId(examData.id.toString());

    // Criar novas notificações com os dados atualizados
    await createExamNotifications(fcmToken, examData);
}

async function deleteExamNotifications(examId) {
    try {
        // Remover todas as notificações relacionadas à prova
        await notificationPersistence.deleteByEntityId(examId.toString());
        console.log(`Notifications deleted for exam ${examId}`);
    } catch (error) {
        console.error(`Error deleting notifications for exam ${examId}:`, error);
    }
}

export async function processExamCreated(msg, chanel) {
    if (msg === null) {
        console.error('Received null message, skipping processing.');
        return;
    }

    const messageContent = msg.content.toString();
    console.log('📥 Raw exam message received:', messageContent);

    let messageData;

    try {
        messageData = JSON.parse(messageContent);
        console.log('📥 Parsed exam message:', JSON.stringify(messageData, null, 2));

        // Extrair dados do evento (pode estar em data.data ou diretamente em data)
        const eventData = messageData.data || messageData;

        if (!eventData.userId || !eventData.examData) {
            console.error('Message missing required data, skipping processing.', eventData);
            chanel.nack(msg, false, false);
            return;
        }

        await createExamNotifications(eventData.userId, eventData.examData);
        console.log(`✅ Exam notifications scheduled for user ${eventData.userId}`);

        chanel.ack(msg);
    } catch (error) {
        console.error('❌ Error processing exam created message:', error);
        chanel.nack(msg, false, false);
    }
}

export async function processExamUpdated(msg, chanel) {
    if (msg === null) {
        console.error('Received null message, skipping processing.');
        return;
    }

    const messageContent = msg.content.toString();
    let messageData;

    try {
        messageData = JSON.parse(messageContent);

        if (!messageData.fcmToken || !messageData.examData) {
            console.error('Message missing required data, skipping processing.');
            chanel.nack(msg, false, false);
            return;
        }

        await updateExamNotifications(messageData.fcmToken, messageData.examData);
        console.log(`Exam notifications updated for user with FCM token ${messageData.fcmToken}`);

        chanel.ack(msg);
    } catch (error) {
        console.error('Error processing exam updated message:', error);
        chanel.nack(msg, false, false);
    }
}

export async function processExamDeleted(msg, chanel) {
    if (msg === null) {
        console.error('Received null message, skipping processing.');
        return;
    }

    const messageContent = msg.content.toString();
    let messageData;

    try {
        messageData = JSON.parse(messageContent);

        if (!messageData.examId) {
            console.error('Message missing examId, skipping processing.');
            chanel.nack(msg, false, false);
            return;
        }

        await deleteExamNotifications(messageData.examId);
        console.log(`Exam notifications deleted for exam ${messageData.examId}`);

        chanel.ack(msg);
    } catch (error) {
        console.error('Error processing exam deleted message:', error);
        chanel.nack(msg, false, false);
    }
}

export async function startExamConsumer() {
    try {
        const chanel = await getChannel();

        // Consumer para provas criadas
        await chanel.assertQueue(EXAM_QUEUE, { durable: true });
        chanel.consume(EXAM_QUEUE, async (msg) => {
            await processExamCreated(msg, chanel);
        }, { noAck: false });

        // Consumer para provas editadas
        await chanel.assertQueue(EXAM_UPDATED_QUEUE, { durable: true });
        chanel.consume(EXAM_UPDATED_QUEUE, async (msg) => {
            await processExamUpdated(msg, chanel);
        }, { noAck: false });

        // Consumer para provas excluídas
        await chanel.assertQueue(EXAM_DELETED_QUEUE, { durable: true });
        chanel.consume(EXAM_DELETED_QUEUE, async (msg) => {
            await processExamDeleted(msg, chanel);
        }, { noAck: false });

        console.log('Exam consumers started, waiting for messages...');

    } catch (error) {
        console.error('Error starting exam consumers:', error);
        setTimeout(startExamConsumer, 10000);
    }
}
