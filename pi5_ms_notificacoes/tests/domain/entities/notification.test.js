import { describe, test, expect, beforeEach } from '@jest/globals';
import Notification from '../../../src/domain/entities/notification.js';

describe('Notification Entity', () => {
    let notification;
    let mockEntityData;

    beforeEach(() => {
        mockEntityData = {
            titulo: 'Prova de Matemática',
            name: 'Prova de Matemática',
            data: '2024-12-25T10:00:00Z',
            date: '2024-12-25T10:00:00Z',
            horario: '2024-12-25T10:00:00Z',
            time: '2024-12-25T10:00:00Z',
            conteudo: 'Álgebra Linear',
            topicos: ['Matrizes', 'Determinantes'],
            local: 'Sala 101'
        };

        notification = new Notification(
            'test-id',
            'user-123',
            'PROVA_CRIADA',
            'entity-456',
            'exam',
            mockEntityData,
            new Date('2024-12-20T10:00:00Z'),
            'PENDING'
        );
    });

    describe('Constructor', () => {
        test('should create notification with all properties', () => {
            expect(notification.id).toBe('test-id');
            expect(notification.userId).toBe('user-123');
            expect(notification.type).toBe('PROVA_CRIADA');
            expect(notification.entityId).toBe('entity-456');
            expect(notification.entityType).toBe('exam');
            expect(notification.entityData).toEqual(mockEntityData);
            expect(notification.scheduledFor).toEqual(new Date('2024-12-20T10:00:00Z'));
            expect(notification.status).toBe('PENDING');
        });

        test('should create notification with default status', () => {
            const notificationWithDefaultStatus = new Notification(
                'test-id',
                'user-123',
                'PROVA_CRIADA',
                'entity-456',
                'exam',
                mockEntityData,
                new Date('2024-12-20T10:00:00Z')
            );
            expect(notificationWithDefaultStatus.status).toBe('PENDING');
        });
    });

    describe('generateContent', () => {
        describe('Event Notifications', () => {
            test('should generate event created content', () => {
                notification.type = 'EVENTO_CRIADO';
                const content = notification.generateContent();
                
                expect(content.title).toBe('📅 Novo evento criado');
                expect(content.body).toContain('Prova de Matemática');
                expect(content.body).toContain('25/12/2024');
            });

            test('should generate event reminder content for 3 days', () => {
                notification.type = 'EVENTO_LEMBRETE_3_DIAS';
                const content = notification.generateContent();
                
                expect(content.title).toContain('⏰ Lembrete: Prova de Matemática em 3 dias');
                expect(content.body).toContain('3 dias');
            });

            test('should generate event today content', () => {
                notification.type = 'EVENTO_DIA';
                const content = notification.generateContent();
                
                expect(content.title).toContain('HOJE: Prova de Matemática');
                expect(content.body).toContain('hoje');
                expect(content.body).toContain('07:00');
            });

            test('should generate event today content without time', () => {
                notification.type = 'EVENTO_DIA';
                delete notification.entityData.horario;
                delete notification.entityData.time;
                const content = notification.generateContent();
                
                expect(content.title).toContain('🔥 HOJE: Prova de Matemática!');
                expect(content.body).toContain('hoje');
                expect(content.body).not.toContain('às');
            });
        });

        describe('Exam Notifications', () => {
            test('should generate exam created content', () => {
                notification.type = 'PROVA_CRIADA';
                const content = notification.generateContent();
                
                expect(content.title).toContain('Nova prova cadastrada');
                expect(content.body).toContain('Prova de Matemática');
                expect(content.body).toContain('25/12/2024');
            });

            test('should generate exam week reminder content', () => {
                notification.type = 'PROVA_LEMBRETE_1_SEMANA';
                const content = notification.generateContent();
                
                expect(content.title).toBe('📚 Prova se aproximando');
                expect(content.body).toContain('1 semana');
                expect(content.body).toContain('Prova de Matemática');
            });

            test('should generate exam 3 days reminder content', () => {
                notification.type = 'PROVA_LEMBRETE_3_DIAS';
                const content = notification.generateContent();
                
                expect(content.title).toContain('⏰ Prova em 3 dias - Revisão final!');
                expect(content.body).toContain('3 dias');
                expect(content.body).toContain('revisão geral');
            });

            test('should generate exam 1 day reminder content', () => {
                notification.type = 'PROVA_LEMBRETE_1_DIA';
                const content = notification.generateContent();
                
                expect(content.title).toContain('🔔 AMANHÃ é dia de prova!');
                expect(content.body).toContain('AMANHÃ');
                expect(content.body).toContain('Separe seus materiais');
            });

            test('should generate exam today content', () => {
                notification.type = 'PROVA_DIA';
                const content = notification.generateContent();
                
                expect(content.title).toContain('HOJE é dia de prova');
                expect(content.body).toContain('Hoje é o dia');
                expect(content.body).toContain('07:00');
                expect(content.body).toContain('Boa sorte');
            });

            test('should generate exam one hour content', () => {
                notification.type = 'PROVA_1_HORA';
                const content = notification.generateContent();
                
                expect(content.title).toContain('⏰ Prova em 1 hora!');
                expect(content.body).toContain('1 hora');
                expect(content.body).toContain('Sala 101');
                expect(content.body).toContain('Verifique seus materiais');
            });
        });

        describe('Session Notifications', () => {
            test('should generate session created content', () => {
                notification.type = 'SESSAO_CRIADA';
                const content = notification.generateContent();
                
                expect(content.title).toContain('Sessão de estudo criada');
                expect(content.body).toContain('Álgebra Linear');
            });

            test('should generate session started content', () => {
                notification.type = 'SESSAO_INICIADA';
                const content = notification.generateContent();
                
                expect(content.title).toBe('🎯 Sessão iniciada!');
                expect(content.body).toContain('Álgebra Linear');
                expect(content.body).toContain('começou');
            });

            test('should generate session reminder content', () => {
                notification.type = 'SESSAO_LEMBRETE';
                const content = notification.generateContent();
                
                expect(content.title).toBe('📚 Lembrete de sessão');
                expect(content.body).toContain('Álgebra Linear');
            });
        });

        describe('Streak Notifications', () => {
            test('should generate streak warning content', () => {
                notification.type = 'STREAK_WARNING';
                const content = notification.generateContent();
                
                expect(content.title).toContain('Sua sequência');
                expect(content.body).toContain('sequência');
            });

            test('should generate streak expired content', () => {
                notification.type = 'STREAK_EXPIRED';
                const content = notification.generateContent();
                
                expect(content.title).toContain('Sequência perdida');
                expect(content.body).toContain('foi perdida');
            });
        });

        describe('Legacy Types', () => {
            test('should generate legacy event reminder content', () => {
                notification.type = 'EVENT_REMINDER';
                const content = notification.generateContent();
                
                expect(content.title).toContain('Lembrete: Prova de Matemática');
                expect(content.body).toContain('evento acontecerá');
            });

            test('should generate legacy exam created content', () => {
                notification.type = 'EXAM_CREATED';
                const content = notification.generateContent();
                
                expect(content.title).toContain('Nova prova cadastrada');
                expect(content.body).toContain('Prova de Matemática');
            });
        });

        describe('Default Case', () => {
            test('should generate default content for unknown type', () => {
                notification.type = 'UNKNOWN_TYPE';
                const content = notification.generateContent();
                
                expect(content.title).toBe('Notificação');
                expect(content.body).toBe('Você tem uma nova notificação');
            });
        });

        describe('Edge Cases', () => {
            test('should handle missing entity data gracefully', () => {
                notification.entityData = {};
                notification.type = 'PROVA_CRIADA';
                const content = notification.generateContent();
                
                expect(content.title).toContain('Nova prova cadastrada');
                expect(content.body).toContain('Prova');
            });

            test('should handle null entity data gracefully', () => {
                notification.entityData = {};
                notification.type = 'EVENTO_CRIADO';
                const content = notification.generateContent();
                
                expect(content.title).toContain('Novo evento criado');
                expect(content.body).toContain('Evento');
            });
        });
    });

    describe('Helper Methods', () => {
        describe('getDaysDifference', () => {
            test('should calculate days difference correctly', () => {
                const targetDate = new Date();
                targetDate.setDate(targetDate.getDate() + 5);
                
                const days = notification.getDaysDifference(targetDate.toISOString());
                expect(days).toBe(5);
            });

            test('should handle past dates', () => {
                const pastDate = new Date();
                pastDate.setDate(pastDate.getDate() - 2);
                
                const days = notification.getDaysDifference(pastDate.toISOString());
                expect(days).toBe(-2);
            });
        });

        describe('getHoursUntilMidnight', () => {
            test('should calculate hours until midnight', () => {
                const hours = notification.getHoursUntilMidnight();
                expect(typeof hours).toBe('number');
                expect(hours).toBeGreaterThanOrEqual(0);
                expect(hours).toBeLessThan(24);
            });
        });
    });

    describe('Serialization', () => {
        describe('fromJson', () => {
            test('should create notification from JSON', () => {
                const json = {
                    id: 'json-id',
                    userId: 'json-user',
                    type: 'PROVA_CRIADA',
                    entityId: 'json-entity',
                    entityType: 'json-type',
                    entityData: { test: 'data' },
                    scheduledFor: '2024-12-20T10:00:00Z',
                    status: 'SENT'
                };

                const notificationFromJson = Notification.fromJson(json);
                
                expect(notificationFromJson.id).toBe('json-id');
                expect(notificationFromJson.userId).toBe('json-user');
                expect(notificationFromJson.type).toBe('PROVA_CRIADA');
                expect(notificationFromJson.entityId).toBe('json-entity');
                expect(notificationFromJson.entityType).toBe('json-type');
                expect(notificationFromJson.entityData).toEqual({ test: 'data' });
                expect(notificationFromJson.scheduledFor).toBe('2024-12-20T10:00:00Z');
                expect(notificationFromJson.status).toBe('SENT');
            });
        });

        describe('toJson', () => {
            test('should convert notification to JSON', () => {
                const json = notification.toJson();
                
                expect(json.id).toBe('test-id');
                expect(json.userId).toBe('user-123');
                expect(json.type).toBe('PROVA_CRIADA');
                expect(json.entityId).toBe('entity-456');
                expect(json.entityType).toBe('exam');
                expect(json.entityData).toEqual(mockEntityData);
                expect(json.scheduledFor).toEqual(new Date('2024-12-20T10:00:00Z'));
                expect(json.status).toBe('PENDING');
            });
        });

        test('should maintain data integrity through serialization cycle', () => {
            const json = notification.toJson();
            const recreatedNotification = Notification.fromJson(json);
            const recreatedJson = recreatedNotification.toJson();
            
            expect(recreatedJson).toEqual(json);
        });
    });
}); 