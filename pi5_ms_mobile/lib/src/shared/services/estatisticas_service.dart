import 'package:shared_preferences/shared_preferences.dart';
import 'gamificacao_backend_service.dart';
import 'auth_service.dart';
import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;

class EstatisticasService {
  static const String _keySequencia = 'sequencia_estudos';
  static const String _keyNivel = 'nivel_usuario';
  static const String _keyXP = 'xp_usuario';
  static const String _keyUltimaSessao = 'ultima_sessao';
  static const String _keyMelhorTempo = 'melhor_tempo';
  static const String _keyUltimaSincronizacao = 'ultima_sincronizacao';

  /// Sincronizar dados com o backend (chamar na inicialização do app)
  static Future<void> sincronizarComBackend() async {
    try {
      print('🔄 Sincronizando dados locais com backend...');

      final dadosBackend =
          await GamificacaoBackendService.obterEstatisticasUsuario();

      if (dadosBackend != null) {
        final prefs = await SharedPreferences.getInstance();

        // Atualizar dados locais com dados reais do backend
        await prefs.setInt(_keyXP, dadosBackend['xpTotal'] ?? 0);
        await prefs.setInt(_keyNivel, dadosBackend['nivel'] ?? 1);
        await prefs.setString(
          _keyUltimaSincronizacao,
          DateTime.now().toIso8601String(),
        );

        print(
          '✅ Sincronização concluída: XP=${dadosBackend['xpTotal']}, Nível=${dadosBackend['nivel']}',
        );
      }
    } catch (e) {
      print('❌ Erro na sincronização com backend: $e');
    }
  }

  /// Verificar se precisa sincronizar (chama automaticamente se necessário)
  static Future<void> verificarESincronizar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ultimaSincStr = prefs.getString(_keyUltimaSincronizacao);

      if (ultimaSincStr == null) {
        // Nunca sincronizou
        await sincronizarComBackend();
        return;
      }

      final ultimaSync = DateTime.parse(ultimaSincStr);
      final agora = DateTime.now();
      final diferenca = agora.difference(ultimaSync);

