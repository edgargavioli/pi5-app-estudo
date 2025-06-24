import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'auth_service.dart';
import '../../config/api_config.dart';
import 'gamificacao_service.dart';

class GamificacaoBackendService {
  /// Processar XP de sessão no backend
  static Future<Map<String, dynamic>> processarXpSessao({
    required double
    tempoEstudoMinutos, // Alterado para double para aceitar decimais
    bool isAgendada = false,
    int? metaTempo,
    bool? cumpriuPrazo,
    int questoesAcertadas = 0,
    int totalQuestoes = 0,
    String? sessionId,
  }) async {
    try {
      final authService = AuthService();
      final token = authService.accessToken;

      if (token == null) {
        throw Exception('Token de autenticação não encontrado');
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/users/gamification/sessao'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'tempoEstudoMinutos': tempoEstudoMinutos,
          'isAgendada': isAgendada,
          'metaTempo': metaTempo,
          'cumpriuPrazo': cumpriuPrazo,
          'questoesAcertadas': questoesAcertadas,
          'totalQuestoes': totalQuestoes,
          'sessionId': sessionId,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final resultado = data['data'] ?? data;

        print('🔄 Resultado completo do backend: $resultado');

        // Mapear resultado do backend para o formato esperado
        final xpGanho = resultado['xpGanho'] ?? 0;
        final xpTotal = resultado['xpTotal'] ?? 0;
        final nivel = resultado['nivel'] ?? 1;
        final subiumLevel = resultado['subiumLevel'] ?? false;
        final xpProximoNivel = resultado['xpProximoNivel'] ?? 0; // XP que falta
        final progressoNivel = resultado['progressoNivel'] ?? 0.0;
        final detalhes = resultado['detalhes']?.cast<String>() ?? <String>[];

        print('💰 Dados mapeados:');
        print('  - XP ganho: $xpGanho');
        print('  - XP total: $xpTotal');
        print('  - Nível: $nivel');
        print('  - Subiu nível: $subiumLevel');
        print('  - XP que falta: $xpProximoNivel');
        print('  - Progresso: ${(progressoNivel * 100).toStringAsFixed(1)}%');

        return {
          'xpGanho': xpGanho, // XP real ganho na sessão
          'xpTotal': xpTotal, // XP total do usuário
          'nivel': nivel, // Nível atual
          'subiumLevel': subiumLevel, // Se subiu de nível
          'xpProximoNivel': xpProximoNivel, // XP que falta para próximo nível
          'progressoNivel':
              progressoNivel, // Progresso no nível atual (0.0 a 1.0)
          'conquista': resultado['conquista'] ?? '',
          'detalhes': detalhes, // Lista de strings com detalhamento
          'detalhamentoXp': resultado['detalhamentoXp'] ?? {},
        };
      } else {
        print('Erro ao processar XP: ${response.statusCode} ${response.body}');
        throw Exception('Falha ao processar XP no backend');
      }
    } catch (e) {
      print('Erro na chamada para backend de gamificação: $e');
      rethrow;
    }
  }

