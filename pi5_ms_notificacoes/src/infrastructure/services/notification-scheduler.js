import NotificationPersistence from "../persistence/notification.js";
import UserPersistence from "../persistence/user.js";
import FirebaseNotificationService from "../firebase/firebase-notification-service.js";

export default class NotificationScheduler {
    constructor() {
        this.notificationPersistence = new NotificationPersistence();
        this.userPersistence = new UserPersistence();
        this.firebaseService = new FirebaseNotificationService();
    }

    async processPendingNotifications() {
        try {
            const now = new Date();
            const pendingNotifications = await this.notificationPersistence.findPendingNotifications(now);

            console.log(`🔔 Processing ${pendingNotifications.length} pending notifications...`);

            for (const notification of pendingNotifications) {
                await this.sendNotification(notification);
            }
        } catch (error) {
            console.error('Error processing pending notifications:', error);
        }
    } async sendNotification(notification) {
        console.log(
            notification
        )
        try {
            const user = await this.userPersistence.findById(notification.userId);
            if (!user) {
                console.error(`User ${notification.userId} not found`);
                await this.notificationPersistence.updateStatus(notification.id, 'FAILED');
                return;
            }            // Priorizar mensagens personalizadas do consumer, senão usar generateContent()
            let content;
            if (notification.entityData.notificationTitle && notification.entityData.notificationBody) {
                content = {
                    title: notification.entityData.notificationTitle,
                    body: notification.entityData.notificationBody
                };
            } else {
                content = notification.generateContent();
            }

            // Simula o envio (você pode comentar esta linha se quiser testar o Firebase real)
            console.log(`📱 Sending notification to user ${user.fcmToken}:`, content);

            // Descomente para enviar via Firebase real:
            await this.firebaseService.sendNotification(user, content);

            // Marca como enviada
            await this.notificationPersistence.updateStatus(notification.id, 'SENT');

            console.log(`✅ Notification sent successfully: ${content.title}`);
        } catch (error) {
            console.error('Error sending notification:', error);
            await this.notificationPersistence.updateStatus(notification.id, 'FAILED');
        }
    }

    // Método para executar periodicamente (cron job)
    startScheduler() {
        console.log('🕐 Starting notification scheduler...');
        setInterval(() => {
            this.processPendingNotifications();
        }, 10000); // Verifica a cada minuto
    }
}