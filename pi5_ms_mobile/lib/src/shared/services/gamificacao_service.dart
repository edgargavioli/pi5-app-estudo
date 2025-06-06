import 'package:shared_preferences/shared_preferences.dart';
import 'sessao_service.dart';
import 'prova_service.dart';
import 'dart:math';

class GamificacaoService {
  static const String _keyXpTotal = 'xp_total';
  static const String _keyNivelAtual = 'nivel_atual';
  static const String _keyTotalSessoes = 'total_sessoes';
  static const String _keyTotalMinutos = 'total_minutos_estudo';
  static const String _keyTotalQuestoes = 'total_questoes_acertadas';
  
  // ======== REGRAS DE GAMIFICAÇÃO ========
  
  // XP por atividade
  static const int XP_POR_SESSAO_CRIADA = 10;
  static const int XP_POR_SESSAO_FINALIZADA = 25;
  static const int XP_POR_MINUTO_ESTUDO = 2;
  static const int XP_POR_QUESTAO_ACERTADA = 5;
  static const int XP_BONUS_PROVA_FINALIZADA = 50;
  
  // Sistema de níveis (XP necessário para cada nível)
  static const int XP_BASE_POR_NIVEL = 100;
  static const double MULTIPLICADOR_NIVEL = 1.15;
  
  // Bônus por desempenho
  static const Map<int, int> BONUS_DESEMPENHO = {
    90: 30,  // 90%+ = 30 XP extra
    80: 20,  // 80-89% = 20 XP extra  
    70: 10,  // 70-79% = 10 XP extra
    60: 5,   // 60-69% = 5 XP extra
  };
  
  // ======== MÉTODOS PRINCIPAIS ========
  
  /// Calcula XP total baseado em todas as atividades do usuário
  static Future<int> calcularXpTotal() async {
    try {
      final sessoes = await SessaoService.listarSessoes();
      final provas = await ProvaService.listarProvas();
      
      int xpTotal = 0;
      
      // XP por sessões de estudo
      for (final sessao in sessoes) {
        // XP por criar sessão
        xpTotal += XP_POR_SESSAO_CRIADA;
        
        // XP por finalizar sessão
        if (sessao.tempoFim != null) {
          xpTotal += XP_POR_SESSAO_FINALIZADA;
          
          // XP por tempo de estudo
          if (sessao.tempoInicio != null) {
            final duracao = sessao.tempoFim!.difference(sessao.tempoInicio!);
            final minutos = duracao.inMinutes;
            xpTotal += minutos * XP_POR_MINUTO_ESTUDO;
          }
        }
      }
      
      // XP por provas realizadas
      for (final prova in provas) {
        if (prova.foiRealizada && prova.acertos != null) {
          // XP por questões acertadas
          xpTotal += prova.acertos! * XP_POR_QUESTAO_ACERTADA;
          
          // XP por finalizar prova
          xpTotal += XP_BONUS_PROVA_FINALIZADA;
          
          // Bônus por desempenho
          if (prova.percentualAcerto != null) {
            final bonus = _calcularBonusDesempenho(prova.percentualAcerto!);
            xpTotal += bonus;
          }
        }
      }
      
      // Salvar XP total calculado
      await _salvarXpTotal(xpTotal);
      
      return xpTotal;
    } catch (e) {
      print('Erro ao calcular XP total: $e');
      return await _obterXpSalvo();
    }
  }
  
  /// Calcula nível baseado no XP total
  static Future<int> calcularNivel() async {
    final xpTotal = await calcularXpTotal();
    return _nivelPorXp(xpTotal);
  }
  
  /// Calcula progresso atual no nível (0.0 a 1.0)
  static Future<double> calcularProgressoNivel() async {
    final xpTotal = await calcularXpTotal();
    final nivelAtual = _nivelPorXp(xpTotal);
    final xpNivelAtual = _xpNecessarioParaNivel(nivelAtual);
    final xpProximoNivel = _xpNecessarioParaNivel(nivelAtual + 1);
    
    if (xpTotal <= xpNivelAtual) return 0.0;
    
    final progressoAtual = xpTotal - xpNivelAtual;
    final progressoNecessario = xpProximoNivel - xpNivelAtual;
    
    return (progressoAtual / progressoNecessario).clamp(0.0, 1.0);
  }
  
  /// XP necessário para próximo nível
  static Future<int> calcularXpParaProximoNivel() async {
    final xpTotal = await calcularXpTotal();
    final nivelAtual = _nivelPorXp(xpTotal);
    final xpProximoNivel = _xpNecessarioParaNivel(nivelAtual + 1);
    
    return (xpProximoNivel - xpTotal).clamp(0, double.infinity).toInt();
  }
  
