import { startUserConsumer } from './user-consumer.js';
import { startEventConsumer } from './event-consumer.js';
import { startStreakConsumer } from './streaks-consumer.js';
import NotificationScheduler from '../../infrastructure/services/notification-scheduler.js';
import { startSessionConsumer } from './session-consumer.js';
import { startExamConsumer } from './exam-consumer.js';

export async function startAllConsumers() {
    try {
        console.log('Starting all consumers...');

        // Inicia todos os consumers
        await startUserConsumer();
        await startEventConsumer();
        await startStreakConsumer();
        await startSessionConsumer();
        await startExamConsumer();

        // Inicia o scheduler de notificações
        const scheduler = new NotificationScheduler();
        scheduler.startScheduler();

        console.log('All consumers and scheduler started successfully!');
    } catch (error) {
        console.error('Error starting consumers:', error);
        setTimeout(startAllConsumers, 10000);
    }
}