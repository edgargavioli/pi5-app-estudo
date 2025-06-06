import '../models/prova_model.dart';
import 'api_service.dart';
import 'cache_service.dart';

class ProvaService {
  
  // Listar todas as provas com cache
  static Future<List<Prova>> listarProvas({bool forceRefresh = false}) async {
    // Verificar cache primeiro (se não for refresh forçado)
    if (!forceRefresh) {
      final cachedProvas = CacheService.getProvas();
      if (cachedProvas != null) {
        return cachedProvas;
      }
    }

    try {
      final response = await ApiService.get('/provas');
      
      final List<dynamic> provasJson = response['data'] as List<dynamic>;
      
      final provas = provasJson
          .map((json) => Prova.fromJson(json as Map<String, dynamic>))
          .toList();
      
      // Salvar no cache
      CacheService.setProvas(provas);
      
      return provas;
    } catch (e) {
      // Se houver erro e temos cache, retornar cache
      final cachedProvas = CacheService.getProvas();
      if (cachedProvas != null) {
        return cachedProvas;
      }
      
      throw Exception('Erro ao carregar provas: $e');
    }
  }

  // Buscar prova por ID
  static Future<Prova> buscarPorId(String id) async {
    try {
      final response = await ApiService.get('/provas/$id');
      
      final Map<String, dynamic> provaJson = response['data'] as Map<String, dynamic>;
      
      return Prova.fromJson(provaJson);
    } catch (e) {
      throw Exception('Erro ao carregar prova: $e');
    }
  }

  // Criar nova prova
  static Future<Prova> criarProva(Prova prova) async {
    try {
      final response = await ApiService.post('/provas', prova.toCreateJson());
      
      final Map<String, dynamic> provaJson = response['data'] as Map<String, dynamic>;
      
      // Invalidar cache
      CacheService.invalidateRelated('provas');
      
      return Prova.fromJson(provaJson);
    } catch (e) {
      throw Exception('Erro ao criar prova: $e');
    }
  }

  // Atualizar prova
  static Future<Prova> atualizarProva(String id, Prova prova) async {
    try {
      final response = await ApiService.put('/provas/$id', prova.toCreateJson());
      
      final Map<String, dynamic> provaJson = response['data'] as Map<String, dynamic>;
      
      // Invalidar cache
      CacheService.invalidateRelated('provas');
      
      return Prova.fromJson(provaJson);
    } catch (e) {
      throw Exception('Erro ao atualizar prova: $e');
    }
  }

  // Deletar prova
  static Future<void> deletarProva(String id) async {
    try {
      await ApiService.delete('/provas/$id');
      
      // Invalidar cache
      CacheService.invalidateRelated('provas');
    } catch (e) {
      throw Exception('Erro ao deletar prova: $e');
    }
  }

  // Registrar resultado da prova
  static Future<Prova> registrarResultado(String id, int acertos) async {
    try {
      final response = await ApiService.patch('/provas/$id/resultado', {
        'acertos': acertos,
      });
      
      final Map<String, dynamic> provaJson = response['data'] as Map<String, dynamic>;
      
      // Invalidar cache
      CacheService.invalidateRelated('provas');
      
      return Prova.fromJson(provaJson);
    } catch (e) {
      throw Exception('Erro ao registrar resultado: $e');
    }
  }
} 