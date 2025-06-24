import 'package:flutter/material.dart';
import 'dart:math' as math;

class NivelProgressaoService {
  // ⚖️ SISTEMA DE PROGRESSÃO BALANCEADO

  // Configurações base do sistema de XP
  static const int XP_BASE_NIVEL = 100; // XP necessário para nível 2
  static const double MULTIPLICADOR_NIVEL = 1.5; // Crescimento por nível
  static const int NIVEL_MAXIMO = 100; // Nível máximo do sistema
  // 📊 GANHO DE XP POR ATIVIDADE (valores balanceados)
  static const Map<String, int> XP_ATIVIDADES = {
    'sessao_livre_base': 10, // XP base por sessão livre
    'sessao_agendada_base': 15, // XP base por sessão agendada
    'minuto_estudo': 2, // XP por minuto de estudo
    'questao_acertada': 5, // XP por questão acertada
    'meta_cumprida': 25, // Bonus por cumprir meta de tempo
    'pontualidade': 20, // Bonus por cumprir horário agendado
    'desempenho_excelente': 30, // Bonus por >90% de acertos
    'desempenho_bom': 15, // Bonus por >70% de acertos
    'sequencia_3_dias': 30, // Bonus sequência 3 dias
    'sequencia_7_dias': 75, // Bonus sequência 7 dias
    'sequencia_15_dias': 150, // Bonus sequência 15 dias
    'sequencia_30_dias': 300, // Bonus sequência 30 dias
    'primeira_sessao_dia': 5, // Bonus primeira sessão do dia
  };

  // 🏆 CONQUISTAS POR NÍVEL
  static const Map<int, String> CONQUISTAS_NIVEL = {
    5: 'Estudante Iniciante',
    10: 'Dedicado aos Estudos',
    15: 'Mente Focada',
    20: 'Estudante Constante',
    25: 'Mestre da Disciplina',
    30: 'Guerreiro do Conhecimento',
    35: 'Sábio Persistente',
    40: 'Lenda dos Estudos',
    50: 'Gênio Acadêmico',
    75: 'Mentor Supremo',
    100: 'Mestre Absoluto',
  };

  // 🎯 METAS DE XP POR NÍVEL
  static const Map<int, String> METAS_NIVEL = {
    1: 'Começar a jornada',
    5: 'Formar o hábito de estudar',
    10: 'Manter a consistência',
    15: 'Dominar a rotina',
    20: 'Ser um exemplo de dedicação',
    25: 'Alcançar a excelência',
    30: 'Inspirar outros estudantes',
    40: 'Tornar-se um mestre',
    50: 'Atingir o nível lendário',
  };

  /// Calcula XP necessário para um nível específico
  static int calcularXpParaNivel(int nivel) {
    if (nivel <= 1) return 0;

    double xpTotal = 0;
    for (int i = 2; i <= nivel; i++) {
      xpTotal += XP_BASE_NIVEL * math.pow(MULTIPLICADOR_NIVEL, i - 2);
    }

    return xpTotal.round();
  }

  /// Calcula nível baseado no XP total
  static int calcularNivelPorXp(int xpTotal) {
    if (xpTotal <= 0) return 1;

    int nivel = 1;
    double xpAcumulado = 0;

    while (nivel < NIVEL_MAXIMO) {
      final xpProximoNivel =
          XP_BASE_NIVEL * math.pow(MULTIPLICADOR_NIVEL, nivel - 1);

      if (xpAcumulado + xpProximoNivel > xpTotal) {
        break;
      }

      xpAcumulado += xpProximoNivel;
      nivel++;
    }

    return nivel;
  }

  /// Calcula XP necessário para o próximo nível
  static int calcularXpProximoNivel(int xpAtual) {
    final nivelAtual = calcularNivelPorXp(xpAtual);
    if (nivelAtual >= NIVEL_MAXIMO) return 0;

    final xpParaProximoNivel = calcularXpParaNivel(nivelAtual + 1);
    return xpParaProximoNivel - xpAtual;
  }

  /// Calcula progresso no nível atual (0.0 a 1.0)
  static double calcularProgressoNivel(int xpAtual) {
    final nivelAtual = calcularNivelPorXp(xpAtual);
    if (nivelAtual >= NIVEL_MAXIMO) return 1.0;

    final xpInicioNivel = calcularXpParaNivel(nivelAtual);
    final xpFimNivel = calcularXpParaNivel(nivelAtual + 1);
    final xpNoNivel = xpAtual - xpInicioNivel;
    final xpTotalNivel = xpFimNivel - xpInicioNivel;

    return (xpNoNivel / xpTotalNivel).clamp(0.0, 1.0);
  }

