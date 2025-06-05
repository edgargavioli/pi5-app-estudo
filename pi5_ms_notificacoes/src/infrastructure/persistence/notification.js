import prisma from "./prisma/prismaClient.js";
import Notification from "../../domain/entities/notification.js";

export default class NotificationPersistence {
    constructor() {
        this.prisma = prisma;
    }

    async create(notificationData) {
        try {
            const createdNotification = await this.prisma.notification.create({
                data: {
                    userId: notificationData.userId,
                    type: notificationData.type,
                    entityId: notificationData.entityId,
                    entityType: notificationData.entityType,
                    entityData: notificationData.entityData,
                    scheduledFor: notificationData.scheduledFor,
                    status: notificationData.status || 'PENDING'
                }
            });

            return Notification.fromJson(createdNotification);
        } catch (error) {
            console.error('Error creating notification:', error);
            throw error;
        }
    }

    async findPendingNotifications(currentTime) {
        try {
            const notifications = await this.prisma.notification.findMany({
                where: {
                    status: 'PENDING',
                    scheduledFor: {
                        lte: currentTime
                    }
                },
                include: {
                    user: true
                }
            });

            return notifications.map(notification => Notification.fromJson(notification));
        } catch (error) {
            console.error('Error finding pending notifications:', error);
            throw error;
        }
    }

    async updateStatus(id, status) {
        try {
            return await this.prisma.notification.update({
                where: { id },
                data: { status, updatedAt: new Date() }
            });
        } catch (error) {
            console.error('Error updating notification status:', error);
            throw error;
        }
    }

    // Método para limpar notificações antigas
    async cleanupOldNotifications(daysOld = 30) {
        try {
            const cutoffDate = new Date();
            cutoffDate.setDate(cutoffDate.getDate() - daysOld);

            return await this.prisma.notification.deleteMany({
                where: {
                    createdAt: {
                        lt: cutoffDate
                    },
                    status: {
                        in: ['SENT', 'FAILED']
                    }
                }
            });
        } catch (error) {
            console.error('Error cleaning up old notifications:', error);
            throw error;
        }
    }
}