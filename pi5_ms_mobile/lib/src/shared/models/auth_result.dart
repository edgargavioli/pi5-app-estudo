import 'auth_user.dart';

/// 🔐 RESULTADO DE OPERAÇÕES DE AUTENTICAÇÃO
class AuthResult {
  final bool success;
  final String message;
  final AuthUser? user;

  const AuthResult({
    required this.success,
    required this.message,
    this.user,
  });

  factory AuthResult.success({
    required String message,
    required AuthUser user,
  }) {
    return AuthResult(
      success: true,
      message: message,
      user: user,
    );
  }

  factory AuthResult.error(String message) {
    return AuthResult(
      success: false,
      message: message,
      user: null,
    );
  }
} 