  /// Obter estatísticas de gamificação do usuário
  static Future<Map<String, dynamic>?> obterEstatisticasUsuario() async {
    try {
      final authService = AuthService();
      final token = authService.accessToken;
      final user = authService.currentUser;

      print(
        '🔍 GamificacaoBackendService - Token: ${token != null ? "presente" : "ausente"}',
      );
      print('🔍 GamificacaoBackendService - User ID: ${user?.id}');

      if (token == null || user?.id == null) {
        print('❌ Token ou User ID ausente');
        return null;
      }

      final url = '${ApiConfig.baseUrl}/users/${user!.id}';
      print('🌐 Fazendo requisição para: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 Status da resposta: ${response.statusCode}');
      print('📦 Corpo da resposta: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userData = data['data'];

        print('👤 Dados do usuário: $userData');
        print(
          '🎮 Pontos do usuário: ${userData['points']}',
        ); // Converter para formato esperado pelo frontend
        final pontos = userData['points'] ?? 0;
        final nivel = _calcularNivel(pontos);
        final xpParaProximoNivel = _calcularXPParaProximoLevel(nivel);
        final xpAtualNoNivel = _calcularXPAtualNoNivel(pontos, nivel);
        final xpTotalProximoNivel = _calcularXPTotalProximoNivel(nivel);
        final xpRestante = xpParaProximoNivel - xpAtualNoNivel;

        final result = {
          'xpTotal': pontos,
          'nivel': nivel,
          'pontosTotal': pontos,
          'xpParaProximoNivel': xpRestante.clamp(0, xpParaProximoNivel),
          'xpAtualNoNivel': xpAtualNoNivel,
          'xpTotalProximoNivel': xpTotalProximoNivel,
          'progressoNivel':
              xpTotalProximoNivel > 0
                  ? xpAtualNoNivel / xpTotalProximoNivel
                  : 1.0,
        };

        print('✅ Resultado final: $result');
        return result;
      } else {
        print(
          '❌ Erro ao obter estatísticas: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('❌ Erro ao obter estatísticas do usuário: $e');
      return null;
    }
  }

  /// Calcular nível baseado nos pontos (mesma lógica do backend)
  static int _calcularNivel(int pontos) {
    if (pontos <= 0) return 1;

    int level = 1;
    int xpNecessario = 100; // baseXP
    double multiplier = 1.5;

    while (pontos >= xpNecessario && level < 100) {
      pontos -= xpNecessario;
      level++;
      xpNecessario = (100 * pow(multiplier, level - 1)).floor();
    }

    return level;
  }

  /// Calcular XP necessário para o próximo nível
  static int _calcularXPParaProximoLevel(int nivelAtual) {
    if (nivelAtual >= 100) return 0;

    const baseXP = 100;
    const multiplier = 1.5;
    return (baseXP * pow(multiplier, nivelAtual)).floor();
  }

  /// Calcular XP atual no nível (quanto XP já foi ganho no nível atual)
  static int _calcularXPAtualNoNivel(int pontosTotal, int nivelAtual) {
    if (pontosTotal <= 0 || nivelAtual <= 1) return pontosTotal;

    // Calcular quanto XP foi gasto para chegar ao nível atual
    int xpGasto = 0;
    const baseXP = 100;
    const multiplier = 1.5;

    for (int i = 1; i < nivelAtual; i++) {
      xpGasto += (baseXP * pow(multiplier, i - 1)).floor();
    }

    return pontosTotal - xpGasto;
  }

  /// Calcular XP total necessário para o próximo nível
  static int _calcularXPTotalProximoNivel(int nivelAtual) {
    return _calcularXPParaProximoLevel(nivelAtual);
  }

  /// Sincronizar XP localmente com o backend
  static Future<void> sincronizarXpLocal(
    Map<String, dynamic> resultadoBackend,
  ) async {
    try {
      // Aqui você pode atualizar o SharedPreferences se necessário
      // para manter consistência entre sessões offline
      print('XP sincronizado: ${resultadoBackend['pontosTotal']} pontos');
    } catch (e) {
      print('Erro ao sincronizar XP local: $e');
    }
  }

  /// Obter estatísticas completas combinando dados do backend (XP real) com dados locais (sessões)
  static Future<Map<String, dynamic>?> obterEstatisticasCompletas() async {
    try {
      print('🔄 Carregando estatísticas completas (backend + local)...');

      // 1. Obter dados do backend (XP real)
      final dadosBackend = await obterEstatisticasUsuario();

      // 2. Obter dados locais (estatísticas de sessões)
      final dadosLocais = await GamificacaoService.obterEstatisticasCompletas();

      if (dadosBackend != null) {
        // Combinar: XP do backend + estatísticas locais
        final estatisticasCompletas = Map<String, dynamic>.from(dadosLocais);

        // Sobrescrever com dados reais do backend
        estatisticasCompletas['xpTotal'] = dadosBackend['xpTotal'];
        estatisticasCompletas['nivel'] = dadosBackend['nivel'];
        estatisticasCompletas['pontosTotal'] = dadosBackend['pontosTotal'];

        print(
          '✅ Estatísticas completas: XP do backend (${dadosBackend['xpTotal']}) + sessões locais',
        );
        return estatisticasCompletas;
      } else {
        // Fallback: usar apenas dados locais
        print('⚠️ Backend indisponível, usando apenas dados locais');
        return dadosLocais;
      }
    } catch (e) {
      print('❌ Erro ao obter estatísticas completas: $e');

      // Fallback: usar apenas dados locais
      try {
        return await GamificacaoService.obterEstatisticasCompletas();
      } catch (e2) {
        print('❌ Erro também nos dados locais: $e2');
        return null;
      }
    }
  }
}
