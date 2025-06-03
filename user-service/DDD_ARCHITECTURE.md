# Domain-Driven Design Architecture Guide

This document provides a comprehensive guide to the Domain-Driven Design (DDD) implementation in the User Service microservice.

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Layer Responsibilities](#layer-responsibilities)
3. [Domain Layer](#domain-layer)
4. [Application Layer](#application-layer)
5. [Infrastructure Layer](#infrastructure-layer)
6. [Presentation Layer](#presentation-layer)
7. [Shared Components](#shared-components)
8. [DDD Principles Applied](#ddd-principles-applied)
9. [Implementation Guidelines](#implementation-guidelines)

## Architecture Overview

The User Service follows a clean Domain-Driven Design architecture with strict separation of concerns and proper dependency direction (inward toward the domain).

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                       │
│  Controllers, Routes, HTTP Handling, HATEOAS               │
└─────────────────────┬───────────────────────────────────────┘
                      │ depends on
┌─────────────────────▼───────────────────────────────────────┐
│                   APPLICATION LAYER                        │
│     Use Cases, Business Workflows, Orchestration           │
└─────────────────────┬───────────────────────────────────────┘
                      │ depends on
┌─────────────────────▼───────────────────────────────────────┐
│                     DOMAIN LAYER                           │
│  Entities, Value Objects, Repository Interfaces            │
│              (Pure Business Logic)                         │
└─────────────────────▲───────────────────────────────────────┘
                      │ implements
┌─────────────────────┴───────────────────────────────────────┐
│                 INFRASTRUCTURE LAYER                       │
│  Database, External Services, Repository Implementations   │
└─────────────────────────────────────────────────────────────┘
```

## Layer Responsibilities

### Domain Layer (`src/domain/`)
- **Pure business logic** with no external dependencies
- **Entities** with rich behavior and validation
- **Value Objects** for data encapsulation and validation
- **Repository Interfaces** defining data access contracts
- **Domain Services** for complex business operations

### Application Layer (`src/application/`)
- **Use Cases** orchestrating business workflows
- **Authorization** and business rule enforcement
- **Coordination** between domain and infrastructure
- **Transaction management** and error handling

### Infrastructure Layer (`src/infrastructure/`)
- **Repository Implementations** using Prisma ORM
- **External Service Integrations** (email, logging)
- **Database Configuration** and connections
- **Technical Utilities** specific to infrastructure

### Presentation Layer (`src/presentation/`)
- **HTTP Controllers** handling requests/responses
- **Route Definitions** with Swagger documentation
- **HATEOAS Implementation** for API navigation
- **Input Validation** and serialization

## Domain Layer

### Entities

#### User Entity (`src/domain/entities/User.js`)
```javascript
class User {
  constructor(userData) {
    this.id = userData.id;
    this.email = userData.email;
    this.password = userData.password;
    this.name = userData.name;
    this.points = userData.points || 0;
    this.isEmailVerified = userData.isEmailVerified || false;
    // ... other properties
  }

  validate() {
    // Business validation rules
  }

  toPublicJSON() {
    // Safe serialization without sensitive data
  }
}
```

### Value Objects

#### Email Value Object (`src/domain/valueObjects/Email.js`)
- Encapsulates email validation logic
- Ensures email format correctness
- Immutable value object

#### Enhanced Password Value Object (`src/domain/valueObjects/Password.js`)
```javascript
class Password {
  static requirements = {
    minLength: 8,
    requireUppercase: true,
    requireLowercase: true,
    requireNumbers: true,
    requireSpecialChars: true
  };

  validate() {
    // Comprehensive password validation
    // - Minimum length check
    // - Uppercase letter requirement
    // - Lowercase letter requirement
    // - Number requirement
    // - Special character requirement
  }

  async hash() {
    // Secure password hashing with bcrypt
  }
}
```

### Repository Interfaces

#### UserRepository Interface (`src/domain/repositories/UserRepository.js`)
```javascript
class UserRepository {
  async findById(id) { throw new Error('Not implemented'); }
  async findByEmail(email) { throw new Error('Not implemented'); }
  async save(user) { throw new Error('Not implemented'); }
  async update(user) { throw new Error('Not implemented'); }
  async delete(id) { throw new Error('Not implemented'); }
}
```

## Application Layer

### Use Cases

#### GetUserUseCase (`src/application/useCases/GetUserUseCase.js`)
- Handles user retrieval with authorization
- Enforces business rules (users can only access their own data)
- Returns sanitized user data

#### UpdateUserUseCase (`src/application/useCases/UpdateUserUseCase.js`)
- Orchestrates user update workflow
- Validates email uniqueness
- Handles password updates with proper hashing
- Enforces authorization rules

## Infrastructure Layer

### Repository Implementations

#### PrismaUserRepository (`src/infrastructure/repositories/PrismaUserRepository.js`)
- Implements UserRepository interface
- Handles data persistence with Prisma ORM
- Converts between domain entities and database models
- Provides proper error handling

### Services

#### AuthService (`src/infrastructure/services/AuthService.js`)
- JWT token generation and verification
- User authentication and registration
- Password reset functionality
- Email verification handling

#### EmailService (`src/infrastructure/services/EmailService.js`)
- Email sending functionality
- Template management
- Development mode logging

#### LoggingService (`src/infrastructure/services/LoggingService.js`)
- Centralized logging with Winston
- Structured logging format
- HTTP request logging middleware

#### CanvasService (`src/infrastructure/services/CanvasService.js`)
- Loads background image buffers or files
- Generates personalized "wrapped" PNG images overlaying user study stats using node-canvas

#### WrappedService (`src/infrastructure/services/WrappedService.js`)
- Data aggregation for analytics
- User statistics calculation
- Achievement and points history

### Infrastructure Utilities (`src/infrastructure/utils/`)
- **passwordUtils.js**: Password hashing utilities
- **logger.js**: Logger configuration
- **hateoas.js**: HATEOAS link generation utilities

## Presentation Layer

### Controllers

#### UserController (`src/presentation/controllers/UserController.js`)
- HTTP request/response handling
- HATEOAS link generation
- Use case orchestration
- Error handling

#### AuthController (`src/presentation/controllers/AuthController.js`)
- Authentication endpoint handling
- Registration and login flows
- Password reset endpoints
- Email verification

### Routes
- **Comprehensive Swagger Documentation** with OpenAPI 3.0
- **Rate Limiting** configuration
- **Input Validation** middleware
- **Authentication** middleware integration

## Shared Components

### Middleware (`src/middleware/`)

#### Enhanced Error Handler (`src/middleware/errorHandler.js`)
```javascript
class AppError extends Error {
  constructor(message, statusCode) {
    super(message);
    this.statusCode = statusCode;
    this.status = `${statusCode}`.startsWith('4') ? 'fail' : 'error';
    this.isOperational = true;
  }
}

const handleError = (error, res) => {
  // Comprehensive error handling with logging
  // Operational vs programming error distinction
  // Proper HTTP status codes
};
```

#### Authentication Middleware (`src/middleware/auth.js`)
- JWT token verification
- User authentication
- Authorization checks

#### Rate Limiting (`src/middleware/rateLimiter.js`)
- API rate limiting
- Different limits for different endpoints
- Security protection

## DDD Principles Applied

### 1. **Ubiquitous Language**
- Domain concepts clearly expressed in code
- Consistent terminology across layers
- Business-focused naming conventions

### 2. **Bounded Context**
- Clear service boundaries
- Well-defined interfaces
- Minimal external dependencies

### 3. **Aggregate Design**
- User as aggregate root
- Consistent business rules enforcement
- Transactional boundaries

### 4. **Repository Pattern**
- Abstract data access
- Domain-focused interface
- Infrastructure implementation

### 5. **Value Objects**
- Immutable data encapsulation
- Business rule enforcement
- Type safety

### 6. **Domain Services**
- Complex business logic
- Cross-entity operations
- Pure domain concerns

## Implementation Guidelines

### 1. **Dependency Direction**
```
Presentation → Application → Domain ← Infrastructure
```

### 2. **Clean Architecture Rules**
- Domain layer has no external dependencies
- Application layer depends only on domain
- Infrastructure implements domain interfaces
- Presentation orchestrates use cases

### 3. **Error Handling Strategy**
- Domain throws business exceptions
- Application handles use case errors
- Infrastructure handles technical errors
- Presentation formats HTTP responses

### 4. **Testing Strategy**
- Unit tests for domain logic
- Integration tests for use cases
- End-to-end tests for API endpoints
- Mock external dependencies

### 5. **Security Implementation**
- Authentication in middleware
- Authorization in use cases
- Input validation at presentation
- Data sanitization in domain

## Key Improvements in This Implementation

### ✅ **No Utils Folder**
All utilities are properly organized by their architectural layer:
- Domain utilities → Domain layer
- Infrastructure utilities → Infrastructure layer
- No cross-cutting utility folders

### ✅ **Enhanced Value Objects**
- Comprehensive Password validation
- Rich Email validation
- Business logic encapsulation

### ✅ **Consolidated Error Handling**
- AppError class for operational errors
- Proper error categorization
- Comprehensive logging integration

### ✅ **Clean Separation**
- No architectural violations
- Clear dependency direction
- Proper abstraction layers

### ✅ **Rich Domain Model**
- Business logic in domain entities
- Value objects for data integrity
- Repository interfaces for data access

This architecture ensures maintainability, testability, and scalability while following DDD best practices and clean architecture principles. 