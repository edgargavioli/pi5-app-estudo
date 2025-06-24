import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pi5_ms_mobile/src/infraestructure/firebase_fcm_get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cache_service.dart';
import 'gamificacao_service.dart';
import 'streak_service.dart';
import 'estatisticas_service.dart';

class AuthService {
  // 🌐 URL DO USER-SERVICE
  static const String _userServiceUrl = 'http://10.0.2.2:3000/api';

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

  /// Getter para verificar se está autenticado
  bool get isAuthenticated => _accessToken != null && _currentUser != null;

  /// Getter para o token de acesso
  String? get accessToken => _accessToken;

  /// Getter para o token de refresh
  String? get refreshToken => _refreshToken;

  /// 🛠️ CONSTRUIR MENSAGEM DE ERRO DE VALIDAÇÃO AMIGÁVEL
  String _buildValidationErrorMessage(List<dynamic> validationErrors) {
    if (validationErrors.isEmpty) return 'Erro de validação';

    final errors = <String>[];

    for (final error in validationErrors) {
      final field = error['field'] as String?;
      final message = error['message'] as String?;

      if (field == 'email') {
        errors.add('Email inválido');
      } else if (field == 'password') {
        if (message?.contains('8 characters') == true) {
          errors.add('Senha deve ter pelo menos 8 caracteres');
        } else if (message?.contains('uppercase') == true ||
            message?.contains('lowercase') == true ||
            message?.contains('number') == true ||
            message?.contains('special') == true) {
          errors.add(
            'Senha deve conter letra maiúscula, minúscula, número e símbolo especial',
          );
        } else {
          errors.add('Senha inválida');
        }
      } else if (field == 'name') {
        errors.add('Nome deve ter pelo menos 2 caracteres');
      } else {
        errors.add(message ?? 'Campo inválido');
      }
    }

    return errors.join(', ');
  }

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
        } else {
          // 📱 VERIFICAR E ATUALIZAR FCM TOKEN NA INICIALIZAÇÃO
          await _checkAndUpdateFcmToken();
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
        body: json.encode({'email': email, 'password': password}),
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
        await prefs.setString(
          _userDataKey,
          json.encode(_currentUser!.toJson()),
        ); // 📱 VERIFICAR E ATUALIZAR FCM TOKEN APÓS LOGIN
        await _checkAndUpdateFcmToken(); // 🗂️ LIMPAR DADOS LOCAIS ANTIGOS DE GAMIFICAÇÃO
        await _limparDadosLocaisGamificacao();

        // 🎯 SINCRONIZAR DADOS COM BACKEND APÓS LOGIN
        try {
          EstatisticasService.sincronizarComBackend();
        } catch (e) {
          print('❌ Erro ao sincronizar após login: $e');
        }

        return AuthResult.success(
          message: 'Login realizado com sucesso',
          user: _currentUser!,
        );
      } else {
        final error = json.decode(response.body);

        // Priorizar userMessage se disponível, senão usar message
        String errorMessage =
            error['userMessage'] ?? error['message'] ?? 'Falha ao fazer login';

        return AuthResult.error(errorMessage);
      }
    } catch (e) {
      print('❌ Erro no login: $e');
      return AuthResult.error('Erro inesperado ao fazer login');
    }
  }

  /// 📝 REGISTRO
  Future<AuthResult> register(
    String name,
    String email,
    String password,
  ) async {
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
          'fcmToken': await getToken(),
        }),
      );

      print(response.body);

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
        await prefs.setString(
          _userDataKey,
          json.encode(_currentUser!.toJson()),
        ); // 📱 SALVAR FCM TOKEN APÓS REGISTRO (já foi enviado no registro)
        final fcmToken = await getToken();
        if (fcmToken != null) {
          await saveCurrentFcmToken(fcmToken);
        }

        // 🗂️ LIMPAR DADOS LOCAIS ANTIGOS DE GAMIFICAÇÃO
        await _limparDadosLocaisGamificacao();

        return AuthResult.success(
          message: 'Registro realizado com sucesso',
          user: AuthUser.fromJson(data['data']['user']),
        );
      } else {
        final error = json.decode(response.body);

        // Priorizar userMessage se disponível, senão usar message
        String errorMessage =
            error['userMessage'] ??
            error['message'] ??
            'Falha ao fazer registro';

        // Se houver detalhes de validação, incluir informações específicas
        if (error['errors'] != null && error['errors'] is List) {
          final validationErrors = error['errors'] as List;
          if (validationErrors.isNotEmpty) {
            errorMessage =
                error['userMessage'] ??
                _buildValidationErrorMessage(validationErrors);
          }
        }

        return AuthResult.error(errorMessage);
      }
    } catch (e) {
      print('❌ Erro no registro: $e');
      return AuthResult.error('Erro inesperado ao fazer registro');
    }
  }

  /// 🗂️ Limpa dados locais de gamificação ao fazer login com novo usuário
  Future<void> _limparDadosLocaisGamificacao() async {
    try {
      await GamificacaoService.limparDadosLocais();
      await StreakService.limparCache();
      await EstatisticasService.limparDadosLocais();
    } catch (e) {
      print('Erro ao limpar dados locais de gamificação: $e');
    }
  }

  /// 📱 VERIFICAR E ATUALIZAR FCM TOKEN (função centralizada)
  Future<void> _checkAndUpdateFcmToken() async {
    try {
      print('🔍 Iniciando verificação de FCM token...');

      // Verificar se usuário está autenticado
      if (!isAuthenticated) {
        print('📱 Usuário não está logado, pulando verificação de FCM token');
        return;
      }

      print('✅ Usuário autenticado: ${_currentUser?.id}');

      // Obter FCM token atual do Firebase
      final currentFcmToken = await getToken();
      print('📱 FCM Token atual: ${currentFcmToken?.substring(0, 20)}...');

      if (currentFcmToken != null) {
        // Verificar se o token mudou comparando com o token salvo
        final tokenChanged = await hasTokenChanged(currentFcmToken);
        print('🔄 Token mudou: $tokenChanged');

        if (tokenChanged) {
          print('📱 FCM Token mudou, atualizando no servidor...');
          print('🌐 URL: $_userServiceUrl/users/${_currentUser!.id}/fcm-token');
          print('🔑 Token de acesso disponível: ${_accessToken != null}');

          // Atualizar token no microserviço de usuário via PATCH
          await updateFcmTokenPatch(currentFcmToken);

          // Salvar novo token localmente para futuras comparações
          await saveCurrentFcmToken(currentFcmToken);

          print('✅ FCM Token atualizado com sucesso!');
        } else {
          print('📱 FCM Token não mudou, nenhuma atualização necessária');
        }
      } else {
        print('⚠️ Não foi possível obter FCM token do Firebase');
      }
    } catch (e) {
      print('⚠️ Erro ao verificar/atualizar FCM Token: $e');
      print('📊 Stack trace: ${StackTrace.current}');
      // Não falhar o processo por causa disso
    }
  }

  /// 🚪 LOGOUT
  Future<void> logout() async {
    try {
      // Limpar dados locais
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_accessTokenKey);
      await prefs.remove(_refreshTokenKey);
      await prefs.remove(_userDataKey); // Limpar estado
      _accessToken = null;
      _refreshToken = null;
      _currentUser = null;

      // Limpar cache
      CacheService.clear();

      // Limpar dados de gamificação e streak
      await _limparDadosLocaisGamificacao();
    } catch (e) {
      print('❌ Erro ao fazer logout: $e');
      rethrow;
    }
  }

  /// 🔄 RENOVAR TOKENS DE AUTENTICAÇÃO
  Future<bool> refreshTokens() async {
    try {
      if (_refreshToken == null) {
        return false;
      }

      final response = await http.post(
        Uri.parse('$_userServiceUrl/auth/refresh-token'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'refreshToken': _refreshToken}),
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
      } else {
        // Refresh token inválido, fazer logout
        await logout();
        return false;
      }
    } catch (e) {
      print('❌ Erro ao renovar tokens: $e');
      await logout();
      return false;
    }
  }

  /// 🔍 VALIDAR SE TOKEN AINDA É VÁLIDO
  Future<bool> _validateToken() async {
    try {
      if (_accessToken == null) return false;

      final response = await http.get(
        Uri.parse('$_userServiceUrl/auth/validate'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_accessToken',
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

  /// Verifica se o FCM token mudou comparando com o token salvo
  Future<bool> hasTokenChanged(String currentToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString('fcm_token');

      // Se não há token salvo ou se o token atual é diferente do salvo
      return savedToken == null || savedToken != currentToken;
    } catch (e) {
      print('Erro ao verificar mudança de FCM token: $e');
      return true; // Em caso de erro, assumir que mudou para tentar atualizar
    }
  }

  /// Salva o FCM token atual localmente para futuras comparações
  Future<void> saveCurrentFcmToken(String fcmToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', fcmToken);
    } catch (e) {
      print('Erro ao salvar FCM token: $e');
    }
  }

  /// Atualiza FCM token usando PATCH request para a nova rota específica
  Future<void> updateFcmTokenPatch(String fcmToken) async {
    try {
      print('🚀 Iniciando PATCH do FCM token...');

      if (_currentUser?.id == null) {
        throw Exception('Usuário não está logado - ID não disponível');
      }

      if (_accessToken == null) {
        throw Exception('Token de acesso não disponível');
      }

      final url = '$_userServiceUrl/users/${_currentUser!.id}/fcm-token';
      print('🌐 URL do PATCH: $url');
      print(
        '🔑 Authorization header: Bearer ${_accessToken!.substring(0, 20)}...',
      );

      final requestBody = json.encode({'fcmToken': fcmToken});
      print('📦 Request body: $requestBody');

      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
        body: requestBody,
      );

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ FCM token atualizado via PATCH com sucesso');

        // Atualizar token no usuário local também
        if (_currentUser != null) {
          _currentUser = _currentUser!.copyWith(fcmToken: fcmToken);
          await _saveUserData(_currentUser!);
          print('💾 Dados do usuário atualizados localmente');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          'Erro HTTP ${response.statusCode}: ${errorData['message'] ?? 'Erro desconhecido'}',
        );
      }
    } catch (e) {
      print('❌ Erro ao atualizar FCM token via PATCH: $e');
      rethrow;
    }
  }

  /// Método legado - manter para compatibilidade, mas usar o PATCH quando possível
  Future<void> updateFcmToken(String fcmToken) async {
    try {
      final response = await http.put(
        Uri.parse('$_userServiceUrl/users/fcm-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
        body: json.encode({'fcmToken': fcmToken}),
      );

      if (response.statusCode != 200) {
        throw Exception('Erro ao atualizar FCM token');
      }
    } catch (e) {
      print('Erro ao atualizar FCM token: $e');
      rethrow;
    }
  }

  /// Salva dados do usuário localmente
  Future<void> _saveUserData(AuthUser user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userDataKey, json.encode(user.toJson()));
    } catch (e) {
      print('Erro ao salvar dados do usuário: $e');
    }
  }
}

