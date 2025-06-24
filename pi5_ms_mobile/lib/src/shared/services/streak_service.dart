import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pi5_ms_mobile/src/shared/services/auth_service.dart';

class StreakService {
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  // Modelo de dados do streak
  static Map<String, dynamic> _currentStreak = {};

  /// Obter informações da sequência atual
  static Future<Map<String, dynamic>> obterStreak() async {
    try {
      final authService = AuthService();
      final userId = authService.currentUser?.id;

      if (userId == null) {
        throw Exception('Usuário não autenticado');
      }

      final token = authService.accessToken;
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId/streak'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _currentStreak = data['data'] ?? {};

        // Salvar cache local
        await _saveToCache(_currentStreak);

        return _currentStreak;
      } else if (response.statusCode == 404) {
        // Usuário não tem streak ainda, retornar dados padrão
        _currentStreak = {
          'currentStreak': 0,
          'longestStreak': 0,
          'isActivatedToday': false,
          'studiedToday': 0,
          'targetMinutes': 1,
          'needsToStudy': true,
        };
        return _currentStreak;
      } else {
        throw Exception('Erro ao obter streak: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao obter streak: $e');
      // Retornar cache local se houver erro
      return await _loadFromCache();
    }
  }
  /// Atualizar streak com tempo estudado
  static Future<Map<String, dynamic>> atualizarStreak(
    double minutosEstudados, {
    String? timezone,
  }) async {
    try {
      final authService = AuthService();
      final userId = authService.currentUser?.id;

      if (userId == null) {
        throw Exception('Usuário não autenticado');
      }

      final token = authService.accessToken;
      final body = {
        'studyMinutes': minutosEstudados,
        'timezone': timezone ?? 'America/Sao_Paulo',
      };

      print('🔥 Atualizando streak com dados: $body');
      print('🔥 URL: $baseUrl/users/$userId/streak');

      final response = await http.put(
        Uri.parse('$baseUrl/users/$userId/streak'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      print('🔥 Response status: ${response.statusCode}');
      print('🔥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final streakData = data['data'] ?? {};

        // Atualizar cache local
        _currentStreak = {
          'currentStreak': streakData['currentStreak'] ?? 0,
          'longestStreak': streakData['longestStreak'] ?? 0,
          'isActivatedToday': streakData['isActivatedToday'] ?? false,
          'studiedToday': streakData['studiedToday'] ?? 0,
          'targetMinutes': 1,
          'needsToStudy': !streakData['isActivatedToday'],
        };

        await _saveToCache(_currentStreak);

        return {
          'success': true,
          'activated': streakData['activated'] ?? false,
          'currentStreak': streakData['currentStreak'] ?? 0,
          'newAchievements': streakData['newAchievements'] ?? [],
          'streakData': _currentStreak,
        };
      } else {
        throw Exception('Erro ao atualizar streak: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao atualizar streak: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Obter conquistas de streak
  static Future<List<Map<String, dynamic>>> obterConquistas() async {
    try {
      final authService = AuthService();
      final userId = authService.currentUser?.id;

      if (userId == null) {
        throw Exception('Usuário não autenticado');
      }

      final token = authService.accessToken;
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId/streak/achievements'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      } else {
        throw Exception('Erro ao obter conquistas: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao obter conquistas: $e');
      return [];
    }
  }

  /// Verificar se o usuário ativou a sequência hoje
  static bool get isActivatedToday =>
      _currentStreak['isActivatedToday'] ?? false;

  /// Obter sequência atual
  static int get currentStreak => _currentStreak['currentStreak'] ?? 0;

  /// Obter maior sequência
  static int get longestStreak => _currentStreak['longestStreak'] ?? 0;

  /// Verificar se ainda precisa estudar hoje
  static bool get needsToStudy => _currentStreak['needsToStudy'] ?? true;

  /// Obter minutos estudados hoje
  static int get studiedToday => _currentStreak['studiedToday'] ?? 0;

  /// Obter meta em minutos
  static int get targetMinutes => _currentStreak['targetMinutes'] ?? 1;

  /// Obter dados completos do streak (cache local)
  static Map<String, dynamic> get streakData =>
      Map<String, dynamic>.from(_currentStreak);

  // Métodos auxiliares para cache
  static Future<void> _saveToCache(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = json.encode(data);
      await prefs.setString('streak_cache', jsonString);
      await prefs.setInt(
        'streak_cache_timestamp',
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      print('Erro ao salvar cache do streak: $e');
    }
  }

  static Future<Map<String, dynamic>> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('streak_cache');
      final timestamp = prefs.getInt('streak_cache_timestamp') ?? 0;

      // Verificar se o cache não é muito antigo (máximo 1 hora)
      final now = DateTime.now().millisecondsSinceEpoch;
      final oneHour = 60 * 60 * 1000;

      if (jsonString != null && (now - timestamp) < oneHour) {
        return Map<String, dynamic>.from(json.decode(jsonString));
      }
    } catch (e) {
      print('Erro ao carregar cache do streak: $e');
    }

    // Retornar dados padrão se não conseguir carregar cache
    return {
      'currentStreak': 0,
      'longestStreak': 0,
      'isActivatedToday': false,
      'studiedToday': 0,
      'targetMinutes': 1,
      'needsToStudy': true,
    };
  }

  /// Inicializar o serviço (carregar dados)
  static Future<void> inicializar() async {
    try {
      // Tentar carregar do backend primeiro
      await obterStreak();
    } catch (e) {
      // Se falhar, carregar do cache
      _currentStreak = await _loadFromCache();
    }
  }

  /// Limpar cache (útil para logout)
  static Future<void> limparCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('streak_cache');
      await prefs.remove('streak_cache_timestamp');
      _currentStreak = {};
    } catch (e) {
      print('Erro ao limpar cache do streak: $e');
    }
  }
}
