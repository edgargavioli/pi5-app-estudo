# User Service - Domain-Driven Design Architecture

A microservice for handling user authentication and management, built with Node.js, Express, Prisma, and following Domain-Driven Design (DDD) principles.

## Features

- **Domain-Driven Design Architecture** with clean separation of concerns
- **HATEOAS Implementation** for RESTful API navigation
- **Comprehensive Swagger Documentation** with OpenAPI 3.0
- **JWT-based Authentication** with refresh tokens
- **User Management** with profile images (base64)
- **Email Verification** and password reset
- **Rate Limiting** and security middleware
- **Gamification Data Integration** (read-only access)
- **Comprehensive Logging** with Winston
- **Input Validation** with Joi schemas

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

- Deploy migrations:
  ```bash
  npm run prisma:deploy
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

## Clean Domain-Driven Design Structure

```
user-service/
├── src/
│   ├── domain/                          # ✅ PURE BUSINESS LOGIC
│   │   ├── entities/
│   │   │   └── User.js                  # ✅ Rich domain entity with validation
│   │   ├── valueObjects/
│   │   │   ├── Email.js                 # ✅ Email validation encapsulation
│   │   │   └── Password.js              # ✅ Enhanced password validation & hashing
│   │   └── repositories/
│   │       └── UserRepository.js        # ✅ Repository interface
│   │
│   ├── application/                     # ✅ USE CASES & ORCHESTRATION
│   │   └── useCases/
│   │       ├── GetUserUseCase.js        # ✅ Business logic orchestration
│   │       └── UpdateUserUseCase.js     # ✅ Business logic orchestration
│   │
│   ├── infrastructure/                  # ✅ EXTERNAL CONCERNS
│   │   ├── repositories/
│   │   │   └── PrismaUserRepository.js  # ✅ Data persistence implementation
│   │   ├── services/
│   │   │   ├── AuthService.js           # ✅ JWT & authentication
│   │   │   ├── EmailService.js          # ✅ Email sending
│   │   │   ├── LoggingService.js        # ✅ Logging infrastructure
│   │   │   └── WrappedService.js        # ✅ Data aggregation service
│   │   ├── database/
│   │   │   └── config.js                # ✅ Database configuration
│   │   ├── middlewares/
│   │   │   └── hateoas.js               # ✅ HATEOAS middleware
│   │   └── utils/                       # ✅ Infrastructure-specific utilities
│   │       ├── passwordUtils.js
│   │       ├── logger.js
│   │       └── hateoas.js
│   │
│   ├── presentation/                    # ✅ HTTP INTERFACE
│   │   ├── controllers/
│   │   │   ├── UserController.js        # ✅ HTTP handling with HATEOAS
│   │   │   ├── AuthController.js        # ✅ Authentication endpoints
│   │   │   ├── WrappedController.js     # ✅ Data aggregation controller
│   │   │   └── HealthController.js      # ✅ Health check controller
│   │   └── routes/
│   │       ├── userRoutes.js            # ✅ User management routes
│   │       ├── authRoutes.js            # ✅ Authentication routes
│   │       ├── auth.js                  # ✅ Auth route definitions
│   │       └── wrapped.js               # ✅ Data aggregation routes
│   │
│   ├── middleware/                      # ✅ SHARED MIDDLEWARE
│   │   ├── auth.js                      # ✅ Authentication middleware
│   │   ├── validation.js                # ✅ Input validation
│   │   ├── rateLimiter.js               # ✅ Rate limiting
│   │   └── errorHandler.js              # ✅ Enhanced error handling with AppError
│   │
│   └── server.js                        # ✅ Application entry point
├── prisma/                              # Database schema and migrations
├── logs/                                # Application logs
└── scripts/                             # Utility scripts
```

## Architecture Principles

### Domain-Driven Design Layers

1. **Domain Layer** (`src/domain/`)
   - Contains core business logic and rules
   - Entities with rich behavior and validation
   - Value objects for data encapsulation (Email, Password)
   - Repository interfaces (no implementations)

2. **Application Layer** (`src/application/`)
   - Orchestrates business logic through use cases
   - Handles authorization and business workflows
   - Coordinates between domain and infrastructure

3. **Infrastructure Layer** (`src/infrastructure/`)
   - Implements repository interfaces
   - External service integrations (email, logging)
   - Database configuration and connections
   - Technical middleware implementations

4. **Presentation Layer** (`src/presentation/`)
   - HTTP request/response handling
   - HATEOAS link generation
   - API route definitions with Swagger docs
   - Input validation and serialization

### Key DDD Improvements

- ✅ **No Utils Folder**: All utilities properly organized by layer
- ✅ **Enhanced Password Value Object**: Comprehensive validation rules
- ✅ **Consolidated Error Handling**: AppError class with proper logging
- ✅ **Clean Separation**: No cross-layer violations
- ✅ **Rich Domain Model**: Business logic encapsulated in domain entities

## API Endpoints

### Authentication
- `POST /api/auth/register` - Register a new user
- `POST /api/auth/login` - User login
- `POST /api/auth/refresh-token` - Refresh access token
- `GET /api/auth/verify-email` - Verify email address
- `POST /api/auth/request-password-reset` - Request password reset
- `POST /api/auth/reset-password` - Reset password
- `POST /api/auth/logout` - User logout

### User Management (DDD Implementation)
- `GET /api/users/{id}` - Get user profile
- `PUT /api/users/{id}` - Update user profile
- `DELETE /api/users/{id}` - Delete user account
- `POST /api/users/{id}/image` - Upload profile image
- `GET /api/users/{id}/image` - Get profile image

### Data Aggregation
- `GET /api/wrapped/{id}` - Get aggregated user data
- `GET /api/wrapped/{id}/achievements` - Get user achievements
- `GET /api/wrapped/{id}/points-history` - Get points history

### System
- `GET /health` - Health check endpoint

## HATEOAS Implementation

All API responses include `_links` object with navigation links:

```json
{
  "data": {
    "id": "user-id",
    "email": "user@example.com",
    "name": "John Doe"
  },
  "_links": {
    "self": { "href": "/api/users/user-id", "method": "GET" },
    "update": { "href": "/api/users/user-id", "method": "PUT" },
    "delete": { "href": "/api/users/user-id", "method": "DELETE" },
    "image": { "href": "/api/users/user-id/image", "method": "GET" },
    "wrapped": { "href": "/api/wrapped/user-id", "method": "GET" }
  }
}
```

## Security Features

- **JWT Authentication** with access and refresh tokens
- **Rate Limiting** (100 requests per 15 minutes for user operations)
- **Input Validation** with Joi schemas
- **Authorization Checks** (users can only access their own data)
- **Security Headers** with Helmet middleware
- **Enhanced Password Validation** with comprehensive rules
- **SQL Injection Prevention** through Prisma ORM
- **Comprehensive Error Handling** with AppError class

## Environment Variables

```env
# Database
DATABASE_URL=postgresql://username:password@localhost:5432/userservice

# JWT
JWT_SECRET=your-super-secret-jwt-key
JWT_EXPIRES_IN=24h

# Server
PORT=3000
NODE_ENV=development

# Email (Optional - uses console logging in development)
SMTP_HOST=smtp.example.com
SMTP_PORT=587
SMTP_USER=your-email@example.com
SMTP_PASS=your-password
FROM_EMAIL=noreply@example.com

# Frontend (for email links)
FRONTEND_URL=http://localhost:3000

# Logging
LOG_LEVEL=info
```

## Testing

Run tests with:
```bash
npm test
```

## Documentation

For detailed architecture documentation, see:
- [DDD_ARCHITECTURE.md](./DDD_ARCHITECTURE.md) - Complete DDD implementation guide

## License

ISC 