/// 👤 MODELO DE USUÁRIO PARA AUTENTICAÇÃO
class AuthUser {
  final String id;
  final String? nome;
  final String? email;
  final String? fcmToken;
  final bool isEmailVerified;
  final DateTime? lastLogin;

  AuthUser({
    required this.id,
    this.nome,
    this.email,
    this.fcmToken,
    this.isEmailVerified = false,
    this.lastLogin,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'],
      nome: json['name'],
      email: json['email'],
      fcmToken: json['fcmToken'],
      isEmailVerified: json['isEmailVerified'] ?? false,
      lastLogin:
          json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': nome,
      'email': email,
      'fcmToken': fcmToken,
      'isEmailVerified': isEmailVerified,
      'lastLogin': lastLogin?.toIso8601String(),
    };
  }

  /// Cria uma cópia do usuário com campos opcionalmente atualizados
  AuthUser copyWith({
    String? id,
    String? nome,
    String? email,
    String? fcmToken,
    bool? isEmailVerified,
    DateTime? lastLogin,
  }) {
    return AuthUser(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      fcmToken: fcmToken ?? this.fcmToken,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}

/// 📋 RESULTADO DE OPERAÇÃO DE AUTENTICAÇÃO
class AuthResult {
  final bool success;
  final String message;
  final AuthUser? user;

  AuthResult.success({required this.user, required this.message})
    : success = true;

  AuthResult.error(this.message) : success = false, user = null;
}
