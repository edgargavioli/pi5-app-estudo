import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../../config/api_config.dart';
import 'auth_service.dart';

class UserService {
  static final AuthService _authService = AuthService();

  static Future<User> obterUsuario(String userId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/users/$userId'),
      headers: _authService.getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return User.fromJson(responseData['data']);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Falha ao obter dados do usuário');
    }
  }

  static Future<User> atualizarUsuario(User usuario) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/users/${usuario.id}'),
      headers: _authService.getAuthHeaders(),
      body: json.encode(usuario.toJson()),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return User.fromJson(responseData['data']);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Falha ao atualizar usuário');
    }
  }
} 