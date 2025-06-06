import 'package:flutter/material.dart';
import 'package:pi5_ms_mobile/src/components/loading_widget.dart';
import 'package:pi5_ms_mobile/src/shared/models/prova_model.dart';
import 'package:pi5_ms_mobile/src/shared/models/evento_model.dart';
import 'package:pi5_ms_mobile/src/shared/services/prova_service.dart';
import 'package:pi5_ms_mobile/src/shared/services/materia_service.dart';
import 'package:pi5_ms_mobile/src/shared/services/estatisticas_service.dart';
import 'package:pi5_ms_mobile/src/presentation/estudos/criar_sessao_page.dart';
import 'dart:async';
// removed ScaffoldWidget import to use simple Scaffold

class EstudosPage extends StatefulWidget {
  const EstudosPage({super.key});
  @override
  State<EstudosPage> createState() => _EstudosPageState();
}

class _EstudosPageState extends State<EstudosPage> {
  // API Integration
  List<Prova> _provas = [];
  List<Materia> _materias = [];
  bool _isLoading = true;
  String? _error;
  
  // Selection
  String? _selectedProvaId;
  String? _selectedMateriaId;
  
  // Timer
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  bool _running = false;

  // Estatísticas
  Map<String, dynamic> _estatisticas = {
    'sequencia': 0,
    'nivel': 1,
    'xp': 0,
    'melhorTempo': Duration.zero,
  };

