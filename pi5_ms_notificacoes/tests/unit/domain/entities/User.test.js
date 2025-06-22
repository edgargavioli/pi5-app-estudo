import { jest } from '@jest/globals';
import User from '../../../../src/domain/entities/user.js';

describe('User Entity', () => {
    describe('Constructor', () => {
        test('deve criar um usuário com todos os parâmetros', () => {
            const user = new User(
                'user-123',
                'fcm-token-456'
            );

            expect(user.id).toBe('user-123');
            expect(user.fcmToken).toBe('fcm-token-456');
        });

        test('deve criar um usuário com fcmToken undefined', () => {
            const user = new User(
                'user-123',
                undefined
            );

            expect(user.id).toBe('user-123');
            expect(user.fcmToken).toBeUndefined();
        });

        test('deve criar um usuário com fcmToken null', () => {
            const user = new User(
                'user-123',
                null
            );

            expect(user.id).toBe('user-123');
            expect(user.fcmToken).toBeNull();
        });
    });

    describe('fromJson', () => {
        test('deve criar usuário a partir de JSON com fcmToken', () => {
            const jsonData = {
                id: 'user-123',
                fcmToken: 'fcm-token-456'
            };

            const user = User.fromJson(jsonData);

            expect(user.id).toBe('user-123');
            expect(user.fcmToken).toBe('fcm-token-456');
        });

        test('deve criar usuário a partir de JSON sem fcmToken', () => {
            const jsonData = {
                id: 'user-123'
            };

            const user = User.fromJson(jsonData);

            expect(user.id).toBe('user-123');
            expect(user.fcmToken).toBeUndefined();
        });

        test('deve criar usuário a partir de JSON com fcmToken null', () => {
            const jsonData = {
                id: 'user-123',
                fcmToken: null
            };

            const user = User.fromJson(jsonData);

            expect(user.id).toBe('user-123');
            expect(user.fcmToken).toBeNull();
        });
    });

    describe('toJson', () => {
        test('deve converter usuário para JSON com fcmToken', () => {
            const user = new User(
                'user-123',
                'fcm-token-456'
            );

            const json = user.toJson();

            expect(json).toEqual({
                id: 'user-123',
                fcmToken: 'fcm-token-456'
            });
        });

        test('deve converter usuário para JSON sem fcmToken', () => {
            const user = new User(
                'user-123',
                undefined
            );

            const json = user.toJson();

            expect(json).toEqual({
                id: 'user-123',
                fcmToken: undefined
            });
        });

        test('deve converter usuário para JSON com fcmToken null', () => {
            const user = new User(
                'user-123',
                null
            );

            const json = user.toJson();

            expect(json).toEqual({
                id: 'user-123',
                fcmToken: null
            });
        });
    });

    describe('Validações', () => {
        test('deve aceitar ID como string vazia', () => {
            const user = new User('', 'fcm-token');
            expect(user.id).toBe('');
        });

        test('deve aceitar ID como string com espaços', () => {
            const user = new User('  user-123  ', 'fcm-token');
            expect(user.id).toBe('  user-123  ');
        });

        test('deve aceitar fcmToken como string vazia', () => {
            const user = new User('user-123', '');
            expect(user.fcmToken).toBe('');
        });

        test('deve aceitar fcmToken como string com espaços', () => {
            const user = new User('user-123', '  fcm-token  ');
            expect(user.fcmToken).toBe('  fcm-token  ');
        });
    });
}); 