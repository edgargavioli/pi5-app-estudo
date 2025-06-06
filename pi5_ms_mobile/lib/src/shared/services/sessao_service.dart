import '../models/evento_model.dart';
import 'api_service.dart';

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
      
      final Map<String, dynamic> sessaoJson = response['data'] as Map<String, dynamic>;
      
      return SessaoEstudo.fromJson(sessaoJson);
    } catch (e) {
      throw Exception('Erro ao carregar sessão: $e');
    }
  }

  // Criar nova sessão de estudo
  static Future<SessaoEstudo> criarSessao(SessaoEstudo sessao) async {
    try {
      final response = await ApiService.post('/sessoes', sessao.toCreateJson());
      
      final Map<String, dynamic> sessaoJson = response['data'] as Map<String, dynamic>;
      
      return SessaoEstudo.fromJson(sessaoJson);
    } catch (e) {
      throw Exception('Erro ao criar sessão: $e');
    }
  }

  // Atualizar sessão de estudo
  static Future<SessaoEstudo> atualizarSessao(String id, SessaoEstudo sessao) async {
    try {
      final response = await ApiService.put('/sessoes/$id', sessao.toCreateJson());
      
      final Map<String, dynamic> sessaoJson = response['data'] as Map<String, dynamic>;
      
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
  static Future<List<SessaoEstudo>> listarSessoesPorMateria(String materiaId) async {
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
  static Future<List<SessaoEstudo>> listarSessoesPorProva(String provaId) async {
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
} 