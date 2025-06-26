import { describe, test, expect, beforeEach, jest } from '@jest/globals';

// Mock do Prisma Client
const mockFindMany = jest.fn();
const mockFindUnique = jest.fn();
const mockCreate = jest.fn();
const mockUpdate = jest.fn();
const mockDelete = jest.fn();

const mockPrismaClient = {
    notification: {
        findMany: mockFindMany,
        findUnique: mockFindUnique,
        create: mockCreate,
        update: mockUpdate,
        delete: mockDelete
    },
    $connect: jest.fn().mockResolvedValue(undefined),
    $disconnect: jest.fn().mockResolvedValue(undefined)
};

jest.unstable_mockModule('../../../src/infrastructure/persistence/prisma/client/index.js', () => ({
    PrismaClient: jest.fn(() => mockPrismaClient)
}));

// Mock da entidade Notification
const mockFromJson = jest.fn();
const mockToJson = jest.fn();

jest.unstable_mockModule('../../../src/domain/entities/notification.js', () => ({
    default: {
        fromJson: mockFromJson
    }
}));

const { default: NotificationPersistence } = await import('../../../src/infrastructure/persistence/notification.js');

describe('NotificationPersistence', () => {
    let persistence;
    let mockNotificationEntity;
    let mockNotificationData;

    beforeEach(() => {
        jest.clearAllMocks();
        persistence = new NotificationPersistence();

        mockNotificationData = {
            id: 'notification-123',
            userId: 'user-456',
            type: 'PROVA_CRIADA',
            entityId: 'entity-789',
            entityType: 'exam',
            entityData: { titulo: 'Prova de Matemática' },
            scheduledFor: new Date('2024-12-25T10:00:00Z'),
            status: 'PENDING',
            createdAt: new Date('2024-12-20T08:00:00Z'),
            updatedAt: new Date('2024-12-20T08:00:00Z')
        };

        mockNotificationEntity = {
            id: 'notification-123',
            userId: 'user-456',
            type: 'PROVA_CRIADA',
            toJson: mockToJson
        };

        mockToJson.mockReturnValue(mockNotificationData);
        mockFromJson.mockReturnValue(mockNotificationEntity);
    });

    describe('Constructor', () => {
        test('should initialize with Prisma client', () => {
            expect(persistence.prisma).toBeDefined();
        });
    });

    describe('findPendingNotifications', () => {
        test('should find pending notifications before specified date', async () => {
            const targetDate = new Date('2024-12-25T10:00:00Z');
            const mockDbResults = [mockNotificationData];
            
            mockFindMany.mockResolvedValue(mockDbResults);

            const result = await persistence.findPendingNotifications(targetDate);

            expect(mockFindMany).toHaveBeenCalledWith({
                where: {
                    status: 'PENDING',
                    scheduledFor: {
                        lte: targetDate
                    }
                },
                include: {
                    user: true
                }
            });
            expect(result).toHaveLength(1);
        });

        test('should handle database error', async () => {
            const targetDate = new Date();
            mockFindMany.mockRejectedValue(new Error('Database error'));

            await expect(persistence.findPendingNotifications(targetDate))
                .rejects.toThrow('Database error');
        });
    });

    describe('updateStatus', () => {
        test('should update notification status successfully', async () => {
            const notificationId = 'notification-123';
            const newStatus = 'SENT';
            const updatedNotification = { ...mockNotificationData, status: 'SENT' };
            
            mockUpdate.mockResolvedValue(updatedNotification);

            const result = await persistence.updateStatus(notificationId, newStatus);

            expect(mockUpdate).toHaveBeenCalledWith({
                where: { id: notificationId },
                data: { 
                    status: newStatus,
                    updatedAt: expect.any(Date)
                }
            });
        });

        test('should handle update error', async () => {
            mockUpdate.mockRejectedValue(new Error('Update failed'));

            await expect(persistence.updateStatus('test-id', 'SENT'))
                .rejects.toThrow('Update failed');
        });
    });

    describe('create', () => {
        test('should create new notification', async () => {
            const createdNotification = { ...mockNotificationData, id: 'new-notification-id' };
            mockCreate.mockResolvedValue(createdNotification);

            const result = await persistence.create(mockNotificationEntity);

            expect(mockCreate).toHaveBeenCalled();
        });

        test('should handle create error', async () => {
            mockCreate.mockRejectedValue(new Error('Create failed'));

            await expect(persistence.create(mockNotificationEntity))
                .rejects.toThrow('Create failed');
        });
    });

    // findById method tests removed as method doesn't exist in current implementation
}); 