      // Sincronizar se passou mais de 5 minutos
      if (diferenca.inMinutes > 5) {
        await sincronizarComBackend();
      }
    } catch (e) {
      print('❌ Erro ao verificar sincronização: $e');
    }
  }

  // Obter sequência atual de estudos
  static Future<int> obterSequencia() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_keySequencia) ?? 0;
    } catch (e) {
      print('Erro ao obter sequência: $e');
      return 0;
    }
  }

  // Obter nível atual do usuário
  static Future<int> obterNivel() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_keyNivel) ?? 1;
    } catch (e) {
      print('Erro ao obter nível: $e');
      return 1;
    }
  }

  // Obter XP atual do usuário
  static Future<int> obterXP() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_keyXP) ?? 0;
    } catch (e) {
      print('Erro ao obter XP: $e');
      return 0;
    }
  }

  // Obter melhor tempo de estudo
  static Future<Duration> obterMelhorTempo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final segundos = prefs.getInt(_keyMelhorTempo) ?? 0;
      return Duration(seconds: segundos);
    } catch (e) {
      print('Erro ao obter melhor tempo: $e');
      return Duration.zero;
    }
  }

  /// Método principal para processar sessão de estudo
  static Future<Map<String, dynamic>> atualizarEstatisticasBalanceado(
    Duration tempoEstudo, {
    bool isAgendada = false,
    int? metaTempo,
    bool? cumpriuPrazo,
    String? sessionId,
    int questoesAcertadas = 0,
    int totalQuestoes = 0,
  }) async {
    try {
      print('🎮 Processando sessão de estudo...');
      print('⏱️ Tempo: ${tempoEstudo.inMinutes}min, Agendada: $isAgendada');
      print('🎯 Questões: $questoesAcertadas/$totalQuestoes');

      // 1. OBTER DADOS LOCAIS ATUAIS
      final prefs = await SharedPreferences.getInstance();
      final xpAnterior = await obterXP();
      final nivelAnterior = await obterNivel();

      print('📊 Estado anterior: XP=$xpAnterior, Nível=$nivelAnterior');

      // 2. ATUALIZAR STREAK LOCAL
      await _atualizarStreakLocal();

      // 3. CALCULAR XP LOCALMENTE (para feedback imediato)
      final resultadoXpLocal = _calcularXpSessaoLocal(
        tempoEstudo: tempoEstudo,
        isAgendada: isAgendada,
        metaTempo: metaTempo,
        cumpriuPrazo: cumpriuPrazo,
        questoesAcertadas: questoesAcertadas,
        totalQuestoes: totalQuestoes,
      );

      final xpGanhoLocal = resultadoXpLocal['xpGanho'] as int;
      final xpNovoLocal = xpAnterior + xpGanhoLocal;
      final nivelNovoLocal = _calcularNivel(xpNovoLocal);
      final subiumNivel = nivelNovoLocal > nivelAnterior;

      // 4. SALVAR LOCALMENTE (para feedback imediato)
      await prefs.setInt(_keyXP, xpNovoLocal);
      await prefs.setInt(_keyNivel, nivelNovoLocal);

      print(
        '🎯 Resultado local: XP ganho=$xpGanhoLocal, XP total=$xpNovoLocal, Nível=$nivelNovoLocal',
      ); // 5. ENVIAR PARA BACKEND (async, não bloqueia feedback)
      final resultadoBackend = await _processarNoBackendSync(
        tempoEstudo: tempoEstudo,
        isAgendada: isAgendada,
        metaTempo: metaTempo,
        cumpriuPrazo: cumpriuPrazo,
        questoesAcertadas: questoesAcertadas,
        totalQuestoes: totalQuestoes,
        sessionId: sessionId,
      );
      if (resultadoBackend != null) {
        // Usar dados do backend se disponível
        print('🔄 Usando dados do backend: $resultadoBackend');

        // Atualizar dados locais com os do backend
        await prefs.setInt(_keyXP, resultadoBackend['xpTotal']);
        await prefs.setInt(_keyNivel, resultadoBackend['nivel']);
        return {
          'sequencia': await obterSequencia(),
          'nivel': resultadoBackend['nivel'],
          'xpGanho': resultadoBackend['xpGanho'],
          'xpTotal': resultadoBackend['xpTotal'],
          'xpParaProximoNivel':
              resultadoBackend['xpProximoNivel'], // Usar o campo correto do backend
          'progressoNivel': resultadoBackend['progressoNivel'],
          'subiumLevel': resultadoBackend['subiumLevel'],
          'conquista':
              resultadoBackend['subiumLevel']
                  ? 'Subiu para o nível ${resultadoBackend['nivel']}!'
                  : '',
          'detalhamentoXp': resultadoBackend['detalhes'] ?? [],
          'motivoXP':
              isAgendada
                  ? 'Sessão agendada concluída'
                  : 'Sessão de estudo concluída',
          'cumpriuPrazo': cumpriuPrazo,
        };
      }

      // 6. FALLBACK: Usar dados locais se backend falhar
      print('⚠️ Backend falhou, usando dados locais para feedback');

      // 6. RETORNAR RESULTADO PARA FEEDBACK IMEDIATO
      final resultado = {
        'sequencia': await obterSequencia(),
        'nivel': nivelNovoLocal,
        'xpGanho': xpGanhoLocal,
        'xpTotal': xpNovoLocal,
        'xpParaProximoNivel': _calcularXpParaProximoNivel(nivelNovoLocal),
        'progressoNivel': _calcularProgressoNivel(xpNovoLocal, nivelNovoLocal),
        'subiumLevel': subiumNivel,
        'conquista': subiumNivel ? 'Subiu para o nível $nivelNovoLocal!' : '',
        'detalhamentoXp': resultadoXpLocal['detalhes'] as List<String>,
        'motivoXP':
            isAgendada
                ? 'Sessão agendada concluída'
                : 'Sessão de estudo concluída',
        'cumpriuPrazo': cumpriuPrazo,
      };

      print('✅ Resultado final: $resultado');
      return resultado;
    } catch (e) {
      print('❌ Erro ao processar sessão: $e');
      return _resultadoErroFallback();
    }
  }

  /// Processar no backend de forma síncrona (para obter resultado imediato)
  static Future<Map<String, dynamic>?> _processarNoBackendSync({
    required Duration tempoEstudo,
    required bool isAgendada,
    int? metaTempo,
    bool? cumpriuPrazo,
    required int questoesAcertadas,
    required int totalQuestoes,
    String? sessionId,
  }) async {
    try {
      print('🌐 Enviando dados para backend de forma síncrona...');
      final resultadoBackend =
          await GamificacaoBackendService.processarXpSessao(
            tempoEstudoMinutos:
                tempoEstudo.inSeconds /
                60.0, // Converter segundos para minutos com decimais
            isAgendada: isAgendada,
            metaTempo: metaTempo,
            cumpriuPrazo: cumpriuPrazo,
            questoesAcertadas: questoesAcertadas,
            totalQuestoes: totalQuestoes,
            sessionId: sessionId,
          );

      print('📡 Backend processado: $resultadoBackend');
      return resultadoBackend;
    } catch (e) {
      print('❌ Erro ao processar no backend: $e');
      return null;
    }
  }

  /// Atualizar streak local
  static Future<void> _atualizarStreakLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ultimaSessaoStr = prefs.getString(_keyUltimaSessao);
      final hoje = DateTime.now();

      final estudouHoje =
          ultimaSessaoStr != null &&
          DateTime.parse(ultimaSessaoStr).day == hoje.day &&
          DateTime.parse(ultimaSessaoStr).month == hoje.month &&
          DateTime.parse(ultimaSessaoStr).year == hoje.year;

      if (!estudouHoje) {
        int sequencia = await obterSequencia();

        final ontem = hoje.subtract(const Duration(days: 1));
        final estudouOntem =
            ultimaSessaoStr != null &&
            DateTime.parse(ultimaSessaoStr).day == ontem.day &&
            DateTime.parse(ultimaSessaoStr).month == ontem.month &&
            DateTime.parse(ultimaSessaoStr).year == ontem.year;

        if (estudouOntem || ultimaSessaoStr == null) {
          sequencia += 1;
        } else {
          sequencia = 1;
        }

        await prefs.setInt(_keySequencia, sequencia);
        await prefs.setString(_keyUltimaSessao, hoje.toIso8601String());

        print('📅 Streak atualizada: $sequencia dias');
      }
    } catch (e) {
      print('❌ Erro ao atualizar streak: $e');
    }
  }

  /// Calcular XP de uma sessão localmente
  static Map<String, dynamic> _calcularXpSessaoLocal({
    required Duration tempoEstudo,
    required bool isAgendada,
    int? metaTempo,
    bool? cumpriuPrazo,
    required int questoesAcertadas,
    required int totalQuestoes,
  }) {
    final minutos = tempoEstudo.inMinutes;
    int xpBase = 5; // XP base por finalizar sessão
    int xpTempo = (minutos * 1.5).round(); // 1.5 XP por minuto
    int xpQuestoes = questoesAcertadas * 3; // 3 XP por questão certa

    List<String> detalhes = [
      'Sessão finalizada: +$xpBase XP',
      'Tempo de estudo ($minutos min): +$xpTempo XP',
    ];

    if (questoesAcertadas > 0) {
      detalhes.add('Questões corretas ($questoesAcertadas): +$xpQuestoes XP');
    }

    int xpTotal = xpBase + xpTempo + xpQuestoes;

    // Bônus para sessões agendadas
    if (isAgendada) {
      if (cumpriuPrazo == true) {
        int bonus = (xpTotal * 0.5).round();
        xpTotal += bonus;
        detalhes.add('Bônus agendada no prazo: +$bonus XP');
      } else if (cumpriuPrazo == false) {
        int penalidade = (xpTotal * 0.2).round();
        xpTotal -= penalidade;
        detalhes.add('Penalidade atraso: -$penalidade XP');
      }
    }

    return {'xpGanho': xpTotal, 'detalhes': detalhes};
  }

  /// Calcular nível baseado no XP (mesma lógica do backend)
  static int _calcularNivel(int xp) {
    if (xp <= 0) return 1;

    int level = 1;
    int xpNecessario = 100; // baseXP
    const double multiplier = 1.5;

    while (xp >= xpNecessario && level < 100) {
      xp -= xpNecessario;
      level++;
      xpNecessario = (100 * pow(multiplier, level - 1)).floor();
    }

    return level;
  }

  /// Calcular XP necessário para o próximo nível
  static int _calcularXpParaProximoNivel(int nivelAtual) {
    if (nivelAtual >= 100) return 0;

    const baseXP = 100;
    const multiplier = 1.5;
    return (baseXP * pow(multiplier, nivelAtual)).floor();
  }

  /// Calcular progresso no nível atual
  static double _calcularProgressoNivel(int xpTotal, int nivelAtual) {
    if (nivelAtual >= 100) return 1.0;

    // Calcular XP gasto para chegar ao nível atual
    int xpGasto = 0;
    const baseXP = 100;
    const multiplier = 1.5;

    for (int i = 1; i < nivelAtual; i++) {
      xpGasto += (baseXP * pow(multiplier, i - 1)).floor();
    }

    final xpAtualNoNivel = xpTotal - xpGasto;
    final xpTotalProximoNivel = _calcularXpParaProximoNivel(nivelAtual);

    if (xpTotalProximoNivel <= 0) return 1.0;

    return (xpAtualNoNivel / xpTotalProximoNivel).clamp(0.0, 1.0);
  }

  /// Resultado de fallback em caso de erro
  static Map<String, dynamic> _resultadoErroFallback() {
    return {
      'sequencia': 0,
      'nivel': 1,
      'xpGanho': 0,
      'xpTotal': 0,
      'xpParaProximoNivel': 100,
      'progressoNivel': 0.0,
      'subiumLevel': false,
      'conquista': '',
      'detalhamentoXp': ['Erro ao processar sessão'],
      'motivoXP': 'Erro ao processar sessão',
      'cumpriuPrazo': null,
    };
  }

  /// Limpar dados locais (útil para logout/login com novo usuário)
  static Future<void> limparDadosLocais() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keySequencia);
      await prefs.remove(_keyNivel);
      await prefs.remove(_keyXP);
      await prefs.remove(_keyUltimaSessao);
      await prefs.remove(_keyMelhorTempo);
      await prefs.remove(_keyUltimaSincronizacao);
      print('✅ Dados locais de estatísticas limpos');
    } catch (e) {
      print('❌ Erro ao limpar dados locais de estatísticas: $e');
    }
  }

  /// Obter estatísticas de sessões de estudo do backend
  static Future<Map<String, dynamic>?> obterEstatisticasSessoes({
    String? provaId,
  }) async {
    try {
      final authService = AuthService();
      final token = authService.accessToken;
      if (token == null) {
        print('❌ Token não encontrado para buscar estatísticas');
        return null;
      }
      const baseUrl = 'http://10.0.2.2:3001'; // URL do microsserviço de provas
      var url = '$baseUrl/sessoes/estatisticas';

      if (provaId != null) {
        url += '?provaId=$provaId';
      }

      print('🔍 Buscando estatísticas de sessões: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('📊 Resposta estatísticas: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true && data['data'] != null) {
          print('✅ Estatísticas de sessões obtidas com sucesso');
          return data['data'] as Map<String, dynamic>;
        } else {
          print('❌ Resposta de estatísticas inválida: $data');
          return null;
        }
      } else {
        print(
          '❌ Erro ao buscar estatísticas: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('❌ Erro ao obter estatísticas de sessões: $e');
      return null;
    }
  }

  /// Obter estatísticas específicas de uma prova
  static Future<Map<String, dynamic>?> obterEstatisticasProva(
    String provaId,
  ) async {
    final estatisticas = await obterEstatisticasSessoes(provaId: provaId);

    if (estatisticas != null) {
      return {
        'tempoTotalMinutos':
            estatisticas['tempoTotalEstudado']?['minutos'] ?? 0,
        'tempoTotalFormatado':
            estatisticas['tempoTotalEstudado']?['formatado'] ?? '0min',
        'totalSessoes': estatisticas['sessoes']?['total'] ?? 0,
        'totalQuestoes': estatisticas['questoes']?['total'] ?? 0,
        'questoesAcertadas': estatisticas['questoes']?['acertadas'] ?? 0,
        'desempenho': estatisticas['questoes']?['desempenho'] ?? 0.0,
      };
    }

    return null;
  }

  /// Obter estatísticas gerais de todas as provas
  static Future<Map<String, dynamic>?> obterEstatisticasGerais() async {
    final estatisticas = await obterEstatisticasSessoes();

    print('🔍 Raw estatísticas recebidas: $estatisticas');

    if (estatisticas != null) {
      // A API agora retorna a estrutura nova do use case
      final resultado = {
        'geral': {
          'tempoTotalMinutos':
              estatisticas['tempoTotalEstudado']?['minutos'] ?? 0,
          'tempoTotalFormatado':
              estatisticas['tempoTotalEstudado']?['formatado'] ?? '0min',
          'totalSessoes': estatisticas['sessoes']?['total'] ?? 0,
          'totalQuestoes': estatisticas['questoes']?['total'] ?? 0,
          'questoesAcertadas': estatisticas['questoes']?['acertadas'] ?? 0,
          'desempenho': estatisticas['questoes']?['desempenho'] ?? 0.0,
        },
      };
      print('📊 Resultado processado: $resultado');
      return resultado;
    }

    return null;
  }
}
