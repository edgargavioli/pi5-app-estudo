import 'dart:developer';
import '../models/evento_model.dart';
import 'api_service.dart';

class EventoService {
  static const String baseUrl = '/eventos';

  static Future<List<Evento>> listarEventos() async {
    try {
      final data = await ApiService.get(baseUrl);
      final List<dynamic> eventos = data['data'] ?? [];
      return eventos.map((evento) => Evento.fromJson(evento)).toList();
    } catch (e) {
      log('Erro no EventoService.listarEventos: $e');
      throw Exception('Erro ao carregar eventos: $e');
    }
  }

  static Future<Evento> obterEvento(String id) async {
    try {
      final data = await ApiService.get('$baseUrl/$id');
      return Evento.fromJson(data['data']);
    } catch (e) {
      log('Erro no EventoService.obterEvento: $e');
      throw Exception('Erro ao carregar evento: $e');
    }
  }

  static Future<Evento> criarEvento(Map<String, Object?> eventoData) async {
    try {
      final data = await ApiService.post(baseUrl, eventoData);
      return Evento.fromJson(data['data']);
    } catch (e) {
      log('Erro no EventoService.criarEvento: $e');
      throw Exception('Erro ao criar evento: $e');
    }
  }

  static Future<Evento> atualizarEvento(
    String id,
    Map<String, Object?> eventoData,
  ) async {
    try {
      final data = await ApiService.put('$baseUrl/$id', eventoData);
      return Evento.fromJson(data['data']);
    } catch (e) {
      log('Erro no EventoService.atualizarEvento: $e');
      throw Exception('Erro ao atualizar evento: $e');
    }
  }

  static Future<bool> deletarEvento(String id) async {
    try {
      await ApiService.delete('$baseUrl/$id');
      return true;
    } catch (e) {
      log('Erro no EventoService.deletarEvento: $e');
      throw Exception('Erro ao deletar evento: $e');
    }
  }

  static Future<List<Evento>> obterEventosDoMes(DateTime data) async {
    try {
      // Por enquanto, usar a lista completa e filtrar localmente
      final eventos = await listarEventos();
      final primeiroDoMes = DateTime(data.year, data.month, 1);
      final ultimoDoMes = DateTime(data.year, data.month + 1, 0);

      return eventos.where((evento) {
        return evento.data.isAfter(
              primeiroDoMes.subtract(const Duration(days: 1)),
            ) &&
            evento.data.isBefore(ultimoDoMes.add(const Duration(days: 1)));
      }).toList();
    } catch (e) {
      log('Erro no EventoService.obterEventosDoMes: $e');
      throw Exception('Erro ao carregar eventos do mês: $e');
    }
  }

  static Future<List<Evento>> obterEventosDoDia(DateTime data) async {
    try {
      final eventos = await listarEventos();
      return eventos.where((evento) {
        return evento.data.year == data.year &&
            evento.data.month == data.month &&
            evento.data.day == data.day;
      }).toList();
    } catch (e) {
      log('Erro no EventoService.obterEventosDoDia: $e');
      throw Exception('Erro ao carregar eventos do dia: $e');
    }
  }

  static Future<List<Evento>> obterProximosEventos({int dias = 30}) async {
    try {
      final eventos = await listarEventos();
      final agora = DateTime.now();
      final limite = agora.add(Duration(days: dias));

      return eventos
          .where(
            (evento) =>
                evento.data.isAfter(agora) && evento.data.isBefore(limite),
          )
          .toList()
        ..sort((a, b) => a.data.compareTo(b.data));
    } catch (e) {
      log('Erro no EventoService.obterProximosEventos: $e');
      throw Exception('Erro ao carregar próximos eventos: $e');
    }
  }
}
