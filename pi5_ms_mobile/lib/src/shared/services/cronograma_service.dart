import '../models/prova_model.dart';
import '../models/evento_model.dart';
import 'prova_service.dart';
import 'sessao_service.dart';
import 'evento_service.dart';

class CronogramaService {
  // Obter todos os eventos de um dia específico
  static Future<Map<String, dynamic>> obterEventosDoDia(DateTime data) async {
    try {
      final provas = await _obterProvasDoDia(data);
      final sessoes = await _obterSessoesDoDia(data);
      final eventos = await _obterEventosDoDia(data);

      return {
        'provas': provas,
        'sessoes': sessoes,
        'eventos': eventos,
        'total': provas.length + sessoes.length + eventos.length,
      };
    } catch (e) {
      throw Exception('Erro ao carregar eventos do dia: $e');
    }
  }

  // Obter eventos de um mês inteiro para o calendário
  static Future<Map<DateTime, List<dynamic>>> obterEventosDoMes(
    DateTime data,
  ) async {
    try {
      final primeiroDoMes = DateTime(data.year, data.month, 1);
      final ultimoDoMes = DateTime(data.year, data.month + 1, 0);

      final Map<DateTime, List<dynamic>> eventos = {};

      // Buscar provas do mês
      final provas = await ProvaService.listarProvas();
      for (final prova in provas) {
        final dataProva = DateTime(
          prova.data.year,
          prova.data.month,
          prova.data.day,
        );
        if (dataProva.isAfter(primeiroDoMes.subtract(Duration(days: 1))) &&
            dataProva.isBefore(ultimoDoMes.add(Duration(days: 1)))) {
          eventos[dataProva] = (eventos[dataProva] ?? [])..add(prova);
        }
      }
      // Buscar sessões do mês (iniciadas E agendadas)
      final sessoes = await SessaoService.listarSessoes();
      for (final sessao in sessoes) {
        DateTime? dataSessao;

        // Para sessões agendadas, usar horarioAgendado
        if (sessao.isAgendada && sessao.horarioAgendado != null) {
          dataSessao = DateTime(
            sessao.horarioAgendado!.year,
            sessao.horarioAgendado!.month,
            sessao.horarioAgendado!.day,
          );
        }
        // Para sessões já iniciadas, usar tempoInicio
        else if (sessao.tempoInicio != null) {
          dataSessao = DateTime(
            sessao.tempoInicio!.year,
            sessao.tempoInicio!.month,
            sessao.tempoInicio!.day,
          );
        }

        if (dataSessao != null &&
            dataSessao.isAfter(primeiroDoMes.subtract(Duration(days: 1))) &&
            dataSessao.isBefore(ultimoDoMes.add(Duration(days: 1)))) {
          eventos[dataSessao] = (eventos[dataSessao] ?? [])..add(sessao);
        }
      }

      // Buscar eventos do mês
      final eventosLista = await EventoService.listarEventos();
      for (final evento in eventosLista) {
        final dataEvento = DateTime(
          evento.data.year,
          evento.data.month,
          evento.data.day,
        );
        if (dataEvento.isAfter(primeiroDoMes.subtract(Duration(days: 1))) &&
            dataEvento.isBefore(ultimoDoMes.add(Duration(days: 1)))) {
          eventos[dataEvento] = (eventos[dataEvento] ?? [])..add(evento);
        }
      }

      return eventos;
    } catch (e) {
      throw Exception('Erro ao carregar eventos do mês: $e');
    }
  }

  // Obter próximas provas (próximos 30 dias)
  static Future<List<Prova>> obterProximasProvas({int dias = 30}) async {
    try {
      final todasProvas = await ProvaService.listarProvas();
      final agora = DateTime.now();
      final limite = agora.add(Duration(days: dias));

      return todasProvas
          .where(
            (prova) => prova.data.isAfter(agora) && prova.data.isBefore(limite),
          )
          .toList()
        ..sort((a, b) => a.data.compareTo(b.data));
    } catch (e) {
      throw Exception('Erro ao carregar próximas provas: $e');
    }
  }

  // Obter sessões de estudo de hoje
  static Future<List<SessaoEstudo>> obterSessoesDeHoje() async {
    try {
      final hoje = DateTime.now();
      return await _obterSessoesDoDia(hoje);
    } catch (e) {
      throw Exception('Erro ao carregar sessões de hoje: $e');
    }
  }

  // Métodos privados auxiliares
  static Future<List<Prova>> _obterProvasDoDia(DateTime data) async {
    final todasProvas = await ProvaService.listarProvas();
    return todasProvas
        .where(
          (prova) =>
              prova.data.year == data.year &&
              prova.data.month == data.month &&
              prova.data.day == data.day,
        )
        .toList();
  }

  static Future<List<SessaoEstudo>> _obterSessoesDoDia(DateTime data) async {
    final todasSessoes = await SessaoService.listarSessoes();
    return todasSessoes
        .where(
          (sessao) =>
              sessao.tempoInicio != null &&
              sessao.tempoInicio!.year == data.year &&
              sessao.tempoInicio!.month == data.month &&
              sessao.tempoInicio!.day == data.day,
        )
        .toList();
  }

  static Future<List<Evento>> _obterEventosDoDia(DateTime data) async {
    final todosEventos = await EventoService.listarEventos();
    return todosEventos
        .where(
          (evento) =>
              evento.data.year == data.year &&
              evento.data.month == data.month &&
              evento.data.day == data.day,
        )
        .toList();
  }

  // Estatísticas do cronograma
  static Future<Map<String, int>> obterEstatisticas() async {
    try {
      final provas = await ProvaService.listarProvas();
      final sessoes = await SessaoService.listarSessoes();
      final eventos = await EventoService.listarEventos();
      final agora = DateTime.now();

      final proximasProvas = provas.where((p) => p.data.isAfter(agora)).length;
      final proximosEventos =
          eventos.where((e) => e.data.isAfter(agora)).length;
      final sessoesHoje =
          sessoes
              .where(
                (s) =>
                    s.tempoInicio != null &&
                    s.tempoInicio!.year == agora.year &&
                    s.tempoInicio!.month == agora.month &&
                    s.tempoInicio!.day == agora.day,
              )
              .length;

      return {
        'totalProvas': provas.length,
        'proximasProvas': proximasProvas,
        'totalEventos': eventos.length,
        'proximosEventos': proximosEventos,
        'totalSessoes': sessoes.length,
        'sessoesHoje': sessoesHoje,
      };
    } catch (e) {
      throw Exception('Erro ao carregar estatísticas: $e');
    }
  }
}
