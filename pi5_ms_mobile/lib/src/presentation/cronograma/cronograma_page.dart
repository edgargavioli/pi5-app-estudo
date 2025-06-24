import 'package:flutter/material.dart';
import 'package:pi5_ms_mobile/src/presentation/cronograma/criar_evento_page.dart';
import 'package:pi5_ms_mobile/src/presentation/cronograma/agendar_sessao_page.dart';
import 'package:pi5_ms_mobile/src/presentation/estudos/estudo_cronometro_page.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:pi5_ms_mobile/src/components/button_widget.dart';
import '../../shared/models/prova_model.dart';
import '../../shared/models/evento_model.dart';
import '../../shared/services/cronograma_service.dart';

import '../provas/provas_listagem_page.dart';

class CronogramaPage extends StatefulWidget {
  const CronogramaPage({super.key});

  @override
  State<CronogramaPage> createState() => _CronogramaPageState();
}

class _CronogramaPageState extends State<CronogramaPage> {
  // Eventos carregados da API (provas e sessões)
  Map<DateTime, List<dynamic>> _eventos = {};

  // get normalized date (year-month-day)
  DateTime _normalize(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = _normalize(DateTime.now());
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Carregar eventos do mês atual
      final eventos = await CronogramaService.obterEventosDoMes(_focusedDay);

      if (mounted) {
        setState(() {
          _eventos = eventos;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar cronograma: $e')),
        );
      }
    }
  }

