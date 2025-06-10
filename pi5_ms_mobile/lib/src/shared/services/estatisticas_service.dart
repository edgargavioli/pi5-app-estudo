import 'package:shared_preferences/shared_preferences.dart';

class EstatisticasService {
  static const String _keySequencia = 'sequencia_estudos';
  static const String _keyNivel = 'nivel_usuario';
  static const String _keyXP = 'xp_usuario';
  static const String _keyUltimaSessao = 'ultima_sessao';
  static const String _keyMelhorTempo = 'melhor_tempo';

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

  // Atualizar estatísticas após uma sessão de estudo
  static Future<Map<String, int>> atualizarEstatisticas(Duration tempoEstudo) async {
    try {
      final prefs = await SharedPreferences.getInstance();
    
      // Verificar se estudou hoje
      final ultimaSessaoStr = prefs.getString(_keyUltimaSessao);
      final hoje = DateTime.now();
      final estudouHoje = ultimaSessaoStr != null && 
          DateTime.parse(ultimaSessaoStr).day == hoje.day &&
          DateTime.parse(ultimaSessaoStr).month == hoje.month &&
          DateTime.parse(ultimaSessaoStr).year == hoje.year;

      // Atualizar sequência
      int sequencia = await obterSequencia();
      if (!estudouHoje) {
        // Verificar se estudou ontem para manter a sequência
        final ontem = hoje.subtract(const Duration(days: 1));
        final estudouOntem = ultimaSessaoStr != null && 
            DateTime.parse(ultimaSessaoStr).day == ontem.day &&
            DateTime.parse(ultimaSessaoStr).month == ontem.month &&
            DateTime.parse(ultimaSessaoStr).year == ontem.year;
        
        if (estudouOntem || ultimaSessaoStr == null) {
          sequencia += 1;
        } else {
          sequencia = 1; // Reiniciar sequência
        }
        
        await prefs.setInt(_keySequencia, sequencia);
        await prefs.setString(_keyUltimaSessao, hoje.toIso8601String());
      }

      // Calcular XP ganho baseado no tempo de estudo
      final minutosEstudo = tempoEstudo.inMinutes;
      int xpGanho = (minutosEstudo * 2).clamp(10, 200);
      
      // Bonus por sequência
      if (sequencia >= 7) {
        xpGanho = (xpGanho * 1.5).round();
      } else if (sequencia >= 3) {
        xpGanho = (xpGanho * 1.2).round();
      }

      // Atualizar XP total
      int xpTotal = await obterXP();
      xpTotal += xpGanho;
      await prefs.setInt(_keyXP, xpTotal);

      // Calcular nível baseado no XP
      int nivel = (xpTotal / 1000).floor() + 1;
      await prefs.setInt(_keyNivel, nivel);

      // Atualizar melhor tempo se necessário
      final melhorTempo = await obterMelhorTempo();
      if (tempoEstudo > melhorTempo) {
        await prefs.setInt(_keyMelhorTempo, tempoEstudo.inSeconds);
      }

      return {
        'sequencia': sequencia,
        'nivel': nivel,
        'xpGanho': xpGanho,
        'xpTotal': xpTotal,
      };
    } catch (e) {
      print('Erro ao atualizar estatísticas: $e');
      return {
        'sequencia': 0,
        'nivel': 1,
        'xpGanho': 0,
        'xpTotal': 0,
      };
    }
  }

  // Obter estatísticas completas
  static Future<Map<String, dynamic>> obterEstatisticasCompletas() async {
    final sequencia = await obterSequencia();
    final nivel = await obterNivel();
    final xp = await obterXP();
    final melhorTempo = await obterMelhorTempo();

    return {
      'sequencia': sequencia,
      'nivel': nivel,
      'xp': xp,
      'melhorTempo': melhorTempo,
      'xpProximoNivel': (nivel * 1000) - xp,
    };
  }
} 