  /// Calcula XP ganho por sessão de estudo
  static Map<String, dynamic> calcularXpSessao({
    required Duration tempoEstudo,
    required bool isAgendada,
    required bool cumpriuMeta,
    required bool cumpriuPrazo,
    required int sequenciaDias,
    required bool isPrimeiraSessaoDia,
    int questoesAcertadas = 0,
    int totalQuestoes = 0,
  }) {
    int xpTotal = 0;
    List<String> detalhes = [];

    // XP base da sessão
    final xpBase =
        isAgendada
            ? XP_ATIVIDADES['sessao_agendada_base']!
            : XP_ATIVIDADES['sessao_livre_base']!;
    xpTotal += xpBase;
    detalhes.add(
      '${isAgendada ? "Sessão agendada" : "Sessão livre"}: +$xpBase XP',
    );

    // XP por tempo de estudo
    final minutosEstudo = tempoEstudo.inMinutes;
    final xpTempo = (minutosEstudo * XP_ATIVIDADES['minuto_estudo']!).clamp(
      0,
      120,
    ); // Máximo 60min = 120 XP
    xpTotal += xpTempo;
    detalhes.add('Tempo de estudo (${minutosEstudo}min): +$xpTempo XP');

    // XP por questões acertadas
    if (questoesAcertadas > 0) {
      final xpQuestoes = questoesAcertadas * XP_ATIVIDADES['questao_acertada']!;
      xpTotal += xpQuestoes;
      detalhes.add('Questões acertadas ($questoesAcertadas): +$xpQuestoes XP');
    }

    // Bonus por desempenho em questões
    if (totalQuestoes > 0) {
      final percentualAcerto = (questoesAcertadas / totalQuestoes);
      if (percentualAcerto >= 0.9) {
        final xpDesempenho = XP_ATIVIDADES['desempenho_excelente']!;
        xpTotal += xpDesempenho;
        detalhes.add('Desempenho excelente (≥90%): +$xpDesempenho XP');
      } else if (percentualAcerto >= 0.7) {
        final xpDesempenho = XP_ATIVIDADES['desempenho_bom']!;
        xpTotal += xpDesempenho;
        detalhes.add('Bom desempenho (≥70%): +$xpDesempenho XP');
      }
    }

    // Bonus por cumprir meta
    if (cumpriuMeta) {
      final xpMeta = XP_ATIVIDADES['meta_cumprida']!;
      xpTotal += xpMeta;
      detalhes.add('Meta cumprida: +$xpMeta XP');
    }

    // Bonus por pontualidade (sessões agendadas)
    if (isAgendada && cumpriuPrazo) {
      final xpPontualidade = XP_ATIVIDADES['pontualidade']!;
      xpTotal += xpPontualidade;
      detalhes.add('Pontualidade: +$xpPontualidade XP');
    }

    // Bonus por sequência de dias
    int xpSequencia = 0;
    if (sequenciaDias >= 30) {
      xpSequencia = XP_ATIVIDADES['sequencia_30_dias']!;
      detalhes.add('Sequência 30 dias: +$xpSequencia XP');
    } else if (sequenciaDias >= 15) {
      xpSequencia = XP_ATIVIDADES['sequencia_15_dias']!;
      detalhes.add('Sequência 15 dias: +$xpSequencia XP');
    } else if (sequenciaDias >= 7) {
      xpSequencia = XP_ATIVIDADES['sequencia_7_dias']!;
      detalhes.add('Sequência 7 dias: +$xpSequencia XP');
    } else if (sequenciaDias >= 3) {
      xpSequencia = XP_ATIVIDADES['sequencia_3_dias']!;
      detalhes.add('Sequência 3 dias: +$xpSequencia XP');
    }
    xpTotal += xpSequencia;

    // Bonus primeira sessão do dia
    if (isPrimeiraSessaoDia) {
      final xpPrimeira = XP_ATIVIDADES['primeira_sessao_dia']!;
      xpTotal += xpPrimeira;
      detalhes.add('Primeira sessão do dia: +$xpPrimeira XP');
    }

    return {'xpGanho': xpTotal, 'detalhes': detalhes};
  }

  /// Obtém conquista para um nível específico
  static String? obterConquistaNivel(int nivel) {
    return CONQUISTAS_NIVEL[nivel];
  }

  /// Obtém meta para um nível específico
  static String? obterMetaNivel(int nivel) {
    // Encontra a meta mais próxima (menor ou igual ao nível)
    int metaMaisProxima = 1;
    for (int nivelMeta in METAS_NIVEL.keys) {
      if (nivelMeta <= nivel && nivelMeta > metaMaisProxima) {
        metaMaisProxima = nivelMeta;
      }
    }
    return METAS_NIVEL[metaMaisProxima];
  }

  /// Verifica se o usuário subiu de nível
  static bool verificarSubiuNivel(int xpAnterior, int xpNovo) {
    final nivelAnterior = calcularNivelPorXp(xpAnterior);
    final nivelNovo = calcularNivelPorXp(xpNovo);
    return nivelNovo > nivelAnterior;
  }

  /// Obtém informações completas de progressão
  static Map<String, dynamic> obterInfoProgressao(int xpAtual) {
    final nivel = calcularNivelPorXp(xpAtual);
    final xpProximoNivel = calcularXpProximoNivel(xpAtual);
    final progresso = calcularProgressoNivel(xpAtual);
    final conquista = obterConquistaNivel(nivel);
    final meta = obterMetaNivel(nivel);

    return {
      'nivel': nivel,
      'xpAtual': xpAtual,
      'xpProximoNivel': xpProximoNivel,
      'progressoNivel': progresso,
      'conquista': conquista,
      'meta': meta,
      'isNivelMaximo': nivel >= NIVEL_MAXIMO,
    };
  }

  /// Obtém estatísticas de progressão para exibição
  static List<Map<String, dynamic>> obterEstatisticasProgressao(int xpAtual) {
    final info = obterInfoProgressao(xpAtual);

    return [
      {
        'titulo': 'Nível Atual',
        'valor': '${info['nivel']}',
        'icon': Icons.star,
        'cor': Colors.amber,
      },
      {
        'titulo': 'XP Total',
        'valor': '${info['xpAtual']}',
        'icon': Icons.trending_up,
        'cor': Colors.blue,
      },
      {
        'titulo': 'Progresso',
        'valor': '${(info['progressoNivel'] * 100).toInt()}%',
        'icon': Icons.show_chart,
        'cor': Colors.green,
      },
      {
        'titulo': 'Próximo Nível',
        'valor':
            info['isNivelMaximo'] ? 'MÁXIMO' : '${info['xpProximoNivel']} XP',
        'icon': Icons.flag,
        'cor': Colors.purple,
      },
    ];
  }
}