  @override
  void initState() {
    super.initState();
    _carregarDados();
    _carregarEstatisticas();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _carregarDados({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final provas = await ProvaService.listarProvas(forceRefresh: forceRefresh);
      final materias = await MateriaService.listarMaterias(forceRefresh: forceRefresh);
      
      if (mounted) {
        setState(() {
          _provas = provas;
          _materias = materias;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _carregarEstatisticas() async {
    try {
      final estatisticas = await EstatisticasService.obterEstatisticasCompletas();
      if (mounted) {
        setState(() {
          _estatisticas = estatisticas;
        });
      }
    } catch (e) {
      print('Erro ao carregar estatísticas: $e');
    }
  }

  void _startTimer() {
    if (!_running) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() {
          _elapsed += const Duration(seconds: 1);
        });
      });
      setState(() {
        _running = true;
      });
    }
  }

  void _pauseTimer() {
    if (_running) {
      _timer?.cancel();
      setState(() => _running = false);
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _running = false;
      _elapsed = Duration.zero;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: () => _carregarDados(forceRefresh: true),
              color: colorScheme.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(
                  left: 20,
                  top: 10,
                  right: 20,
                  bottom: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Back arrow
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Loading state
                    if (_isLoading)
                      const LoadingWidget(
                        message: 'Carregando dados...',
                        size: 48,
                      )
                    else if (_error != null)
                      Center(
                        child: Column(
                          children: [
                            Icon(Icons.error_outline, 
                                 size: 48, 
                                 color: colorScheme.error),
                            const SizedBox(height: 16),
                            Text(
                              'Erro ao carregar dados',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: colorScheme.error,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _error!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _carregarDados,
                              child: const Text('Tentar novamente'),
                            ),
                          ],
                        ),
                      )
                    else ...[
                      // Prova dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedProvaId,
                        isExpanded: true,
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 14,
                          color: colorScheme.onSurface,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Prova',
                          labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: BorderSide(color: colorScheme.outline),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: BorderSide(color: colorScheme.outline),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: BorderSide(color: colorScheme.primary),
                          ),
                          prefixIcon: Icon(Icons.assignment, color: colorScheme.onSurfaceVariant),
                        ),
                        dropdownColor: colorScheme.surface,
                        items: _provas.map((prova) {
                          return DropdownMenuItem<String>(
                            value: prova.id,
                            child: Text(
                              prova.titulo,
                              style: TextStyle(color: colorScheme.onSurface),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _selectedProvaId = value),
                      ),
                      const SizedBox(height: 16),
                      
                      // Matéria dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedMateriaId,
                        isExpanded: true,
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 14,
                          color: colorScheme.onSurface,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Matéria',
                          labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: BorderSide(color: colorScheme.outline),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: BorderSide(color: colorScheme.outline),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: BorderSide(color: colorScheme.primary),
                          ),
                          prefixIcon: Icon(Icons.menu_book, color: colorScheme.onSurfaceVariant),
                        ),
                        dropdownColor: colorScheme.surface,
                        items: _materias.map((materia) {
                          return DropdownMenuItem<String>(
                            value: materia.id,
                            child: Text(
                              materia.nome,
                              style: TextStyle(color: colorScheme.onSurface),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _selectedMateriaId = value),
                      ),
                      const SizedBox(height: 32),
                      
                      // Session time
                      Center(
                        child: Text(
                          'Tempo de sessão',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 24,
                            fontWeight: FontWeight.w400,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Text(
                          '${_elapsed.inHours.toString().padLeft(2, '0')}:'
                          '${(_elapsed.inMinutes % 60).toString().padLeft(2, '0')}:'
                          '${(_elapsed.inSeconds % 60).toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 32,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Seu último recorde foi:',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Icon(
                              Icons.local_fire_department,
                              size: 24,
                              color: Colors.orange,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatarDuracao(_estatisticas['melhorTempo'] as Duration),
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 38),
                      
                      // Controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          // Pause button
                          ElevatedButton(
                            onPressed: _running ? _pauseTimer : null,
                            style: ElevatedButton.styleFrom(
                              elevation: 4,
                              shadowColor: Colors.black26,
                              backgroundColor: _running 
                                  ? colorScheme.secondary
                                  : colorScheme.outlineVariant,
                              disabledBackgroundColor: colorScheme.outlineVariant,
                              minimumSize: const Size(85, 85),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            child: Icon(
                              Icons.pause,
                              size: 24,
                              color: _running ? colorScheme.onSecondary : colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 22),
                          
                          // Play button
                          ElevatedButton(
                            onPressed: !_running ? _startTimer : null,
                            style: ElevatedButton.styleFrom(
                              elevation: 4,
                              shadowColor: Colors.black26,
                              backgroundColor: !_running 
                                  ? colorScheme.primary
                                  : colorScheme.outlineVariant,
                              disabledBackgroundColor: colorScheme.outlineVariant,
                              minimumSize: const Size(85, 85),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            child: Icon(
                              Icons.play_arrow,
                              size: 24,
                              color: !_running ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 22),
                          
                          // Reset button
                          ElevatedButton(
                            onPressed: _resetTimer,
                            style: ElevatedButton.styleFrom(
                              elevation: 4,
                              shadowColor: Colors.black26,
                              backgroundColor: colorScheme.errorContainer,
                              minimumSize: const Size(85, 85),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            child: Icon(
                              Icons.refresh,
                              size: 24,
                              color: colorScheme.onErrorContainer,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 160),
                    if (!_running && _elapsed > Duration.zero)
                      Align(
                        alignment: Alignment.centerRight,
                        child: SizedBox(
                          width: 56,
                          height: 56,
                          child: FloatingActionButton(
                            heroTag: "estudos_save_session_fab",
                            backgroundColor:
                                colorScheme.primary,
                            onPressed: () async {
                              // Criar uma sessão pré-preenchida com o tempo decorrido
                              final agora = DateTime.now();
                              final inicioSessao = agora.subtract(_elapsed);
                              
                              final sessaoTemporaria = SessaoEstudo(
                                id: '',
                                materiaId: _selectedMateriaId ?? '',
                                provaId: _selectedProvaId,
                                conteudo: '',
                                topicos: [],
                                tempoInicio: inicioSessao,
                                tempoFim: agora,
                                createdAt: agora,
                                updatedAt: agora,
                              );

                              final resultado = await Navigator.push<bool>(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CriarSessaoPage(
                                    sessao: sessaoTemporaria,
                                    materiaId: _selectedMateriaId,
                                    provaId: _selectedProvaId,
                                  ),
                                ),
                              );

                              if (resultado == true) {
                                _resetTimer();
                                _carregarEstatisticas();
                                Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
                              }
                            },
                            child: const Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatarDuracao(Duration duracao) {
  final horas = duracao.inHours.toString().padLeft(2, '0');
  final minutos = (duracao.inMinutes % 60).toString().padLeft(2, '0');
  final segundos = (duracao.inSeconds % 60).toString().padLeft(2, '0');
  return '$horas:$minutos:$segundos';
}
