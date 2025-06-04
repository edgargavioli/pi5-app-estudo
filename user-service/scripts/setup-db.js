const { Client } = require('pg');
require('dotenv').config();

const setupDatabase = async () => {
  const client = new Client({
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT || 5432,
    user: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD || 'postgres',
    database: 'postgres' // Connect to default postgres database first
  });

  try {
    await client.connect();
    console.log('Connected to PostgreSQL');

    // Check if database exists
    const result = await client.query(
      "SELECT 1 FROM pg_database WHERE datname = $1",
      [process.env.DB_NAME || 'auth_service']
    );

    if (result.rowCount === 0) {
      // Create database if it doesn't exist
      await client.query(
        `CREATE DATABASE ${process.env.DB_NAME || 'auth_service'}`
      );
      console.log(`Database ${process.env.DB_NAME || 'auth_service'} created successfully`);
    } else {
      console.log(`Database ${process.env.DB_NAME || 'auth_service'} already exists`);
    }
  } catch (error) {
    console.error('Error setting up database:', error);
    process.exit(1);
  } finally {
    await client.end();
  }
};

// Run the setup
setupDatabase(); 