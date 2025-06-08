import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'cache_service.dart';
import 'gamificacao_service.dart';
import '../models/user_model.dart';
import '../models/auth_result.dart';
import '../../config/api_config.dart';

class AuthService {
  // 🌐 URL DO USER-SERVICE
  static const String _userServiceUrl = 'http://localhost:3000/api';
  
  // 🔑 CHAVES PARA ARMAZENAMENTO LOCAL
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';

  // 📱 SINGLETON PATTERN
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // 🎯 ESTADO ATUAL DO USUÁRIO
  AuthUser? _currentUser;
  String? _accessToken;
  String? _refreshToken;

  // Getters
  AuthUser? get currentUser => _currentUser;
  String? get accessToken => _accessToken;
  bool get isLoggedIn => _currentUser != null && _accessToken != null;

  /// 🚀 INICIALIZAR SERVIÇO (verificar tokens salvos)
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _accessToken = prefs.getString(_accessTokenKey);
      _refreshToken = prefs.getString(_refreshTokenKey);
      
      final userDataJson = prefs.getString(_userDataKey);
      if (userDataJson != null) {
        final userData = json.decode(userDataJson);
        _currentUser = AuthUser.fromJson(userData);
      }

      // Se tem token, verificar se ainda é válido
      if (_accessToken != null) {
        final isValid = await _validateToken();
        if (!isValid) {
          await logout(); // Token inválido, fazer logout
        }
      }
    } catch (e) {
      print('❌ Erro ao inicializar AuthService: $e');
      await logout(); // Em caso de erro, limpar tudo
    }
  }

  /// 🔐 LOGIN
  Future<AuthResult> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_userServiceUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Salvar tokens
        _accessToken = data['data']['accessToken'];
        _refreshToken = data['data']['refreshToken'];
        
        // Salvar dados do usuário
        _currentUser = AuthUser.fromJson(data['data']['user']);
        
        // Persistir dados
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_accessTokenKey, _accessToken!);
        await prefs.setString(_refreshTokenKey, _refreshToken!);
        await prefs.setString(_userDataKey, json.encode(_currentUser!.toJson()));

        return AuthResult.success(
          message: 'Login realizado com sucesso',
          user: _currentUser!,
        );
      } else {
        final error = json.decode(response.body);
        return AuthResult.error(error['message'] ?? 'Falha ao fazer login');
      }
    } catch (e) {
      print('❌ Erro no login: $e');
      return AuthResult.error('Erro inesperado ao fazer login');
    }
  }

  /// 📝 REGISTRO
  Future<AuthResult> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_userServiceUrl/auth/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        
        // Salvar tokens
        _accessToken = data['data']['accessToken'];
        _refreshToken = data['data']['refreshToken'];
        
        // Salvar dados do usuário
        _currentUser = AuthUser.fromJson(data['data']['user']);
        
        // Persistir dados
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_accessTokenKey, _accessToken!);
        await prefs.setString(_refreshTokenKey, _refreshToken!);
        await prefs.setString(_userDataKey, json.encode(_currentUser!.toJson()));

        return AuthResult.success(
          message: 'Registro realizado com sucesso',
          user: data['data']['user'],
        );
      } else {
        final error = json.decode(response.body);
        return AuthResult.error(error['message'] ?? 'Falha ao fazer registro');
      }
    } catch (e) {
      print('❌ Erro no registro: $e');
      return AuthResult.error('Erro inesperado ao fazer registro');
    }
  }

  /// 🚪 LOGOUT
  Future<void> logout() async {
    try {
      // Limpar dados locais
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_accessTokenKey);
      await prefs.remove(_refreshTokenKey);
      await prefs.remove(_userDataKey);
      
      // Limpar estado
      _accessToken = null;
      _refreshToken = null;
      _currentUser = null;
      
      // Limpar cache
      CacheService.clear();
    } catch (e) {
      print('❌ Erro ao fazer logout: $e');
      rethrow;
    }
  }

  /// 🔄 RENOVAR TOKENS
  Future<bool> refreshTokens() async {
    try {
      if (_refreshToken == null) return false;

      final response = await http.post(
        Uri.parse('$_userServiceUrl/auth/refresh'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'refreshToken': _refreshToken,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Atualizar tokens
        _accessToken = data['data']['accessToken'];
        _refreshToken = data['data']['refreshToken'];
        
        // Persistir novos tokens
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_accessTokenKey, _accessToken!);
        await prefs.setString(_refreshTokenKey, _refreshToken!);
        
        return true;
      }
      
      return false;
    } catch (e) {
      print('❌ Erro ao renovar tokens: $e');
      return false;
    }
  }

  /// ✅ VALIDAR TOKEN
  Future<bool> _validateToken() async {
    try {
      final response = await http.get(
        Uri.parse('$_userServiceUrl/auth/validate'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Accept': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Erro ao validar token: $e');
      return false;
    }
  }

  /// 🔑 OBTER HEADERS COM TOKEN
  Map<String, String> getAuthHeaders() {
    return {
      'Authorization': 'Bearer $_accessToken',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }
}

/// 👤 MODELO DE USUÁRIO PARA AUTENTICAÇÃO
class AuthUser {
  final String id;
  final String? nome;
  final String? email;
  final bool isEmailVerified;
  final DateTime? lastLogin;

  AuthUser({
    required this.id,
    this.nome,
    this.email,
    this.isEmailVerified = false,
    this.lastLogin,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'],
      nome: json['name'],
      email: json['email'],
      isEmailVerified: json['isEmailVerified'] ?? false,
      lastLogin: json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': nome,
      'email': email,
      'isEmailVerified': isEmailVerified,
      'lastLogin': lastLogin?.toIso8601String(),
    };
  }
}

/// 📋 RESULTADO DE OPERAÇÃO DE AUTENTICAÇÃO
class AuthResult {
  final bool success;
  final String message;
  final AuthUser? user;

  AuthResult.success({required this.user, required this.message})
      : success = true;

  AuthResult.error(this.message)
      : success = false,
        user = null;
} 