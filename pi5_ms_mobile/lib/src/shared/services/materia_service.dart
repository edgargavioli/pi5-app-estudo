import '../models/materia_model.dart';
import 'api_service.dart';
import 'cache_service.dart';

class MateriaService {
  // Listar todas as matérias com cache
  static Future<List<Materia>> listarMaterias({
    bool forceRefresh = false,
  }) async {
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

      final materias =
          materiasJson
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

      final Map<String, dynamic> materiaJson =
          response['data'] as Map<String, dynamic>;

      return Materia.fromJson(materiaJson);
    } catch (e) {
      throw Exception('Erro ao carregar matéria: $e');
    }
  }

  // Criar nova matéria
  static Future<Materia> criarMateria(Materia materia) async {
    try {
      final response = await ApiService.post(
        '/materias',
        materia.toCreateJson(),
      );

      final Map<String, dynamic> materiaJson =
          response['data'] as Map<String, dynamic>;

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
      final response = await ApiService.put(
        '/materias/$id',
        materia.toCreateJson(),
      );

      final Map<String, dynamic> materiaJson =
          response['data'] as Map<String, dynamic>;

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

  // Buscar matérias não utilizadas
  static Future<List<Materia>> listarMateriasNaoUtilizadas({
    bool forceRefresh = false,
  }) async {
    try {
      final response = await ApiService.get('/materias/nao-utilizadas');

      final List<dynamic> materiasJson = response['data'] as List<dynamic>;

      return materiasJson
          .map((json) => Materia.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao carregar matérias não utilizadas: $e');
    }
  }

  // Buscar matérias utilizadas (vinculadas a provas)
  static Future<List<Materia>> listarMateriasUtilizadas({
    bool forceRefresh = false,
  }) async {
    try {
      final response = await ApiService.get('/materias/utilizadas');

      final List<dynamic> materiasJson = response['data'] as List<dynamic>;

      return materiasJson
          .map((json) => Materia.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao carregar matérias utilizadas: $e');
    }
  }

  // Buscar matérias por prova específica
  static Future<List<Materia>> listarMateriasPorProva(String provaId) async {
    try {
      final response = await ApiService.get('/provas/$provaId');

      final provaData = response['data'] as Map<String, dynamic>;

      // Verificar se há matérias no novo formato (múltiplas)
      if (provaData['materias'] != null && provaData['materias'] is List) {
        final List<dynamic> materiasJson =
            provaData['materias'] as List<dynamic>;
        return materiasJson
            .map((json) => Materia.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      // Fallback para compatibilidade com formato antigo (uma matéria)
      final materiaId = provaData['materiaId'] as String?;
      if (materiaId == null) {
        return [];
      }

      final materia = await buscarPorId(materiaId);
      return [materia];
    } catch (e) {
      throw Exception('Erro ao carregar matérias da prova: $e');
    }
  }

  // Desvincular matéria de prova específica
  static Future<void> desvincularMateriaDeProva(
    String provaId,
    String materiaId,
  ) async {
    try {
      await ApiService.delete('/provas/$provaId/materias/$materiaId');

      // Invalidar cache
      CacheService.invalidateRelated('materias');
      CacheService.invalidateRelated('provas');
    } catch (e) {
      throw Exception('Erro ao desvincular matéria da prova: $e');
    }
  }

  // Vincular matéria a prova
  static Future<void> vincularMateriaAProva(
    String provaId,
    String materiaId,
  ) async {
    try {
      await ApiService.post('/provas/$provaId/materias', {
        'materiaId': materiaId,
      });

      // Invalidar cache
      CacheService.invalidateRelated('materias');
      CacheService.invalidateRelated('provas');
    } catch (e) {
      throw Exception('Erro ao vincular matéria à prova: $e');
    }
  }

  // Verificar se matéria pode ser deletada (não está em uso)
  static Future<bool> podeSerDeletada(String materiaId) async {
    try {
      final response = await ApiService.get(
        '/materias/$materiaId/pode-deletar',
      );
      return response['data']['podeDeletar'] as bool;
    } catch (e) {
      // Se a rota não existir, assumir que pode deletar se não houver erro de constraint
      return true;
    }
  }

  // Adicionar matéria a uma prova (novo relacionamento many-to-many)
  static Future<void> adicionarMateriaAProva(
    String provaId,
    String materiaId,
  ) async {
    try {
      await ApiService.post('/provas/$provaId/materias', {
        'materiaId': materiaId,
      });

      // Invalidar cache
      CacheService.invalidateRelated('materias');
      CacheService.invalidateRelated('provas');
    } catch (e) {
      throw Exception('Erro ao adicionar matéria à prova: $e');
    }
  }

  // Remover matéria de uma prova (novo relacionamento many-to-many)
  static Future<void> removerMateriaDeProva(
    String provaId,
    String materiaId,
  ) async {
    try {
      await ApiService.delete('/provas/$provaId/materias/$materiaId');

      // Invalidar cache
      CacheService.invalidateRelated('materias');
      CacheService.invalidateRelated('provas');
    } catch (e) {
      throw Exception('Erro ao remover matéria da prova: $e');
    }
  }
}
