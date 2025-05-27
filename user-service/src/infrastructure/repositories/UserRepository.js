const { User } = require('../../domain/entities/User');
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

class UserRepository {
  async findByEmailOrUsername(email, username) {
    const user = await prisma.user.findFirst({
      where: {
        OR: [
          { email },
          { username }
        ]
      }
    });
    return user ? User.fromDatabase(user) : null;
  }

  async save(user) {
    if (user.id) {
      return prisma.user.update({
        where: { id: user.id },
        data: {
          email: user.email,
          password: user.password,
          name: user.name,
          points: user.points,
          lastLogin: user.lastLogin
        }
      });
    }

    return prisma.user.create({
      data: {
        email: user.email,
        password: user.password,
        name: user.name,
        points: user.points,
        lastLogin: user.lastLogin
      }
    });
  }

  async findById(id) {
    const user = await prisma.user.findUnique({
      where: { id }
    });
    return user ? User.fromDatabase(user) : null;
  }

  async findByEmail(email) {
    const user = await prisma.user.findUnique({
      where: { email }
    });
    return user ? User.fromDatabase(user) : null;
  }

  async updateLastLogin(id) {
    return prisma.user.update({
      where: { id },
      data: { lastLogin: new Date() }
    });
  }
}

module.exports = new UserRepository(); 