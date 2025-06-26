import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EstatisticasProvasService {
  static String get baseUrl {
    final tipoDispositivo = dotenv.env['TIPODISPOSITIVO'] ?? 'Real';

    if (tipoDispositivo == 'Emulator') {
      final baseUrlEmulator = dotenv.env['API_BASE_URL_EMULATOR'];
      return (baseUrlEmulator ?? 'http://10.0.2.2');
    } else {
      final baseUrlReal = dotenv.env['API_BASE_URL_REAL'];
      return (baseUrlReal ?? 'http://192.168.1.100');
    }
  }

  // URL do microsserviço de provas
  static final String _baseUrl = '$baseUrl:3002/api';

  /// Obtém estatísticas das provas por status
  static Future<Map<String, dynamic>> obterEstatisticasPorStatus() async {
    try {
      final authService = AuthService();
      final userId = authService.currentUser?.id;

      if (userId == null) {
        throw Exception('Usuário não encontrado');
      }
      final response = await http.get(
        Uri.parse('$_baseUrl/provas/estatisticas?userId=$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      print('🔍 Response estatísticas provas: ${response.statusCode}');
      print('🔍 Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        throw Exception(
          'Erro ao obter estatísticas das provas: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Erro no EstatisticasProvasService: $e');
      // Retornar dados padrão em caso de erro
      return {
        'total': 0,
        'pendentes': 0,
        'concluidas': 0,
        'canceladas': 0,
        'percentualConcluidas': 0.0,
        'percentualPendentes': 100.0,
        'percentualCanceladas': 0.0,
      };
    }
  }
}
