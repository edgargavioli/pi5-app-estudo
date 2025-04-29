import 'package:pi5_ms_mobile/src/services/auth_service.dart';
import 'package:pi5_ms_mobile/src/models/user_model.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository(this._authService);

  Future<UserModel> register(String name, String email, String password) async {
    try {
      final response = await _authService.register(name, email, password);
      final userData = response['data']['user'];
      return UserModel.fromJson({
        'id': userData['id'],
        'name': name,
        'email': userData['email'],
        'token': response['data']['accessToken'],
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> login(String email, String password) async {
    try {
      final response = await _authService.login(email, password);
      final userData = response['data']['user'];
      return UserModel.fromJson({
        'id': userData['id'],
        'name': userData['name'],
        'email': userData['email'],
        'token': response['data']['accessToken'],
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> recoverPassword(String email) async {
    try {
      await _authService.recoverPassword(email);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resetPassword(String token, String newPassword) async {
    try {
      await _authService.resetPassword(token, newPassword);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> verifyResetToken(String token) async {
    try {
      return await _authService.verifyPasswordResetToken(token);
    } catch (e) {
      throw Exception('Falha ao verificar o token: ${e.toString()}');
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      await _authService.changePassword(currentPassword, newPassword);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> isAuthenticated() async {
    try {
      return await _authService.isAuthenticated();
    } catch (e) {
      rethrow;
    }
  }
} 