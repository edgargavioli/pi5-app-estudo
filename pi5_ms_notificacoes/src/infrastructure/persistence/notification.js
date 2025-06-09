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

    /**
     * Busca notificação por entityId e entityType
     * Usado para encontrar notificações relacionadas a eventos específicos
     */
    async findByEntity(entityId, entityType, userId = null) {
        try {
            const whereCondition = {
                entityId: entityId,
                entityType: entityType
            };

            if (userId) {
                whereCondition.userId = userId;
            }

            const notifications = await this.prisma.notification.findMany({
                where: whereCondition,
                include: {
                    user: true
                }
            });

            return notifications.map(notification => Notification.fromJson(notification));
        } catch (error) {
            console.error('Error finding notifications by entity:', error);
            throw error;
        }
    }

    /**
     * Busca notificação por tipo e usuário
     * Usado para encontrar notificações específicas de streak, evento, etc.
     */
    async findByTypeAndUser(type, userId, status = null) {
        try {
            const whereCondition = {
                type: type,
                userId: userId
            };

            if (status) {
                whereCondition.status = status;
            }

            const notifications = await this.prisma.notification.findMany({
                where: whereCondition,
                include: {
                    user: true
                },
                orderBy: {
                    createdAt: 'desc'
                }
            });

            return notifications.map(notification => Notification.fromJson(notification));
        } catch (error) {
            console.error('Error finding notifications by type and user:', error);
            throw error;
        }
    }

    /**
     * Atualiza notificação baseada em evento de outro microsserviço
     */
    async updateByEntity(entityId, entityType, updateData, userId = null) {
        try {
            const whereCondition = {
                entityId: entityId,
                entityType: entityType
            };

            if (userId) {
                whereCondition.userId = userId;
            }

            const updatedNotifications = await this.prisma.notification.updateMany({
                where: whereCondition,
                data: {
                    ...updateData,
                    updatedAt: new Date()
                }
            });

            console.log(`Updated ${updatedNotifications.count} notifications for entity ${entityId}`);
            return updatedNotifications;
        } catch (error) {
            console.error('Error updating notifications by entity:', error);
            throw error;
        }
    }

    /**
     * Deleta notificações relacionadas a uma entidade específica
     * Usado quando um evento é cancelado/removido
     */
    async deleteByEntity(entityId, entityType, userId = null) {
        try {
            const whereCondition = {
                entityId: entityId,
                entityType: entityType
            };

            if (userId) {
                whereCondition.userId = userId;
            }

            const deletedNotifications = await this.prisma.notification.deleteMany({
                where: whereCondition
            });

            console.log(`Deleted ${deletedNotifications.count} notifications for entity ${entityId}`);
            return deletedNotifications;
        } catch (error) {
            console.error('Error deleting notifications by entity:', error);
            throw error;
        }
    }

    /**
     * Cancela notificações pendentes por entidade
     * Marca como CANCELLED em vez de deletar (para auditoria)
     */
    async cancelByEntity(entityId, entityType, reason = 'Event cancelled', userId = null) {
        try {
            const whereCondition = {
                entityId: entityId,
                entityType: entityType,
                status: 'PENDING'
            };

            if (userId) {
                whereCondition.userId = userId;
            }

            const cancelledNotifications = await this.prisma.notification.updateMany({
                where: whereCondition,
                data: {
                    status: 'CANCELLED',
                    entityData: {
                        ...whereCondition.entityData,
                        cancellationReason: reason,
                        cancelledAt: new Date().toISOString()
                    },
                    updatedAt: new Date()
                }
            });

            console.log(`Cancelled ${cancelledNotifications.count} notifications for entity ${entityId}`);
            return cancelledNotifications;
        } catch (error) {
            console.error('Error cancelling notifications by entity:', error);
            throw error;
        }
    }

    /**
     * Atualiza ou cria notificação baseada em streak
     * Usado quando streak é renovada ou quebrada
     */
    async upsertStreakNotification(userId, streakData, notificationType) {
        try {
            const existingNotification = await this.prisma.notification.findFirst({
                where: {
                    userId: userId,
                    type: notificationType,
                    entityId: streakData.streakId,
                    entityType: 'STREAK',
                    status: 'PENDING'
                }
            });

            if (existingNotification) {
                // Atualizar notificação existente
                const updated = await this.prisma.notification.update({
                    where: { id: existingNotification.id },
                    data: {
                        entityData: streakData,
                        scheduledFor: new Date(), // Enviar imediatamente
                        updatedAt: new Date()
                    }
                });
                return Notification.fromJson(updated);
            } else {
                // Criar nova notificação
                const created = await this.prisma.notification.create({
                    data: {
                        userId: userId,
                        type: notificationType,
                        entityId: streakData.streakId,
                        entityType: 'STREAK',
                        entityData: streakData,
                        scheduledFor: new Date(), // Enviar imediatamente
                        status: 'PENDING'
                    }
                });
                return Notification.fromJson(created);
            }
        } catch (error) {
            console.error('Error upserting streak notification:', error);
            throw error;
        }
    }

    /**
     * Reeschedula notificação para nova data
     * Usado quando evento é reagendado
     */
    async rescheduleByEntity(entityId, entityType, newScheduleTime, userId = null) {
        try {
            const whereCondition = {
                entityId: entityId,
                entityType: entityType,
                status: 'PENDING'
            };

            if (userId) {
                whereCondition.userId = userId;
            }

            const rescheduled = await this.prisma.notification.updateMany({
                where: whereCondition,
                data: {
                    scheduledFor: newScheduleTime,
                    updatedAt: new Date()
                }
            });

            console.log(`Rescheduled ${rescheduled.count} notifications for entity ${entityId}`);
            return rescheduled;
        } catch (error) {
            console.error('Error rescheduling notifications:', error);
            throw error;
        }
    }

    /**
     * Busca notificações em batch por múltiplas entidades
     * Otimização para quando processar vários eventos de uma vez
     */
    async findByEntities(entities, status = null) {
        try {
            const entityConditions = entities.map(entity => ({
                AND: [
                    { entityId: entity.entityId },
                    { entityType: entity.entityType },
                    ...(entity.userId ? [{ userId: entity.userId }] : [])
                ]
            }));

            const whereCondition = {
                OR: entityConditions
            };

            if (status) {
                whereCondition.status = status;
            }

            const notifications = await this.prisma.notification.findMany({
                where: whereCondition,
                include: {
                    user: true
                }
            });

            return notifications.map(notification => Notification.fromJson(notification));
        } catch (error) {
            console.error('Error finding notifications by entities:', error);
            throw error;
        }
    }

    /**
     * Estatísticas de notificações por entidade
     * Útil para debugging e monitoramento
     */
    async getEntityStats(entityId, entityType) {
        try {
            const stats = await this.prisma.notification.groupBy({
                by: ['status'],
                where: {
                    entityId: entityId,
                    entityType: entityType
                },
                _count: {
                    status: true
                }
            });

            return stats.reduce((acc, stat) => {
                acc[stat.status] = stat._count.status;
                return acc;
            }, {});
        } catch (error) {
            console.error('Error getting entity stats:', error);
            throw error;
        }
    }
}