  List<dynamic> _getEventosParaDia(DateTime dia) {
    return _eventos[_normalize(dia)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Cronograma',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            Divider(thickness: 1, height: 1, color: colorScheme.outline),

            if (_isLoading)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: CircularProgressIndicator(color: colorScheme.primary),
              ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: TableCalendar(
                        locale: 'pt_BR',
                        eventLoader: _getEventosParaDia,
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2030, 12, 31),
                        focusedDay: _focusedDay,
                        selectedDayPredicate:
                            (day) => isSameDay(_selectedDay, day),
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                        },
                        onPageChanged: (focusedDay) {
                          setState(() {
                            _focusedDay = focusedDay;
                          });
                          _carregarDados(); // Recarregar eventos do novo mês
                        },
                        calendarStyle: CalendarStyle(
                          todayDecoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          selectedDecoration: BoxDecoration(
                            color: colorScheme.secondary,
                            shape: BoxShape.circle,
                          ),
                          outsideDaysVisible: false,
                          weekendTextStyle: TextStyle(
                            color: colorScheme.error,
                            fontSize: 12,
                          ),
                          defaultTextStyle: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurface,
                          ),
                          holidayTextStyle: TextStyle(
                            color: colorScheme.error,
                            fontSize: 12,
                          ),
                          cellMargin: EdgeInsets.zero,
                          cellPadding: EdgeInsets.zero,
                          markerDecoration: BoxDecoration(
                            color: colorScheme.tertiary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        headerStyle: HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                          titleTextStyle: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                          leftChevronIcon: Icon(
                            Icons.chevron_left,
                            color: colorScheme.primary,
                            size: 16,
                          ),
                          rightChevronIcon: Icon(
                            Icons.chevron_right,
                            color: colorScheme.primary,
                            size: 16,
                          ),
                          headerPadding: const EdgeInsets.symmetric(
                            vertical: 2,
                          ),
                          leftChevronMargin: const EdgeInsets.only(left: 4),
                          rightChevronMargin: const EdgeInsets.only(right: 4),
                        ),
                        calendarFormat: CalendarFormat.month,
                        calendarBuilders: CalendarBuilders(
                          dowBuilder: (context, day) {
                            if (day.weekday == DateTime.sunday ||
                                day.weekday == DateTime.saturday) {
                              return Center(
                                child: Text(
                                  day.weekday == DateTime.sunday ? 'D' : 'S',
                                  style: TextStyle(
                                    color: colorScheme.error,
                                    fontSize: 11,
                                  ),
                                ),
                              );
                            }
                            return null;
                          },
                          markerBuilder: (context, day, events) {
                            if (events.isEmpty) return null;

                            return Positioned(
                              bottom: 1,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children:
                                    events.take(3).map((event) {
                                      Color cor = colorScheme.primary;
                                      if (event is Prova) {
                                        cor = colorScheme.error;
                                      } else if (event is SessaoEstudo) {
                                        cor = colorScheme.secondary;
                                      } else if (event is Evento) {
                                        cor = colorScheme.tertiary;
                                      }

                                      return Container(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 0.5,
                                        ),
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: cor,
                                          shape: BoxShape.circle,
                                        ),
                                      );
                                    }).toList(),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: ButtonWidget(
                                text:
                                    _selectedDay != null
                                        ? 'Agendar Sessão'
                                        : 'Selecione um dia',
                                onPressed:
                                    _selectedDay != null
                                        ? _agendarSessaoParaDia
                                        : null,
                                color: colorScheme.primary,
                                textStyle: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: colorScheme.onPrimary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: ButtonWidget(
                                text:
                                    _selectedDay != null
                                        ? 'Agendar Evento'
                                        : 'Selecione um dia',
                                onPressed:
                                    _selectedDay != null
                                        ? _criarEventoParaDia
                                        : null,
                                color: colorScheme.secondary,
                                textStyle: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: colorScheme.onSecondary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (_selectedDay != null) _buildEventosDodia(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "cronograma_gerenciar_fab",
        backgroundColor: colorScheme.secondary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProvasListagemPage()),
          );
        },
        icon: Icon(Icons.library_books, color: colorScheme.onSecondary),
        label: Text(
          "Ver Provas",
          style: TextStyle(color: colorScheme.onSecondary),
        ),
      ),
    );
  }

  Widget _buildEventosDodia() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final eventos = _getEventosParaDia(_selectedDay!);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Eventos em ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 8),

          if (eventos.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Nenhum evento neste dia.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: 'Poppins',
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else
            ...eventos.map((evento) => _buildEventoCard(evento)),

          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildEventoCard(dynamic evento) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    String titulo, subtitulo, horario;
    Color corCard, corIcone;
    IconData icone;
    Widget? statusWidget;

    if (evento is Prova) {
      titulo = evento.titulo;
      subtitulo = evento.local;
      horario = DateFormat('HH:mm').format(evento.horario);
      corCard = colorScheme.errorContainer;
      corIcone = colorScheme.error;
      icone = Icons.assignment;
    } else if (evento is SessaoEstudo) {
      titulo = evento.conteudo;

      // Definir subtítulo e status baseado no estado da sessão
      if (evento.finalizada) {
        subtitulo = 'Sessão Finalizada';
        statusWidget = Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: colorScheme.tertiary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, size: 14, color: colorScheme.tertiary),
              const SizedBox(width: 4),
              Text(
                'Finalizada',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.tertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
        corCard = colorScheme.tertiaryContainer.withOpacity(0.3);
        corIcone = colorScheme.tertiary;
        icone = Icons.history;
      } else if (evento.isAgendada) {
        subtitulo = 'Sessão Agendada';
        statusWidget = Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.schedule, size: 14, color: colorScheme.primary),
              const SizedBox(width: 4),
              Text(
                'Agendada',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
        corCard = colorScheme.primaryContainer;
        corIcone = colorScheme.primary;
        icone = Icons.school;
      } else {
        subtitulo = 'Sessão Livre';
        corCard = colorScheme.primaryContainer;
        corIcone = colorScheme.primary;
        icone = Icons.school;
      }

      // Determinar horário baseado no estado
      if (evento.finalizada) {
        if (evento.tempoInicio != null) {
          horario = DateFormat('HH:mm').format(evento.tempoInicio!);
        } else {
          horario = 'Histórico';
        }
      } else if (evento.isAgendada && evento.horarioAgendado != null) {
        horario = DateFormat('HH:mm').format(evento.horarioAgendado!);
      } else {
        horario = 'Livre';
      }
    } else if (evento is Evento) {
      titulo = evento.titulo;
      subtitulo = evento.tipo.displayName;
      horario = DateFormat('HH:mm').format(evento.horario);
      corCard = colorScheme.tertiaryContainer;
      corIcone = colorScheme.tertiary;
      icone = Icons.event;
    } else {
      titulo = 'Evento';
      subtitulo = '';
      horario = '';
      corCard = colorScheme.surfaceContainerHighest;
      corIcone = colorScheme.onSurfaceVariant;
      icone = Icons.event;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: GestureDetector(
        onTap: () => _acessarEvento(evento),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: colorScheme.outline),
            borderRadius: BorderRadius.circular(8),
            color: corCard,
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(icone, size: 24, color: corIcone),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    if (subtitulo.isNotEmpty)
                      Row(
                        children: [
                          Text(
                            subtitulo,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontFamily: 'Poppins',
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          if (statusWidget != null) ...[
                            const SizedBox(width: 8),
                            statusWidget,
                          ],
                        ],
                      ),
                  ],
                ),
              ),
              if (horario.isNotEmpty)
                Text(
                  horario,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _agendarSessaoParaDia() async {
    if (_selectedDay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um dia primeiro')),
      );
      return;
    }

    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AgendarSessaoPage(dataInicial: _selectedDay),
      ),
    );

    if (resultado == true) {
      // Recarregar dados se a sessão foi agendada
      _carregarDados();
    }
  }

  Future<void> _criarEventoParaDia() async {
    if (_selectedDay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um dia primeiro')),
      );
      return;
    }

    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => CriarEventoPage(dataInicial: _selectedDay),
      ),
    );

    if (resultado == true) {
      // Recarregar dados se o evento foi criado
      _carregarDados();
    }
  }

  void _acessarEvento(dynamic evento) {
    if (evento is SessaoEstudo) {
      if (evento.finalizada) {
        // Mostrar histórico da sessão finalizada (agendada ou livre)
        _mostrarHistoricoSessao(evento);
      } else if (evento.isAgendada) {
        // Verificar se pode acessar a sessão agendada
        if (evento.podeSerIniciada) {
          // Navegar para tela de cronômetro
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EstudoCronometroPage(sessao: evento),
            ),
          ).then((_) => _carregarDados()); // Recarregar após voltar
        } else {
          // Mostrar diálogo explicando o horário
          _mostrarDialogoSessaoAgendada(evento);
        }
      } else {
        // Sessão livre não finalizada - pode iniciar
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EstudoCronometroPage(sessao: evento),
          ),
        ).then((_) => _carregarDados()); // Recarregar após voltar
      }
    }
    // Adicionar outras ações para outros tipos de evento se necessário
  }

  void _mostrarDialogoSessaoAgendada(SessaoEstudo sessao) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final agora = DateTime.now();
    final horarioAgendado = sessao.horarioAgendado!;
    final podeIniciarEm = horarioAgendado.difference(agora);
    final jaPassouHorario = agora.isAfter(
      horarioAgendado.add(const Duration(minutes: 30)),
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(
                  jaPassouHorario ? Icons.warning : Icons.schedule,
                  color:
                      jaPassouHorario ? colorScheme.error : colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  jaPassouHorario ? 'Sessão Expirada' : 'Sessão Agendada',
                  style: TextStyle(
                    color:
                        jaPassouHorario
                            ? colorScheme.error
                            : colorScheme.primary,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Conteúdo: ${sessao.conteudo}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Agendado para: ${_formatarDataHora(horarioAgendado)}',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                      if (sessao.metaTempo != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Meta de tempo: ${sessao.metaTempo} minutos',
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                if (jaPassouHorario) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: colorScheme.error, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Esta sessão não pode mais ser iniciada pois passou do prazo de tolerância (30 minutos após o horário agendado).',
                            style: TextStyle(
                              color: colorScheme.error,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (podeIniciarEm.isNegative) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.tertiaryContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.play_circle,
                          color: colorScheme.tertiary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Você pode iniciar esta sessão agora! Ainda está dentro do prazo de tolerância.',
                            style: TextStyle(
                              color: colorScheme.tertiary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Você poderá iniciar esta sessão em ${_formatarTempoRestante(podeIniciarEm)}.',
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              if (!jaPassouHorario && podeIniciarEm.isNegative)
                FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => EstudoCronometroPage(sessao: sessao),
                      ),
                    ).then((_) => _carregarDados());
                  },
                  child: const Text('Iniciar Sessão'),
                ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  String _formatarTempoRestante(Duration duracao) {
    final horas = duracao.inHours;
    final minutos = duracao.inMinutes.remainder(60);

    if (horas > 0) {
      return '${horas}h ${minutos}min';
    } else if (minutos > 0) {
      return '${minutos}min';
    } else {
      return 'alguns segundos';
    }
  }

  void _mostrarHistoricoSessao(SessaoEstudo sessao) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 8,
            backgroundColor: colorScheme.surface,
            contentPadding: EdgeInsets.zero,
            content: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: colorScheme.surface,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header com gradiente
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          (sessao.isAgendada
                                  ? colorScheme.primaryContainer
                                  : colorScheme.secondaryContainer)
                              .withOpacity(0.8),
                          (sessao.isAgendada
                                  ? colorScheme.primaryContainer
                                  : colorScheme.secondaryContainer)
                              .withOpacity(0.4),
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: (sessao.isAgendada
                                    ? colorScheme.primary
                                    : colorScheme.secondary)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Icon(
                            Icons.history_rounded,
                            size: 28,
                            color:
                                sessao.isAgendada
                                    ? colorScheme.primary
                                    : colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Histórico da Sessão',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: (sessao.isAgendada
                                          ? colorScheme.primary
                                          : colorScheme.secondary)
                                      .withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      sessao.isAgendada
                                          ? Icons.schedule_rounded
                                          : Icons.play_circle_rounded,
                                      size: 16,
                                      color:
                                          sessao.isAgendada
                                              ? colorScheme.primary
                                              : colorScheme.secondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      sessao.isAgendada
                                          ? 'Sessão Agendada'
                                          : 'Sessão Livre',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            sessao.isAgendada
                                                ? colorScheme.primary
                                                : colorScheme.secondary,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Conteúdo scrollável
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Conteúdo
                          _buildHistoricoCard(
                            icon: Icons.book_rounded,
                            label: 'Conteúdo',
                            value: sessao.conteudo,
                            colorScheme: colorScheme,
                            theme: theme,
                          ),

                          if (sessao.topicos.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            _buildHistoricoCard(
                              icon: Icons.tag_rounded,
                              label: 'Tópicos',
                              value: sessao.topicos.join(' • '),
                              colorScheme: colorScheme,
                              theme: theme,
                            ),
                          ],

                          // Duração
                          if (sessao.tempoInicio != null &&
                              sessao.tempoFim != null) ...[
                            const SizedBox(height: 16),
                            _buildHistoricoCard(
                              icon: Icons.timer_rounded,
                              label: 'Duração',
                              value: _formatarDuracao(
                                sessao.tempoFim!.difference(
                                  sessao.tempoInicio!,
                                ),
                              ),
                              colorScheme: colorScheme,
                              theme: theme,
                            ),
                          ],

                          // Horários
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              if (sessao.tempoInicio != null)
                                Expanded(
                                  child: _buildTimeCard(
                                    icon: Icons.play_arrow_rounded,
                                    label: 'Início',
                                    time: _formatarDataHora(
                                      sessao.tempoInicio!,
                                    ),
                                    color: colorScheme.tertiary,
                                    backgroundColor:
                                        colorScheme.tertiaryContainer,
                                    theme: theme,
                                  ),
                                ),
                              if (sessao.tempoInicio != null &&
                                  sessao.tempoFim != null)
                                const SizedBox(width: 12),
                              if (sessao.tempoFim != null)
                                Expanded(
                                  child: _buildTimeCard(
                                    icon: Icons.stop_rounded,
                                    label: 'Fim',
                                    time: _formatarDataHora(sessao.tempoFim!),
                                    color: colorScheme.primary,
                                    backgroundColor:
                                        colorScheme.primaryContainer,
                                    theme: theme,
                                  ),
                                ),
                            ],
                          ),

                          // Desempenho em questões
                          if (sessao.totalQuestoes > 0) ...[
                            const SizedBox(height: 20),
                            _buildPerformanceSection(
                              sessao,
                              colorScheme,
                              theme,
                            ),
                          ],

                          // Status da sessão agendada
                          if (sessao.isAgendada &&
                              sessao.cumpriuPrazo != null) ...[
                            const SizedBox(height: 20),
                            _buildStatusCard(sessao, colorScheme, theme),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Botão de fechar
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withOpacity(
                        0.3,
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FilledButton.tonal(
                          onPressed: () => Navigator.pop(context),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.close_rounded, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Fechar',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildHistoricoCard({
    required IconData icon,
    required String label,
    required String value,
    required ColorScheme colorScheme,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeCard({
    required IconData icon,
    required String label,
    required String time,
    required Color color,
    required Color backgroundColor,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            time.split(' às ')[1], // Só o horário
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          Text(
            time.split(' às ')[0], // Só a data
            style: theme.textTheme.labelSmall?.copyWith(
              color: color.withOpacity(0.7),
              fontFamily: 'Poppins',
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceSection(
    SessaoEstudo sessao,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    final percentual = sessao.percentualAcerto;
    Color performanceColor;
    IconData performanceIcon;

    if (percentual >= 80) {
      performanceColor = colorScheme.tertiary;
      performanceIcon = Icons.emoji_events_rounded;
    } else if (percentual >= 60) {
      performanceColor = colorScheme.primary;
      performanceIcon = Icons.thumb_up_rounded;
    } else {
      performanceColor = colorScheme.error;
      performanceIcon = Icons.trending_down_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            performanceColor.withOpacity(0.1),
            performanceColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: performanceColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: performanceColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(performanceIcon, size: 20, color: performanceColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Desempenho em Questões',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: performanceColor,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${sessao.questoesAcertadas}/${sessao.totalQuestoes} questões acertadas',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${percentual.toStringAsFixed(1)}%',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: performanceColor,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentual / 100,
              backgroundColor: colorScheme.outline.withOpacity(0.2),
              color: performanceColor,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(
    SessaoEstudo sessao,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    final cumpriu = sessao.cumpriuPrazo!;
    final color = cumpriu ? colorScheme.tertiary : colorScheme.error;
    final backgroundColor =
        cumpriu ? colorScheme.tertiaryContainer : colorScheme.errorContainer;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              cumpriu ? Icons.check_circle_rounded : Icons.warning_rounded,
              size: 20,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status da Sessão',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: color,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  cumpriu
                      ? 'Sessão realizada no prazo'
                      : 'Sessão realizada fora do prazo',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: color,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatarDuracao(Duration duracao) {
    final horas = duracao.inHours;
    final minutos = duracao.inMinutes.remainder(60);

    if (horas > 0) {
      return '${horas}h ${minutos}min';
    } else {
      return '${minutos}min';
    }
  }

  String _formatarDataHora(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} às ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
