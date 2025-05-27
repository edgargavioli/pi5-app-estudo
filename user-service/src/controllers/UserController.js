const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

class UserController {
  async getAllUsers(req, res) {
    try {
      const users = await prisma.user.findMany({
        select: { id: true, username: true, email: true, points: true, lastLogin: true }
      });
      res.status(200).json({ status: 'success', data: users });
    } catch (error) {
      res.status(500).json({ status: 'error', message: error.message });
    }
  }

  async getUserById(req, res) {
    try {
      const user = await prisma.user.findUnique({
        where: { id: req.params.id },
        select: { id: true, username: true, email: true, points: true, lastLogin: true }
      });
      if (!user) {
        return res.status(404).json({ status: 'error', message: 'User not found' });
      }
      res.status(200).json({ status: 'success', data: user });
    } catch (error) {
      res.status(404).json({ status: 'error', message: error.message });
    }
  }

  async updateUser(req, res) {
    try {
      const user = await prisma.user.update({
        where: { id: req.params.id },
        data: req.body,
        select: { id: true, username: true, email: true, points: true, lastLogin: true }
      });
      res.status(200).json({ status: 'success', data: user });
    } catch (error) {
      res.status(404).json({ status: 'error', message: error.message });
    }
  }

  async deleteUser(req, res) {
    try {
      await prisma.user.delete({ where: { id: req.params.id } });
      res.status(200).json({ status: 'success', message: 'User deleted successfully' });
    } catch (error) {
      res.status(404).json({ status: 'error', message: error.message });
    }
  }

  async create(req, res) {
    try {
      const user = await prisma.user.create({
        data: req.body,
        select: { id: true, username: true, email: true, points: true, lastLogin: true }
      });
      res.status(201).json({ status: 'success', data: user });
    } catch (error) {
      res.status(400).json({ status: 'error', message: error.message });
    }
  }

  async getProfile(req, res) {
    try {
      const user = await prisma.user.findUnique({
        where: { id: req.params.id },
        select: { id: true, username: true, email: true, points: true, lastLogin: true }
      });
      if (!user) {
        return res.status(404).json({ status: 'error', message: 'User not found' });
      }
      res.status(200).json({ status: 'success', data: user });
    } catch (error) {
      res.status(404).json({ status: 'error', message: error.message });
    }
  }

  async updateProfile(req, res) {
    try {
      const user = await prisma.user.update({
        where: { id: req.params.id },
        data: req.body,
        select: { id: true, username: true, email: true, points: true, lastLogin: true }
      });
      res.status(200).json({ status: 'success', data: user });
    } catch (error) {
      res.status(404).json({ status: 'error', message: error.message });
    }
  }
}

module.exports = new UserController(); 