import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'http://localhost:3000/api/auth';
  final SharedPreferences _prefs;

  AuthService(this._prefs);

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      await _saveTokens(data['data']['tokens']);
      return data;
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      if (!data['success']) {
        throw Exception(data['message'] ?? 'Erro ao fazer login');
      }

      await _saveTokens({
        'accessToken': data['data']['accessToken'],
        'refreshToken': data['data']['refreshToken']
      });
      return data;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Erro ao fazer login');
    }
  }

  Future<void> logout() async {
    final accessToken = await _getAccessToken();
    if (accessToken != null) {
      await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );
    }
    await _clearTokens();
  }

  Future<void> recoverPassword(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/recover-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    final data = jsonDecode(response.body);
    
    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Erro ao tentar recuperar senha');
    }
    
    if (data['success'] == false) {
      throw Exception(data['message'] ?? 'Email não encontrado');
    }
  }

  Future<void> resetPassword(String token, String newPassword) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'token': token,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    final accessToken = await _getAccessToken();
    if (accessToken == null) throw Exception('Usuário não autenticado');

    final response = await http.put(
      Uri.parse('$baseUrl/change-password'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  Future<bool> isAuthenticated() async {
    final accessToken = await _getAccessToken();
    if (accessToken == null) return false;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/verify-token'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> verifyPasswordResetToken(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify-reset-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token}),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode != 200) {
        throw Exception(data['message'] ?? 'Token inválido');
      }
      
      return data['success'] == true;
    } catch (e) {
      throw Exception('Token inválido ou expirado');
    }
  }

  Future<String?> _getAccessToken() async {
    return _prefs.getString('accessToken');
  }

  Future<void> _saveTokens(Map<String, dynamic> tokens) async {
    await _prefs.setString('accessToken', tokens['accessToken']);
    await _prefs.setString('refreshToken', tokens['refreshToken']);
  }

  Future<void> _clearTokens() async {
    await _prefs.remove('accessToken');
    await _prefs.remove('refreshToken');
  }
} 