import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:pi5_ms_mobile/src/components/button_widget.dart';
import '../../shared/models/prova_model.dart';
import '../../shared/models/evento_model.dart';
import '../../shared/services/cronograma_service.dart';


import '../estudos/sessoes_estudo_page.dart';
import '../estudos/criar_sessao_page.dart';
import 'criar_evento_page.dart';

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
                        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
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
                          headerPadding: const EdgeInsets.symmetric(vertical: 2),
                          leftChevronMargin: const EdgeInsets.only(left: 4),
                          rightChevronMargin: const EdgeInsets.only(right: 4),
                        ),
                        calendarFormat: CalendarFormat.month,
                        calendarBuilders: CalendarBuilders(
                          dowBuilder: (context, day) {
                            if (day.weekday == DateTime.sunday || day.weekday == DateTime.saturday) {
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
                                children: events.take(3).map((event) {
                                  Color cor = colorScheme.primary;
                                  if (event is Prova) {
                                    cor = colorScheme.error;
                                  } else if (event is SessaoEstudo) {
                                    cor = colorScheme.secondary;
                                  } else if (event is Evento) {
                                    cor = colorScheme.tertiary;
                                  }
                                  
                                  return Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 0.5),
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
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: ButtonWidget(
                                text: _selectedDay != null 
                                    ? 'Nova sessão'
                                    : 'Selecione um dia',
                                onPressed: _selectedDay != null ? _criarSessaoParaDia : null,
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
                          const SizedBox(width: 8),
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: ButtonWidget(
                                text: _selectedDay != null 
                                    ? 'Novo evento'
                                    : 'Selecione um dia',
                                onPressed: _selectedDay != null ? _criarEventoParaDia : null,
                                color: colorScheme.tertiary,
                                textStyle: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: colorScheme.onTertiary,
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
            MaterialPageRoute(
              builder: (context) => const SessoesEstudoPage(),
            ),
          );
        },
        icon: Icon(Icons.manage_search, color: colorScheme.onSecondary),
        label: Text(
          "Gerenciar Sessões",
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
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
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

    if (evento is Prova) {
      titulo = evento.titulo;
      subtitulo = evento.local;
      horario = DateFormat('HH:mm').format(evento.horario);
      corCard = colorScheme.errorContainer;
      corIcone = colorScheme.error;
      icone = Icons.assignment;
    } else if (evento is SessaoEstudo) {
      titulo = evento.conteudo;
      subtitulo = 'Sessão de Estudo';
      horario = evento.tempoInicio != null 
          ? DateFormat('HH:mm').format(evento.tempoInicio!)
          : 'Não iniciada';
      corCard = colorScheme.primaryContainer;
      corIcone = colorScheme.primary;
      icone = Icons.school;
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
      corCard = colorScheme.surfaceVariant;
      corIcone = colorScheme.onSurfaceVariant;
      icone = Icons.event;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
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
                    Text(
                      subtitulo,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'Poppins',
                        color: colorScheme.onSurfaceVariant,
                      ),
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
    );
  }

  Future<void> _criarSessaoParaDia() async {
    if (_selectedDay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um dia primeiro')),
      );
      return;
    }

    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => CriarSessaoPage(
          dataInicial: _selectedDay,
        ),
      ),
    );

    if (resultado == true) {
      // Recarregar dados se a sessão foi criada
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
        builder: (context) => CriarEventoPage(
          dataInicial: _selectedDay,
        ),
      ),
    );

    if (resultado == true) {
      // Recarregar dados se o evento foi criado
      _carregarDados();
    }
  }
}
