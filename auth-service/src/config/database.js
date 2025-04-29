const { Pool } = require('pg');
require('dotenv').config();

// Configuração da conexão com o PostgreSQL
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  // Configurações adicionais
  max: 20, // número máximo de clientes no pool
  idleTimeoutMillis: 30000, // tempo que um cliente pode ficar ocioso antes de ser desconectado
  connectionTimeoutMillis: 2000, // tempo de espera para uma conexão
});

// Testar a conexão ao iniciar
pool.on('connect', () => {
  console.log('Conexão com o banco de dados estabelecida');
});

pool.on('error', (err) => {
  console.error('Erro inesperado na conexão com o banco de dados', err);
  process.exit(-1);
});

// Função para executar querys SQL
const query = async (text, params) => {
  const start = Date.now();
  try {
    const res = await pool.query(text, params);
    const duration = Date.now() - start;
    console.log('Query executada', { text, duration, rows: res.rowCount });
    return res;
  } catch (error) {
    console.error('Erro ao executar query', { text, error });
    throw error;
  }
};

// Função para inicializar o banco de dados (criar tabelas se necessário)
const initDatabase = async () => {
  try {
    // Criar tabela de usuários se não existir
    await query(`
      CREATE TABLE IF NOT EXISTS users (
        id UUID PRIMARY KEY,
        email VARCHAR(255) UNIQUE NOT NULL,
        password VARCHAR(255) NOT NULL,
        name VARCHAR(100),
        status VARCHAR(50) NOT NULL DEFAULT 'pending',
        login_attempts INTEGER NOT NULL DEFAULT 0,
        locked_until TIMESTAMP,
        created_at TIMESTAMP NOT NULL DEFAULT NOW(),
        updated_at TIMESTAMP NOT NULL DEFAULT NOW()
      )
    `);

    // Verificar se a coluna name já existe, caso contrário, adicionar
    try {
      await query(`
        SELECT name FROM users LIMIT 1
      `);
    } catch (error) {
      if (error.message.includes('column "name" does not exist')) {
        await query(`
          ALTER TABLE users 
          ADD COLUMN name VARCHAR(100)
        `);
        console.log('Coluna name adicionada à tabela users');
      } else {
        throw error;
      }
    }

    // Criar tabela de tokens de recuperação de senha
    await query(`
      CREATE TABLE IF NOT EXISTS password_resets (
        id SERIAL PRIMARY KEY,
        user_id UUID NOT NULL,
        token VARCHAR(255) UNIQUE NOT NULL,
        used BOOLEAN NOT NULL DEFAULT FALSE,
        expires_at TIMESTAMP NOT NULL,
        created_at TIMESTAMP NOT NULL DEFAULT NOW(),
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    `);

    console.log('Tabelas verificadas/criadas com sucesso');
  } catch (error) {
    console.error('Erro ao inicializar o banco de dados', error);
    throw error;
  }
};

module.exports = {
  query,
  pool,
  initDatabase
}; 