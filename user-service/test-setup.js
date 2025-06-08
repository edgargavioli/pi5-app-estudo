// Test script to verify all imports work correctly
console.log('Testing imports...');

try {
  // Test server imports
  require('./src/server.js');
  console.log('✅ Server imports successful');
  
  // Test main controllers
  require('./src/presentation/controllers/AuthController');
  require('./src/presentation/controllers/UserController');
  require('./src/presentation/controllers/WrappedController');
  require('./src/presentation/controllers/HealthController');
  console.log('✅ Controllers import successful');
  
  // Test services
  require('./src/infrastructure/services/AuthService');
  require('./src/infrastructure/services/EmailService');
  require('./src/infrastructure/services/LoggingService');
  require('./src/infrastructure/services/WrappedService');
  console.log('✅ Services import successful');
  
  // Test use cases
  require('./src/application/useCases/GetUserUseCase');
  require('./src/application/useCases/UpdateUserUseCase');
  console.log('✅ Use cases import successful');
  
  // Test domain entities
  require('./src/domain/entities/User');
  require('./src/domain/valueObjects/Email');
  require('./src/domain/valueObjects/Password');
  require('./src/domain/repositories/UserRepository');
  console.log('✅ Domain layer import successful');
  
  // Test infrastructure
  require('./src/infrastructure/repositories/PrismaUserRepository');
  require('./src/infrastructure/database/config');
  console.log('✅ Infrastructure layer import successful');
  
  console.log('\n🎉 All imports successful! The project is ready to run.');
  
} catch (error) {
  console.error('❌ Import error:', error.message);
  console.error('Stack:', error.stack);
  process.exit(1);
} 