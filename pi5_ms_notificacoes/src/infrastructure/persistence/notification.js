import prisma from "./prisma/prismaClient.js";
import Notification from "../../domain/entities/notification.js";

export default class NotificationPersistence {
    constructor() {
        this.prisma = prisma();
    }

    async create(notificationData) {
        try {
            const notification = new Notification(notificationData);

            const createdNotification = await this.prisma.notification.create({
                data: notification,
            });

            return createdNotification;
        } catch (error) {
            console.error('Error creating notification:', error);
            throw error;
        }
    }

    async getAll() {
        try {
            const notifications = await this.prisma.notification.findMany();
            return notifications.map(notification => new Notification(notification));
        } catch (error) {
            console.error('Error fetching all notifications:', error);
            throw error;
        }
    }

    async findById(id) {
        try {
            const notification = await this.prisma.notification.findUnique({
                where: { id },
            });

            if (!notification) {
                throw new Error(`Notification with id ${id} not found.`);
            }

            return new Notification(notification);
        } catch (error) {
            console.error('Error finding notification by id:', error);
            throw error;
        }
    }

    async delete(id) {
        try {
            const deletedNotification = await this.prisma.notification.delete({
                where: { id },
            });

            return deletedNotification;
        } catch (error) {
            console.error('Error deleting notification:', error);
            throw error;
        }
    }
}