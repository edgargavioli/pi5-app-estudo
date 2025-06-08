const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

class HealthController {
  async check(req, res) {
    try {
      await prisma.$queryRaw`SELECT 1`;
      res.status(200).json({ status: 'ok' });
    } catch (error) {
      res.status(500).json({ status: 'error', error: error.message });
    }
  }
}

module.exports = new HealthController(); 