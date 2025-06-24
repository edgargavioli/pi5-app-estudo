import '../models/evento_model.dart';
import 'api_service.dart';
import 'estatisticas_service.dart';

class SessaoService {
  // Listar todas as sessões de estudo
  static Future<List<SessaoEstudo>> listarSessoes() async {
    try {
      final response = await ApiService.get('/sessoes');

      final List<dynamic> sessoesJson = response['data'] as List<dynamic>;

      return sessoesJson
          .map((json) => SessaoEstudo.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao carregar sessões: $e');
    }
  }

  // Buscar sessão por ID
  static Future<SessaoEstudo> buscarPorId(String id) async {
    try {
      final response = await ApiService.get('/sessoes/$id');

      final Map<String, dynamic> sessaoJson =
          response['data'] as Map<String, dynamic>;

      return SessaoEstudo.fromJson(sessaoJson);
    } catch (e) {
      throw Exception('Erro ao carregar sessão: $e');
    }
  }

  // Criar nova sessão de estudo
  static Future<SessaoEstudo> criarSessao(SessaoEstudo sessao) async {
    try {
      final response = await ApiService.post('/sessoes', sessao.toCreateJson());

      final Map<String, dynamic> sessaoJson =
          response['data'] as Map<String, dynamic>;

      return SessaoEstudo.fromJson(sessaoJson);
    } catch (e) {
      throw Exception('Erro ao criar sessão: $e');
    }
  } // Atualizar sessão de estudo

  static Future<SessaoEstudo> atualizarSessao(
    String id,
    SessaoEstudo sessao,
  ) async {
    try {
      final response = await ApiService.put(
        '/sessoes/$id',
        sessao.toCreateJson(),
      );

      final Map<String, dynamic> sessaoJson =
          response['data'] as Map<String, dynamic>;

      return SessaoEstudo.fromJson(sessaoJson);
    } catch (e) {
      throw Exception('Erro ao atualizar sessão: $e');
    }
  }

  // Deletar sessão de estudo
  static Future<void> deletarSessao(String id) async {
    try {
      await ApiService.delete('/sessoes/$id');
    } catch (e) {
      throw Exception('Erro ao deletar sessão: $e');
    }
  }

  // Listar sessões por matéria
  static Future<List<SessaoEstudo>> listarSessoesPorMateria(
    String materiaId,
  ) async {
    try {
      final response = await ApiService.get('/sessoes?materiaId=$materiaId');

      final List<dynamic> sessoesJson = response['data'] as List<dynamic>;

      return sessoesJson
          .map((json) => SessaoEstudo.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao carregar sessões da matéria: $e');
    }
  }

  // Listar sessões por prova
  static Future<List<SessaoEstudo>> listarSessoesPorProva(
    String provaId,
  ) async {
    try {
      final response = await ApiService.get('/sessoes?provaId=$provaId');

      final List<dynamic> sessoesJson = response['data'] as List<dynamic>;

      return sessoesJson
          .map((json) => SessaoEstudo.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao carregar sessões da prova: $e');
    }
  }

  // Listar sessões em uma data específica
  static Future<List<SessaoEstudo>> listarSessoesPorData(DateTime data) async {
    try {
      final dataFormatada = data.toIso8601String().split('T')[0]; // YYYY-MM-DD
      final response = await ApiService.get('/sessoes?data=$dataFormatada');

      final List<dynamic> sessoesJson = response['data'] as List<dynamic>;

      return sessoesJson
          .map((json) => SessaoEstudo.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao carregar sessões da data: $e');
    }
  }

  /// Finaliza uma sessão de estudo, calcula XP e mostra feedback
  static Future<Map<String, int>> finalizarSessao(SessaoEstudo sessao) async {
    try {
      // Atualizar a sessão com horário de fim
      final sessaoFinalizada = SessaoEstudo(
        id: sessao.id,
        conteudo: sessao.conteudo,
        topicos: sessao.topicos,
        materiaId: sessao.materiaId,
        provaId: sessao.provaId,
        tempoInicio: sessao.tempoInicio,
        tempoFim: DateTime.now(),
        createdAt: sessao.createdAt,
        updatedAt: DateTime.now(),
        eventoId: sessao.eventoId,
        isAgendada: sessao.isAgendada,
        cumpriuPrazo: sessao.cumpriuPrazo,
        horarioAgendado: sessao.horarioAgendado,
        questoesAcertadas: sessao.questoesAcertadas,
        totalQuestoes: sessao.totalQuestoes,
      );

      // Atualizar no backend
      await atualizarSessao(sessao.id, sessaoFinalizada);

      // Calcular tempo de estudo
      final tempoEstudo = DateTime.now().difference(
        sessao.tempoInicio ?? DateTime.now(),
      );

      // Determinar se cumpriu prazo para sessões agendadas
      bool? cumpriuPrazo;
      if (sessao.isAgendada == true && sessao.horarioAgendado != null) {
        final agora = DateTime.now();
        final prazoLimite = sessao.horarioAgendado!.add(
          const Duration(hours: 2),
        ); // 2h de tolerância
        cumpriuPrazo = agora.isBefore(prazoLimite);
      } // Atualizar estatísticas e calcular XP
      final estatisticas =
          await EstatisticasService.atualizarEstatisticasBalanceado(
            tempoEstudo,
            isAgendada: sessao.isAgendada,
            cumpriuPrazo: cumpriuPrazo,
          );

      // Converter para o formato esperado pelo código legado
      return {
        'sequencia': estatisticas['sequencia'] ?? 0,
        'nivel': estatisticas['nivel'] ?? 1,
        'xp': estatisticas['xpTotal'] ?? 0,
        'melhorTempo': tempoEstudo.inSeconds,
        'xpProximoNivel': estatisticas['xpParaProximoNivel'] ?? 100,
      };
    } catch (e) {
      throw Exception('Erro ao finalizar sessão: $e');
    }
  }

  /// Finaliza uma sessão com questões respondidas/acertadas
  static Future<void> finalizarSessaoComQuestoes(
    String sessaoId, {
    int questoesAcertadas = 0,
    int totalQuestoes = 0,
  }) async {
    try {
      await ApiService.post('/sessoes/$sessaoId/finalizar', {
        'questoesAcertadas': questoesAcertadas,
        'totalQuestoes': totalQuestoes,
      });
    } catch (e) {
      throw Exception('Erro ao finalizar sessão: $e');
    }
  }

  /// Cria e finaliza uma sessão não programada (para estudos livres)
  static Future<SessaoEstudo> criarEFinalizarSessaoLivre({
    required String materiaId,
    String? provaId,
    required String conteudo,
    required List<String> topicos,
    required DateTime tempoInicio,
    required DateTime tempoFim,
    int questoesAcertadas = 0,
    int totalQuestoes = 0,
  }) async {
    try {
      // Criar a sessão já finalizada
      final sessaoData = {
        'materiaId': materiaId,
        'provaId': provaId,
        'conteudo': conteudo,
        'topicos': topicos,
        'tempoInicio': tempoInicio.toIso8601String(),
        'tempoFim': tempoFim.toIso8601String(),
        'finalizada': true,
        'questoesAcertadas': questoesAcertadas,
        'totalQuestoes': totalQuestoes,
        'isAgendada': false,
      };

      final response = await ApiService.post('/sessoes', sessaoData);
      final sessaoJson = response['data'] as Map<String, dynamic>;
      return SessaoEstudo.fromJson(sessaoJson);
    } catch (e) {
      throw Exception('Erro ao criar sessão livre: $e');
    }
  }
}
