import User from '../../domain/entities/user.js';
import prisma from './prisma/prismaClient.js';

export default class UserPersistence {
    constructor() {
        this.prisma = prisma;
    }

    async create(userData) {
        try {
            return await this.prisma.user.create({
                data: {
                    fcmToken: userData.fcmToken, // ✅ Direto, sem objeto aninhado
                },
            });
        } catch (error) {
            console.error('Error creating user:', error);
            throw error;
        }
    }

    async getAll() {
        try {
            const users = await this.prisma.user.findMany();
            return users.map(user => new User(user));
        } catch (error) {
            console.error('Error fetching all users:', error);
            throw error;
        }
    }

    async findByFcmToken(fcmToken) {
        try {
            const user = await this.prisma.user.findUnique({
                where: { fcmToken: fcmToken },
            });

            if (!user) {
                throw new Error(`User with FCM token ${fcmToken} not found.`);
            }

            return new User(
                user.id,
                user.fcmToken
            );
        } catch (error) {
            console.error('Error finding user by FCM token:', error);
            throw error;
        }
    }

    async findById(id) {
        try {
            const user = await this.prisma.user.findUnique({
                where: { id: id },
            });

            if (!user) {
                throw new Error(`User with ID ${id} not found.`);
            }

            return new User(
                user.id,
                user.fcmToken
            );
        } catch (error) {
            console.error('Error finding user by ID:', error);
            throw error;
        }
    }

    async update(id, userData) {
        try {
            const user = new User(userData);
            const updatedUser = await this.prisma.user.update({
                where: { id },
                data: user,
            });
            return updatedUser;
        } catch (error) {
            console.error('Error updating user:', error);
            throw error;
        }
    }

    async delete(id) {
        try {
            const deletedUser = await this.prisma.user.delete({
                where: { id },
            });
            return deletedUser;
        } catch (error) {
            console.error('Error deleting user:', error);
            throw error;
        }
    }
}