import '../models/prova_model.dart';
import 'api_service.dart';
import 'cache_service.dart';

class MateriaService {
  
  // Listar todas as matérias com cache
  static Future<List<Materia>> listarMaterias({bool forceRefresh = false}) async {
    // Verificar cache primeiro (se não for refresh forçado)
    if (!forceRefresh) {
      final cachedMaterias = CacheService.getMaterias();
      if (cachedMaterias != null) {
        return cachedMaterias;
      }
    }

    try {
      final response = await ApiService.get('/materias');
      
      final List<dynamic> materiasJson = response['data'] as List<dynamic>;
      
      final materias = materiasJson
          .map((json) => Materia.fromJson(json as Map<String, dynamic>))
          .toList();
      
      // Salvar no cache
      CacheService.setMaterias(materias);
      
      return materias;
    } catch (e) {
      // Se houver erro e temos cache, retornar cache
      final cachedMaterias = CacheService.getMaterias();
      if (cachedMaterias != null) {
        return cachedMaterias;
      }
      
      throw Exception('Erro ao carregar matérias: $e');
    }
  }

  // Buscar matéria por ID
  static Future<Materia> buscarPorId(String id) async {
    try {
      final response = await ApiService.get('/materias/$id');
      
      final Map<String, dynamic> materiaJson = response['data'] as Map<String, dynamic>;
      
      return Materia.fromJson(materiaJson);
    } catch (e) {
      throw Exception('Erro ao carregar matéria: $e');
    }
  }

  // Criar nova matéria
  static Future<Materia> criarMateria(Materia materia) async {
    try {
      final response = await ApiService.post('/materias', materia.toCreateJson());
      
      final Map<String, dynamic> materiaJson = response['data'] as Map<String, dynamic>;
      
      // Invalidar cache
      CacheService.invalidateRelated('materias');
      
      return Materia.fromJson(materiaJson);
    } catch (e) {
      throw Exception('Erro ao criar matéria: $e');
    }
  }

  // Atualizar matéria
  static Future<Materia> atualizarMateria(String id, Materia materia) async {
    try {
      final response = await ApiService.put('/materias/$id', materia.toCreateJson());
      
      final Map<String, dynamic> materiaJson = response['data'] as Map<String, dynamic>;
      
      // Invalidar cache
      CacheService.invalidateRelated('materias');
      
      return Materia.fromJson(materiaJson);
    } catch (e) {
      throw Exception('Erro ao atualizar matéria: $e');
    }
  }

  // Deletar matéria
  static Future<void> deletarMateria(String id) async {
    try {
      await ApiService.delete('/materias/$id');
      
      // Invalidar cache
      CacheService.invalidateRelated('materias');
    } catch (e) {
      throw Exception('Erro ao deletar matéria: $e');
    }
  }
} 