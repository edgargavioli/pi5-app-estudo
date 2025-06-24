import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../../config/api_config.dart';
import 'auth_service.dart';

class UserService {
  static final AuthService _authService = AuthService();
  static Future<UserModel> obterUsuario(String userId) async {
    print('🔍 Debug UserService - obterUsuario - UserID: $userId');
    print('🔍 Debug UserService - URL: ${ApiConfig.baseUrl}/users/$userId');
    print('🔍 Debug UserService - Headers: ${_authService.getAuthHeaders()}');

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/users/$userId'),
      headers: _authService.getAuthHeaders(),
    );

    print('🔍 Debug UserService - Status Code: ${response.statusCode}');
    print('🔍 Debug UserService - Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      print('🔍 Debug UserService - Response Data: $responseData');
      return UserModel.fromJson(responseData['data']);
    } else {
      final error = json.decode(response.body);
      print('🔍 Debug UserService - Error: $error');
      throw Exception(error['message'] ?? 'Falha ao obter dados do usuário');
    }
  }

  static Future<UserModel> atualizarUsuario(UserModel usuario) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/users/${usuario.id}'),
      headers: _authService.getAuthHeaders(),
      body: json.encode(usuario.toJson()),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return UserModel.fromJson(responseData['data']);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Falha ao atualizar usuário');
    }
  }

  /// Atualiza apenas o FCM token do usuário usando PATCH
  static Future<void> atualizarFcmToken(String userId, String fcmToken) async {
    final response = await http.patch(
      Uri.parse('${ApiConfig.baseUrl}/users/$userId/fcm-token'),
      headers: _authService.getAuthHeaders(),
      body: json.encode({'fcmToken': fcmToken}),
    );

    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Falha ao atualizar FCM token');
    }
  }

  /// Adiciona pontos ao usuário no backend
  static Future<bool> adicionarPontos({
    required String userId,
    required int pontos,
    required String motivo,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/users/$userId/points'),
        headers: _authService.getAuthHeaders(),
        body: json.encode({'points': pontos, 'reason': motivo, 'type': 'ADD'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Pontos adicionados com sucesso: $pontos pts por "$motivo"');
        return true;
      } else {
        print(
          'Erro ao adicionar pontos: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('Erro ao adicionar pontos: $e');
      return false;
    }
  }

  /// Busca os pontos totais do usuário
  static Future<int?> buscarPontosUsuario(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/users/$userId'),
        headers: _authService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data']['points'] as int?;
      } else {
        print('Erro ao buscar pontos: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Erro ao buscar pontos: $e');
      return null;
    }
  }
}
