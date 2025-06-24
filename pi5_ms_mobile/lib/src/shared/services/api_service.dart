import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiService {
  // 🌐 URLs DOS MICROSERVIÇOS
  static const String _userServiceUrl = 'http://10.0.2.2:3000';
  static const String _provasServiceUrl = 'http://10.0.2.2:3002';

  // 🔐 INSTÂNCIA DO SERVIÇO DE AUTENTICAÇÃO
  static final AuthService _authService = AuthService();

  /// 🛡️ OBTER HEADERS COM AUTENTICAÇÃO
  static Map<String, String> _getHeaders({bool needsAuth = true}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (needsAuth && _authService.isAuthenticated) {
      headers['Authorization'] = 'Bearer ${_authService.accessToken}';
    }

    return headers;
  }

  /// 🌐 OBTER URL BASE BASEADO NO ENDPOINT
  static String _getBaseUrl(String endpoint) {
    // Endpoints do user-service
    if (endpoint.startsWith('/api/auth/') ||
        endpoint.startsWith('/api/users/') ||
        endpoint.startsWith('/api/gamificacao/')) {
      return _userServiceUrl;
    }

    // Endpoints do provas-service
    if (endpoint.startsWith('/materias') ||
        endpoint.startsWith('/provas') ||
        endpoint.startsWith('/sessoes') ||
        endpoint.startsWith('/eventos')) {
      return _provasServiceUrl;
    }

    // Default para user-service
    return _userServiceUrl;
  }

  /// 🔄 RENOVAR TOKEN SE NECESSÁRIO
  static Future<bool> _handleTokenRefresh() async {
    try {
      return await _authService.refreshTokens();
    } catch (e) {
      print('❌ Erro ao renovar token: $e');
      return false;
    }
  }

  /// 📥 GET REQUEST
  static Future<Map<String, dynamic>> get(
    String endpoint, {
    bool needsAuth = true,
  }) async {
    try {
      final baseUrl = _getBaseUrl(endpoint);
      final headers = _getHeaders(needsAuth: needsAuth);

      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );

      // Se token expirado, tentar renovar
      if (response.statusCode == 401 && needsAuth) {
        final renewed = await _handleTokenRefresh();
        if (renewed) {
          // Tentar novamente com novo token
          final newHeaders = _getHeaders(needsAuth: needsAuth);
          final retryResponse = await http.get(
            Uri.parse('$baseUrl$endpoint'),
            headers: newHeaders,
          );
          return _handleResponse(retryResponse);
        } else {
          throw ApiException('Sessão expirada. Faça login novamente.', 401);
        }
      }

      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erro de conexão: $e', 0);
    }
  }

  /// 📤 POST REQUEST
  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, Object?> data, {
    bool needsAuth = true,
  }) async {
    try {
      final baseUrl = _getBaseUrl(endpoint);
      final headers = _getHeaders(needsAuth: needsAuth);

      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: json.encode(data),
      );

      // Se token expirado, tentar renovar
      if (response.statusCode == 401 && needsAuth) {
        final renewed = await _handleTokenRefresh();
        if (renewed) {
          // Tentar novamente com novo token
          final newHeaders = _getHeaders(needsAuth: needsAuth);
          final retryResponse = await http.post(
            Uri.parse('$baseUrl$endpoint'),
            headers: newHeaders,
            body: json.encode(data),
          );
          return _handleResponse(retryResponse);
        } else {
          throw ApiException('Sessão expirada. Faça login novamente.', 401);
        }
      }

      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erro de conexão: $e', 0);
    }
  }

  /// 🔄 PUT REQUEST
  static Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, Object?> data, {
    bool needsAuth = true,
  }) async {
    try {
      final baseUrl = _getBaseUrl(endpoint);
      final headers = _getHeaders(needsAuth: needsAuth);

      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: json.encode(data),
      );

      // Se token expirado, tentar renovar
      if (response.statusCode == 401 && needsAuth) {
        final renewed = await _handleTokenRefresh();
        if (renewed) {
          final newHeaders = _getHeaders(needsAuth: needsAuth);
          final retryResponse = await http.put(
            Uri.parse('$baseUrl$endpoint'),
            headers: newHeaders,
            body: json.encode(data),
          );
          return _handleResponse(retryResponse);
        } else {
          throw ApiException('Sessão expirada. Faça login novamente.', 401);
        }
      }

      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erro de conexão: $e', 0);
    }
  }

  /// 🗑️ DELETE REQUEST
  static Future<void> delete(String endpoint, {bool needsAuth = true}) async {
    try {
      final baseUrl = _getBaseUrl(endpoint);
      final headers = _getHeaders(needsAuth: needsAuth);

      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );

      // Se token expirado, tentar renovar
      if (response.statusCode == 401 && needsAuth) {
        final renewed = await _handleTokenRefresh();
        if (renewed) {
          final newHeaders = _getHeaders(needsAuth: needsAuth);
          final retryResponse = await http.delete(
            Uri.parse('$baseUrl$endpoint'),
            headers: newHeaders,
          );
          _handleDeleteResponse(retryResponse);
          return;
        } else {
          throw ApiException('Sessão expirada. Faça login novamente.', 401);
        }
      }

      _handleDeleteResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erro de conexão: $e', 0);
    }
  }

  /// 🔧 PATCH REQUEST
  static Future<Map<String, dynamic>> patch(
    String endpoint,
    Map<String, dynamic> data, {
    bool needsAuth = true,
  }) async {
    try {
      final baseUrl = _getBaseUrl(endpoint);
      final headers = _getHeaders(needsAuth: needsAuth);

      final response = await http.patch(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: json.encode(data),
      );

      // Se token expirado, tentar renovar
      if (response.statusCode == 401 && needsAuth) {
        final renewed = await _handleTokenRefresh();
        if (renewed) {
          final newHeaders = _getHeaders(needsAuth: needsAuth);
          final retryResponse = await http.patch(
            Uri.parse('$baseUrl$endpoint'),
            headers: newHeaders,
            body: json.encode(data),
          );
          return _handleResponse(retryResponse);
        } else {
          throw ApiException('Sessão expirada. Faça login novamente.', 401);
        }
      }

      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erro de conexão: $e', 0);
    }
  }

  /// 📋 PROCESSAR RESPOSTA HTTP
  static Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {'success': true};
      }
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      String message = 'Erro ${response.statusCode}';

      try {
        final errorData = json.decode(response.body);

        // Priorizar userMessage (mensagem amigável) se disponível
        if (errorData['userMessage'] != null &&
            errorData['userMessage'].toString().isNotEmpty) {
          message = errorData['userMessage'];
        } else if (errorData['message'] != null) {
          message = errorData['message'];
        } else if (errorData['error'] != null) {
          message = errorData['error'];
        }

        // Se houver erros de validação, incluir detalhes
        if (errorData['errors'] != null && errorData['errors'] is List) {
          final validationErrors = errorData['errors'] as List;
          if (validationErrors.isNotEmpty) {
            final errorMessages = validationErrors
                .map((error) => error['message'] ?? 'Erro de validação')
                .join(', ');
            message =
                errorData['userMessage'] ??
                'Erros de validação: $errorMessages';
          }
        }
      } catch (e) {
        message = response.body.isNotEmpty ? response.body : message;
      }

      throw ApiException(message, response.statusCode);
    }
  }

  /// 🗑️ PROCESSAR RESPOSTA DELETE
  static void _handleDeleteResponse(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message = 'Erro ${response.statusCode}';

      try {
        final errorData = json.decode(response.body);

        // Priorizar userMessage se disponível
        if (errorData['userMessage'] != null &&
            errorData['userMessage'].toString().isNotEmpty) {
          message = errorData['userMessage'];
        } else if (errorData['message'] != null) {
          message = errorData['message'];
        } else if (errorData['error'] != null) {
          message = errorData['error'];
        }
      } catch (e) {
        message = response.body.isNotEmpty ? response.body : message;
      }

      throw ApiException(message, response.statusCode);
    }
  }
}

/// ❌ EXCEÇÃO PERSONALIZADA PARA ERROS DE API
class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => message;
}