  /// Obtém estatísticas completas de gamificação
  static Future<Map<String, dynamic>> obterEstatisticasCompletas() async {
    try {
      final sessoes = await SessaoService.listarSessoes();
      final provas = await ProvaService.listarProvas();
      
      // Contadores gerais
      final totalSessoes = sessoes.length;
      final sessoesFinalizadas = sessoes.where((s) => s.tempoFim != null).length;
      final provasRealizadas = provas.where((p) => p.foiRealizada).length;
      
      // Tempo total de estudo
      Duration tempoTotal = Duration.zero;
      for (final sessao in sessoes) {
        if (sessao.tempoInicio != null && sessao.tempoFim != null) {
          tempoTotal += sessao.tempoFim!.difference(sessao.tempoInicio!);
        }
      }
      
      // Questões acertadas
      int totalQuestoes = 0;
      int totalAcertos = 0;
      for (final prova in provas) {
        if (prova.foiRealizada && prova.totalQuestoes != null && prova.acertos != null) {
          totalQuestoes += prova.totalQuestoes!;
          totalAcertos += prova.acertos!;
        }
      }
      
      // Desempenho médio
      double desempenhoMedio = 0.0;
      final provasComResultado = provas.where((p) => p.percentualAcerto != null).toList();
      if (provasComResultado.isNotEmpty) {
        final somaPercentuais = provasComResultado.fold<double>(
          0.0, (sum, prova) => sum + prova.percentualAcerto!
        );
        desempenhoMedio = somaPercentuais / provasComResultado.length;
      }
      
      // Gamificação
      final xpTotal = await calcularXpTotal();
      final nivel = await calcularNivel();
      final progressoNivel = await calcularProgressoNivel();
      final xpParaProximo = await calcularXpParaProximoNivel();
      
      return {
        // Estatísticas gerais
        'totalSessoes': totalSessoes,
        'sessoesFinalizadas': sessoesFinalizadas,
        'provasRealizadas': provasRealizadas,
        'tempoTotalMinutos': tempoTotal.inMinutes,
        'tempoTotalFormatado': _formatarDuracao(tempoTotal),
        'totalQuestoes': totalQuestoes,
        'totalAcertos': totalAcertos,
        'desempenhoMedio': desempenhoMedio,
        
        // Gamificação
        'xpTotal': xpTotal,
        'nivel': nivel,
        'progressoNivel': progressoNivel,
        'xpParaProximoNivel': xpParaProximo,
        'progressoNivelPercentual': (progressoNivel * 100).round(),
        
        // Meta dados
        'ultimaAtualizacao': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('Erro ao obter estatísticas completas: $e');
      return _obterEstatisticasPadrao();
    }
  }
  
  /// Adiciona XP manualmente (para eventos especiais)
  static Future<bool> adicionarXp(int xp, String motivo) async {
    try {
      final xpAtual = await _obterXpSalvo();
      final novoXp = xpAtual + xp;
      await _salvarXpTotal(novoXp);
      
      print('XP adicionado: +$xp ($motivo). Total: $novoXp');
      return true;
    } catch (e) {
      print('Erro ao adicionar XP: $e');
      return false;
    }
  }
  
  // ======== MÉTODOS AUXILIARES ========
  
  /// Calcula nível baseado no XP
  static int _nivelPorXp(int xp) {
    if (xp <= 0) return 1;
    
    int nivel = 1;
    int xpNecessario = 0;
    
    while (xp >= xpNecessario) {
      nivel++;
      xpNecessario = _xpNecessarioParaNivel(nivel);
    }
    
    return nivel - 1; // Retorna o último nível alcançado
  }
  
  /// Calcula XP necessário para um nível específico
  static int _xpNecessarioParaNivel(int nivel) {
    if (nivel <= 1) return 0;
    
    int xpTotal = 0;
    for (int i = 2; i <= nivel; i++) {
      final xpNivel = (XP_BASE_POR_NIVEL * pow(MULTIPLICADOR_NIVEL, i - 2)).round();
      xpTotal += xpNivel;
    }
    
    return xpTotal;
  }
  
  /// Calcula bônus de XP baseado no desempenho
  static int _calcularBonusDesempenho(int percentual) {
    for (final entry in BONUS_DESEMPENHO.entries) {
      if (percentual >= entry.key) {
        return entry.value;
      }
    }
    return 0;
  }
  
  /// Formata duração em texto legível
  static String _formatarDuracao(Duration duracao) {
    final horas = duracao.inHours;
    final minutos = duracao.inMinutes.remainder(60);
    
    if (horas > 0) {
      return '${horas}h ${minutos}min';
    } else {
      return '${minutos}min';
    }
  }
  
  /// Salva XP total no armazenamento local
  static Future<void> _salvarXpTotal(int xp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyXpTotal, xp);
  }

  /// Limpa todos os dados de gamificação salvos localmente
  static Future<void> limparDadosLocais() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyXpTotal);
      await prefs.remove(_keyNivelAtual);
      await prefs.remove(_keyTotalSessoes);
      await prefs.remove(_keyTotalMinutos);
      await prefs.remove(_keyTotalQuestoes);
      print('Dados de gamificação limpos com sucesso');
    } catch (e) {
      print('Erro ao limpar dados de gamificação: $e');
    }
  }
  
  /// Obtém XP salvo do armazenamento local
  static Future<int> _obterXpSalvo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_keyXpTotal) ?? 0;
    } catch (e) {
      print('Erro ao obter XP salvo: $e');
      return 0;
    }
  }
  
  /// Retorna estatísticas padrão em caso de erro
  static Map<String, dynamic> _obterEstatisticasPadrao() {
    return {
      'totalSessoes': 0,
      'sessoesFinalizadas': 0,
      'provasRealizadas': 0,
      'tempoTotalMinutos': 0,
      'tempoTotalFormatado': '0min',
      'totalQuestoes': 0,
      'totalAcertos': 0,
      'desempenhoMedio': 0.0,
      'xpTotal': 0,
      'nivel': 1,
      'progressoNivel': 0.0,
      'xpParaProximoNivel': XP_BASE_POR_NIVEL,
      'progressoNivelPercentual': 0,
      'ultimaAtualizacao': DateTime.now().toIso8601String(),
    };
  }
} 