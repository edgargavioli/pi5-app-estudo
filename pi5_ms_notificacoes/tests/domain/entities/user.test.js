import { describe, test, expect, beforeEach } from '@jest/globals';
import User from '../../../src/domain/entities/user.js';

describe('User Entity', () => {
    let user;

    beforeEach(() => {
        user = new User('user-123', 'fcm-token-abc123');
    });

    describe('Constructor', () => {
        test('should create user with all properties', () => {
            expect(user.id).toBe('user-123');
            expect(user.fcmToken).toBe('fcm-token-abc123');
        });

        test('should create user with null fcmToken', () => {
            const userWithNullToken = new User('user-456', null);
            expect(userWithNullToken.id).toBe('user-456');
            expect(userWithNullToken.fcmToken).toBeNull();
        });

        test('should create user with undefined fcmToken', () => {
            const userWithUndefinedToken = new User('user-789', undefined);
            expect(userWithUndefinedToken.id).toBe('user-789');
            expect(userWithUndefinedToken.fcmToken).toBeUndefined();
        });

        test('should create user with empty string fcmToken', () => {
            const userWithEmptyToken = new User('user-empty', '');
            expect(userWithEmptyToken.id).toBe('user-empty');
            expect(userWithEmptyToken.fcmToken).toBe('');
        });
    });

    describe('Serialization', () => {
        describe('fromJson', () => {
            test('should create user from JSON with all properties', () => {
                const json = {
                    id: 'json-user-123',
                    fcmToken: 'json-fcm-token-456'
                };

                const userFromJson = User.fromJson(json);
                
                expect(userFromJson.id).toBe('json-user-123');
                expect(userFromJson.fcmToken).toBe('json-fcm-token-456');
                expect(userFromJson).toBeInstanceOf(User);
            });

            test('should create user from JSON with null fcmToken', () => {
                const json = {
                    id: 'json-user-null',
                    fcmToken: null
                };

                const userFromJson = User.fromJson(json);
                
                expect(userFromJson.id).toBe('json-user-null');
                expect(userFromJson.fcmToken).toBeNull();
            });

            test('should create user from JSON with missing fcmToken', () => {
                const json = {
                    id: 'json-user-missing'
                };

                const userFromJson = User.fromJson(json);
                
                expect(userFromJson.id).toBe('json-user-missing');
                expect(userFromJson.fcmToken).toBeUndefined();
            });

            test('should handle empty JSON object', () => {
                const json = {};

                const userFromJson = User.fromJson(json);
                
                expect(userFromJson.id).toBeUndefined();
                expect(userFromJson.fcmToken).toBeUndefined();
            });
        });

        describe('toJson', () => {
            test('should convert user to JSON with all properties', () => {
                const json = user.toJson();
                
                expect(json.id).toBe('user-123');
                expect(json.fcmToken).toBe('fcm-token-abc123');
                expect(Object.keys(json)).toEqual(['id', 'fcmToken']);
            });

            test('should convert user with null fcmToken to JSON', () => {
                const userWithNullToken = new User('user-null', null);
                const json = userWithNullToken.toJson();
                
                expect(json.id).toBe('user-null');
                expect(json.fcmToken).toBeNull();
            });

            test('should convert user with undefined fcmToken to JSON', () => {
                const userWithUndefinedToken = new User('user-undefined', undefined);
                const json = userWithUndefinedToken.toJson();
                
                expect(json.id).toBe('user-undefined');
                expect(json.fcmToken).toBeUndefined();
            });
        });

        test('should maintain data integrity through serialization cycle', () => {
            const originalJson = user.toJson();
            const recreatedUser = User.fromJson(originalJson);
            const recreatedJson = recreatedUser.toJson();
            
            expect(recreatedJson).toEqual(originalJson);
        });

        test('should maintain data integrity with null values', () => {
            const userWithNull = new User('test-null', null);
            const json = userWithNull.toJson();
            const recreatedUser = User.fromJson(json);
            const finalJson = recreatedUser.toJson();
            
            expect(finalJson).toEqual(json);
            expect(finalJson.fcmToken).toBeNull();
        });
    });

    describe('Edge Cases', () => {
        test('should handle special characters in id', () => {
            const specialUser = new User('user-123!@#$%', 'token-456');
            expect(specialUser.id).toBe('user-123!@#$%');
            
            const json = specialUser.toJson();
            const recreated = User.fromJson(json);
            expect(recreated.id).toBe('user-123!@#$%');
        });

        test('should handle long fcmToken', () => {
            const longToken = 'a'.repeat(1000);
            const userWithLongToken = new User('user-long', longToken);
            expect(userWithLongToken.fcmToken).toBe(longToken);
            
            const json = userWithLongToken.toJson();
            const recreated = User.fromJson(json);
            expect(recreated.fcmToken).toBe(longToken);
        });

        test('should handle unicode characters', () => {
            const unicodeUser = new User('user-🔥', 'token-🚀');
            expect(unicodeUser.id).toBe('user-🔥');
            expect(unicodeUser.fcmToken).toBe('token-🚀');
            
            const json = unicodeUser.toJson();
            const recreated = User.fromJson(json);
            expect(recreated.id).toBe('user-🔥');
            expect(recreated.fcmToken).toBe('token-🚀');
        });
    });

    describe('Type Safety', () => {
        test('should preserve instance type after fromJson', () => {
            const json = { id: 'test', fcmToken: 'token' };
            const userFromJson = User.fromJson(json);
            
            expect(userFromJson).toBeInstanceOf(User);
            expect(typeof userFromJson.toJson).toBe('function');
        });

        test('should have correct property types', () => {
            expect(typeof user.id).toBe('string');
            expect(typeof user.fcmToken).toBe('string');
        });

        test('should handle number id conversion', () => {
            const jsonWithNumberId = { id: 123, fcmToken: 'token' };
            const userFromJson = User.fromJson(jsonWithNumberId);
            
            expect(userFromJson.id).toBe(123);
            expect(typeof userFromJson.id).toBe('number');
        });
    });
}); 