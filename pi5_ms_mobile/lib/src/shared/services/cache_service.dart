import '../models/materia_model.dart';
import '../models/prova_model.dart';

/// Serviço de cache simples para melhorar performance
class CacheService {
  static final Map<String, dynamic> _cache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};

  // Duração do cache (5 minutos)
  static const Duration _cacheDuration = Duration(minutes: 5);

  /// Verifica se um item do cache ainda é válido
  static bool _isCacheValid(String key) {
    final timestamp = _cacheTimestamps[key];
    if (timestamp == null) return false;

    return DateTime.now().difference(timestamp) < _cacheDuration;
  }

  /// Salva dados no cache
  static void set<T>(String key, T data) {
    _cache[key] = data;
    _cacheTimestamps[key] = DateTime.now();
  }

  /// Recupera dados do cache
  static T? get<T>(String key) {
    if (!_isCacheValid(key)) {
      remove(key);
      return null;
    }

    return _cache[key] as T?;
  }

  /// Remove um item do cache
  static void remove(String key) {
    _cache.remove(key);
    _cacheTimestamps.remove(key);
  }

  /// Limpa todo o cache
  static void clear() {
    _cache.clear();
    _cacheTimestamps.clear();
  }

  /// Cache específico para matérias
  static void setMaterias(List<Materia> materias) {
    set('materias', materias);
  }

  static List<Materia>? getMaterias() {
    return get<List<Materia>>('materias');
  }

  /// Cache específico para provas
  static void setProvas(List<Prova> provas) {
    set('provas', provas);
  }

  static List<Prova>? getProvas() {
    return get<List<Prova>>('provas');
  }

  /// Invalida cache relacionado a uma entidade específica
  static void invalidateRelated(String entity) {
    switch (entity.toLowerCase()) {
      case 'materia':
      case 'materias':
        remove('materias');
        remove('cronograma');
        break;
      case 'prova':
      case 'provas':
        remove('provas');
        remove('cronograma');
        break;
      case 'sessao':
      case 'sessoes':
        remove('sessoes');
        remove('cronograma');
        break;
    }
  }
}
