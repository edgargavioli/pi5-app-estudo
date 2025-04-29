const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const cookieParser = require('cookie-parser');
const authRoutes = require('./interfaces/routes/authRoutes');
const { initDatabase } = require('./config/database');
const rabbitmqService = require('./infrastructure/rabbitmq/rabbitmqService');
const emailService = require('./infrastructure/email/emailService');
require('dotenv').config();

// Inicializar o servidor Express
const app = express();
const PORT = process.env.PORT || 3000;

// Middlewares
app.use(helmet()); // Segurança
app.use(cors({
  origin: process.env.CORS_ORIGIN || '*',
  credentials: true
}));
app.use(express.json()); // Parsear JSON
app.use(cookieParser()); // Parsear cookies

// Rotas
app.use('/api/auth', authRoutes);

// Rota de teste/status
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'ok',
    service: 'auth-service',
    timestamp: new Date().toISOString()
  });
});

// Middleware para tratar erros
app.use((err, req, res, next) => {
  console.error('Erro não tratado:', err);
  res.status(500).json({
    success: false,
    message: 'Erro interno do servidor'
  });
});

// Middleware para rotas não encontradas
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'Rota não encontrada'
  });
});

// Inicializar o banco de dados, RabbitMQ e serviço de email antes de iniciar o servidor
const startServer = async () => {
  try {
    // Inicializar banco de dados
    await initDatabase();
    console.log('Banco de dados inicializado com sucesso');

    // Conectar ao RabbitMQ
    await rabbitmqService.connect();
    console.log('Conectado ao RabbitMQ com sucesso');

    // Inicializar serviço de email
    await emailService.initEmailService();
    
    // Iniciar o servidor
    app.listen(PORT, () => {
      console.log(`Servidor rodando na porta ${PORT}`);
    });
  } catch (error) {
    console.error('Erro ao inicializar o servidor:', error);
    process.exit(1);
  }
};

// Tratar sinais de encerramento
process.on('SIGINT', async () => {
  console.log('Encerrando servidor...');
  await rabbitmqService.close();
  process.exit(0);
});

process.on('SIGTERM', async () => {
  console.log('Encerrando servidor...');
  await rabbitmqService.close();
  process.exit(0);
});

// Iniciar o servidor
startServer(); 