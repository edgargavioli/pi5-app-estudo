import { jest } from '@jest/globals';
import Notification from '../../../../src/domain/entities/notification.js';

describe('Notification Entity', () => {
    let mockNotification;

    beforeEach(() => {
        mockNotification = new Notification(
            'test-id',
            'user-123',
            'EVENT_REMINDER',
            'event-456',
            'event',
            {
                name: 'Reunião de Estudo',
                date: '2024-12-25T10:00:00Z',
                time: '10:00'
            },
            '2024-12-24T10:00:00Z',
            'PENDING'
        );
    });

    describe('Constructor', () => {
        test('deve criar uma notificação com todos os parâmetros', () => {
            const notification = new Notification(
                'id-1',
                'user-1',
                'EXAM_REMINDER',
                'exam-1',
                'exam',
                { name: 'Prova de Matemática' },
                '2024-12-25T10:00:00Z',
                'SENT'
            );

            expect(notification.id).toBe('id-1');
            expect(notification.userId).toBe('user-1');
            expect(notification.type).toBe('EXAM_REMINDER');
            expect(notification.entityId).toBe('exam-1');
            expect(notification.entityType).toBe('exam');
            expect(notification.entityData).toEqual({ name: 'Prova de Matemática' });
            expect(notification.scheduledFor).toBe('2024-12-25T10:00:00Z');
            expect(notification.status).toBe('SENT');
        });

        test('deve usar status PENDING como padrão', () => {
            const notification = new Notification(
                'id-1',
                'user-1',
                'EVENT_REMINDER',
                'event-1',
                'event',
                { name: 'Evento' },
                '2024-12-25T10:00:00Z'
            );

            expect(notification.status).toBe('PENDING');
        });
    });

    describe('generateContent', () => {
        test('deve gerar conteúdo para EVENT_REMINDER', () => {
            const notification = new Notification(
                'id-1',
                'user-1',
                'EVENT_REMINDER',
                'event-1',
                'event',
                {
                    name: 'Reunião de Estudo',
                    date: '2024-12-25T10:00:00Z'
                },
                '2024-12-24T10:00:00Z'
            );

            const content = notification.generateContent();
            expect(content.title).toBe('Lembrete: Reunião de Estudo');
            expect(content.body).toContain('O evento acontecerá em');
        });

        test('deve gerar conteúdo para EVENT_TODAY', () => {
            const notification = new Notification(
                'id-1',
                'user-1',
                'EVENT_TODAY',
                'event-1',
                'event',
                {
                    name: 'Reunião de Estudo',
                    time: '10:00'
                },
                '2024-12-25T10:00:00Z'
            );

            const content = notification.generateContent();
            expect(content.title).toBe('Hoje é o dia!');
            expect(content.body).toContain('Reunião de Estudo');
            expect(content.body).toContain('10:00');
        });

        test('deve gerar conteúdo para EVENT_CREATED', () => {
            const notification = new Notification(
                'id-1',
                'user-1',
                'EVENT_CREATED',
                'event-1',
                'event',
                {
                    name: 'Reunião de Estudo',
                    date: '2024-12-25T10:00:00Z'
                },
                '2024-12-24T10:00:00Z'
            );

            const content = notification.generateContent();
            expect(content.title).toBe('📅 Novo evento criado');
            expect(content.body).toContain('Reunião de Estudo');
        });

        test('deve gerar conteúdo para EXAM_WEEK_REMINDER', () => {
            const notification = new Notification(
                'id-1',
                'user-1',
                'EXAM_WEEK_REMINDER',
                'exam-1',
                'exam',
                {
                    name: 'Prova de Matemática',
                    date: '2024-12-25T10:00:00Z'
                },
                '2024-12-24T10:00:00Z'
            );

            const content = notification.generateContent();
            expect(content.title).toBe('📚 Prova se aproximando');
            expect(content.body).toContain('Prova de Matemática');
        });

        test('deve gerar conteúdo para EXAM_REMINDER', () => {
            const notification = new Notification(
                'id-1',
                'user-1',
                'EXAM_REMINDER',
                'exam-1',
                'exam',
                {
                    name: 'Prova de Matemática',
                    date: '2024-12-25T10:00:00Z',
                    time: '10:00'
                },
                '2024-12-24T10:00:00Z'
            );

            const content = notification.generateContent();
            expect(content.title).toContain('⏰ Lembrete: Prova em');
            expect(content.body).toContain('Prova de Matemática');
        });

        test('deve gerar conteúdo para EXAM_TODAY', () => {
            const notification = new Notification(
                'id-1',
                'user-1',
                'EXAM_TODAY',
                'exam-1',
                'exam',
                {
                    name: 'Prova de Matemática',
                    time: '10:00'
                },
                '2024-12-25T10:00:00Z'
            );

            const content = notification.generateContent();
            expect(content.title).toBe('🎯 Prova hoje!');
            expect(content.body).toContain('Prova de Matemática');
            expect(content.body).toContain('10:00');
        });

        test('deve gerar conteúdo para EXAM_CREATED', () => {
            const notification = new Notification(
                'id-1',
                'user-1',
                'EXAM_CREATED',
                'exam-1',
                'exam',
                {
                    name: 'Prova de Matemática',
                    date: '2024-12-25T10:00:00Z'
                },
                '2024-12-24T10:00:00Z'
            );

            const content = notification.generateContent();
            expect(content.title).toBe('📋 Nova prova cadastrada');
            expect(content.body).toContain('Prova de Matemática');
        });

        test('deve gerar conteúdo para SESSION_CREATED', () => {
            const notification = new Notification(
                'id-1',
                'user-1',
                'SESSION_CREATED',
                'session-1',
                'session',
                {
                    name: 'Sessão de Matemática'
                },
                '2024-12-25T10:00:00Z'
            );

            const content = notification.generateContent();
            expect(content.title).toBe('🎯 Sessão de estudo iniciada');
            expect(content.body).toContain('Sessão de Matemática');
        });

        test('deve gerar conteúdo para SESSION_FINISHED com score', () => {
            const notification = new Notification(
                'id-1',
                'user-1',
                'SESSION_FINISHED',
                'session-1',
                'session',
                {
                    name: 'Sessão de Matemática',
                    score: 85
                },
                '2024-12-25T10:00:00Z'
            );

            const content = notification.generateContent();
            expect(content.title).toBe('✅ Sessão concluída');
            expect(content.body).toContain('Sessão de Matemática');
            expect(content.body).toContain('85%');
        });

        test('deve gerar conteúdo para SESSION_FINISHED sem score', () => {
            const notification = new Notification(
                'id-1',
                'user-1',
                'SESSION_FINISHED',
                'session-1',
                'session',
                {
                    name: 'Sessão de Matemática'
                },
                '2024-12-25T10:00:00Z'
            );

            const content = notification.generateContent();
            expect(content.title).toBe('✅ Sessão concluída');
            expect(content.body).toContain('Sessão de Matemática');
            expect(content.body).not.toContain('Pontuação');
        });

        test('deve gerar conteúdo para STREAK_WARNING', () => {
            const notification = new Notification(
                'id-1',
                'user-1',
                'STREAK_WARNING',
                'streak-1',
                'streak',
                {
                    name: 'Estudo Diário',
                    currentCount: 7
                },
                '2024-12-25T10:00:00Z'
            );

            const content = notification.generateContent();
            expect(content.title).toBe('⚠️ Sua sequência Estudo Diário expira hoje!');
            expect(content.body).toContain('7 dias');
        });

        test('deve gerar conteúdo para STREAK_EXPIRED', () => {
            const notification = new Notification(
                'id-1',
                'user-1',
                'STREAK_EXPIRED',
                'streak-1',
                'streak',
                {
                    name: 'Estudo Diário',
                    previousCount: 7
                },
                '2024-12-25T10:00:00Z'
            );

            const content = notification.generateContent();
            expect(content.title).toBe('💔 Sequência perdida');
            expect(content.body).toContain('7 dias');
        });

        test('deve retornar conteúdo padrão para tipo desconhecido', () => {
            const notification = new Notification(
                'id-1',
                'user-1',
                'UNKNOWN_TYPE',
                'entity-1',
                'entity',
                {},
                '2024-12-25T10:00:00Z'
            );

            const content = notification.generateContent();
            expect(content.title).toBe('Notificação');
            expect(content.body).toBe('Você tem uma nova notificação');
        });
    });

    describe('getDaysDifference', () => {
        test('deve calcular diferença de dias corretamente', () => {
            const today = new Date();
            const tomorrow = new Date(today);
            tomorrow.setDate(today.getDate() + 1);

            const notification = new Notification(
                'id-1',
                'user-1',
                'EVENT_REMINDER',
                'event-1',
                'event',
                { date: tomorrow.toISOString() },
                today.toISOString()
            );

            const daysDiff = notification.getDaysDifference(tomorrow.toISOString());
            expect(daysDiff).toBe(1);
        });

        test('deve retornar 0 para data de hoje', () => {
            const today = new Date();
            const notification = new Notification(
                'id-1',
                'user-1',
                'EVENT_REMINDER',
                'event-1',
                'event',
                { date: today.toISOString() },
                today.toISOString()
            );

            const daysDiff = notification.getDaysDifference(today.toISOString());
            expect(daysDiff).toBe(0);
        });
    });

    describe('getHoursUntilMidnight', () => {
        test('deve calcular horas até meia-noite', () => {
            const notification = new Notification(
                'id-1',
                'user-1',
                'STREAK_WARNING',
                'streak-1',
                'streak',
                { name: 'Estudo Diário' },
                '2024-12-25T10:00:00Z'
            );

            const hoursLeft = notification.getHoursUntilMidnight();
            expect(hoursLeft).toBeGreaterThan(0);
            expect(hoursLeft).toBeLessThanOrEqual(24);
        });
    });

    describe('fromJson', () => {
        test('deve criar notificação a partir de JSON', () => {
            const jsonData = {
                id: 'id-1',
                userId: 'user-1',
                type: 'EVENT_REMINDER',
                entityId: 'event-1',
                entityType: 'event',
                entityData: { name: 'Evento' },
                scheduledFor: '2024-12-25T10:00:00Z',
                status: 'PENDING'
            };

            const notification = Notification.fromJson(jsonData);

            expect(notification.id).toBe('id-1');
            expect(notification.userId).toBe('user-1');
            expect(notification.type).toBe('EVENT_REMINDER');
            expect(notification.entityId).toBe('event-1');
            expect(notification.entityType).toBe('event');
            expect(notification.entityData).toEqual({ name: 'Evento' });
            expect(notification.scheduledFor).toBe('2024-12-25T10:00:00Z');
            expect(notification.status).toBe('PENDING');
        });
    });

    describe('toJson', () => {
        test('deve converter notificação para JSON', () => {
            const notification = new Notification(
                'id-1',
                'user-1',
                'EVENT_REMINDER',
                'event-1',
                'event',
                { name: 'Evento' },
                '2024-12-25T10:00:00Z',
                'PENDING'
            );

            const json = notification.toJson();

            expect(json).toEqual({
                id: 'id-1',
                userId: 'user-1',
                type: 'EVENT_REMINDER',
                entityId: 'event-1',
                entityType: 'event',
                entityData: { name: 'Evento' },
                scheduledFor: '2024-12-25T10:00:00Z',
                status: 'PENDING'
            });
        });
    });
}); 