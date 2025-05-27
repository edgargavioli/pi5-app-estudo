# Authentication Microservice

A microservice for handling user authentication, built with Node.js, Express, and Prisma.

## Features

- User registration and login
- JWT-based authentication
- Google OAuth integration
- Email verification
- Password reset functionality
- Rate limiting
- Swagger API documentation

## Prerequisites

- Node.js 20 or higher
- Docker and Docker Compose
- PostgreSQL 16 or higher

## Setup

1. Clone the repository
2. Copy `.env.example` to `.env` and update the values
3. Install dependencies:
   ```bash
   npm install
   ```

4. Start the services with Docker:
   ```bash
   docker compose up --build
   ```

## Development

### Database Migrations

- Create a new migration:
  ```bash
  npm run prisma:migrate
  ```

- View database with Prisma Studio:
  ```bash
  npm run prisma:studio
  ```

### API Documentation

Access the Swagger documentation at:
```
http://localhost:3000/api-docs
```

## Project Structure

```
auth-service/
├── src/
│   ├── domain/              # Business logic and entities
│   ├── application/         # Use cases
│   ├── infrastructure/      # External services and implementations
│   ├── presentation/        # Controllers and routes
│   └── config/             # Configuration files
├── prisma/                 # Prisma schema and migrations
└── scripts/               # Utility scripts
```

## Environment Variables

See `.env.example` for all required environment variables.

## API Endpoints

- POST `/api/auth/register` - Register a new user
- POST `/api/auth/login` - User login
- POST `/api/auth/google` - Google OAuth login
- GET `/api/auth/verify-email/:token` - Verify email
- POST `/api/auth/forgot-password` - Request password reset
- POST `/api/auth/reset-password` - Reset password

## License

ISC 