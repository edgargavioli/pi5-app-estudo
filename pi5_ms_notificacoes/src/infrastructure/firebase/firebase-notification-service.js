import initializeFirebaseAdmin from "./firebase-admin.js";

export default class FirebaseNotificationService {
    constructor() {
        this.admin = initializeFirebaseAdmin();
    }

    async sendNotification(user, notification, data = {}) {
        if (!this.admin) {
            throw new Error("Firebase Admin SDK is not initialized.");
        }

        if (!user || !user.fcmToken || !notification) {
            throw new Error("User or FCM token or notification is not provided.");
        }

        const message = {
            notification: {
                title: notification.title,
                body: notification.content,
            },
            data: data,
        }

        try {
            const response = await this.admin.messaging().send({
                token: user.fcmToken,
                ...message,
            });

            console.log('Notification sent successfully:', response);

            if (response.faliureCount > 0) {
                response.results.forEach((result, index) => {
                    if (result.error) {
                        console.error(`Error sending notification to user ${user.id}:`, result.error);
                    } else {
                        console.log(`Notification sent to user ${user.id} successfully.`);
                    }
                });
            }

            return response;
        } catch (error) {
            console.error('Error sending notification:', error);
            throw error;
        }
    }
}