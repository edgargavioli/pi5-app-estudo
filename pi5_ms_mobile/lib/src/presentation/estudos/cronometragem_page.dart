import 'package:flutter/material.dart';
import 'package:pi5_ms_mobile/src/shared/models/evento_model.dart';
import 'package:pi5_ms_mobile/src/shared/models/prova_model.dart';
import 'package:pi5_ms_mobile/src/shared/services/sessao_service.dart';
import 'package:pi5_ms_mobile/src/shared/services/estatisticas_service.dart';
import 'package:pi5_ms_mobile/src/shared/services/cronometro_service.dart';
import 'package:pi5_ms_mobile/src/components/input_widget.dart';
import 'package:pi5_ms_mobile/src/components/button_widget.dart';
import 'dart:async';

class CronometragemPage extends StatefulWidget {
  final SessaoEstudo sessao;
  final List<Materia> materias;

  const CronometragemPage({
    super.key,
    required this.sessao,
    required this.materias,
  });

  @override
  State<CronometragemPage> createState() => _CronometragemPageState();
}

class _CronometragemPageState extends State<CronometragemPage> {
  final CronometroService _cronometroService = CronometroService();
  bool _isFinalizando = false;
  DateTime? _tempoInicioLocal;

  // Dados das estatísticas
  Duration _melhorTempo = Duration.zero;
  int _sequencia = 0;
  int _nivel = 0;
  int _xpAtual = 0;
  bool _loadingStats = true;

  @override
  void initState() {
    super.initState();
    _tempoInicioLocal = widget.sessao.tempoInicio;

    // Carregar estatísticas
    _carregarEstatisticas();

    // Se a sessão já foi finalizada, não fazer nada com cronômetro
    if (widget.sessao.tempoFim != null) {
      return;
    }

    // Verificar se já há uma sessão ativa no cronômetro global para esta sessão específica
    if (_cronometroService.hasActiveSession &&
        _cronometroService.sessaoId == widget.sessao.id) {
      // Já está rodando para esta sessão - manter como está
      print('>> Cronômetro já ativo para esta sessão: ${widget.sessao.id}');
      return;
    }

    // Se há uma sessão ativa para outra sessão, parar ela primeiro
    if (_cronometroService.hasActiveSession &&
        _cronometroService.sessaoId != widget.sessao.id) {
      print(
        '>> Parando cronômetro de outra sessão: ${_cronometroService.sessaoId}',
      );
      _cronometroService.stopCronometro();
    }

    // NÃO iniciar automaticamente o cronômetro - deixar para o usuário apertar play
    print('>> Sessão carregada mas cronômetro não iniciado automaticamente');
  }

  Materia _getMateria() {
    return widget.materias.firstWhere(
      (m) => m.id == widget.sessao.materiaId,
      orElse:
          () => Materia(
            id: '',
            nome: 'Matéria Desconhecida',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
    );
  }

  Future<void> _carregarEstatisticas() async {
    try {
      final stats = await EstatisticasService.obterEstatisticasCompletas();
      setState(() {
        _melhorTempo = stats['melhorTempo'] as Duration;
        _sequencia = stats['sequencia'] as int;
        _nivel = stats['nivel'] as int;
        _xpAtual = stats['xp'] as int;
        _loadingStats = false;
      });
    } catch (e) {
      print('Erro ao carregar estatísticas: $e');
      setState(() {
        _loadingStats = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _startTimer() {
    if (_cronometroService.isRunning) return;

    // Se a sessão ainda não foi iniciada, iniciar agora
    if (_tempoInicioLocal == null) {
      _iniciarSessao();
      return;
    }

    // Se já há uma sessão ativa para esta sessão, apenas retomar
    if (_cronometroService.hasActiveSession &&
        _cronometroService.sessaoId == widget.sessao.id) {
      _cronometroService.resumeCronometro();
      return;
    }

    // Iniciar cronômetro do zero (não calcular tempo desde _tempoInicioLocal)
    // O CronometroService já vai recuperar tempo salvo se existir
    final materia = _getMateria();
    _cronometroService.startCronometro(
      sessaoId: widget.sessao.id,
      materiaNome: materia.nome,
      // NÃO passar elapsedTime - deixar o service usar o tempo salvo se existir
    );
  }

  void _iniciarSessao() async {
    try {
      final agora = DateTime.now();
      final sessaoAtualizada = SessaoEstudo(
        id: widget.sessao.id,
        materiaId: widget.sessao.materiaId,
        provaId: widget.sessao.provaId,
        eventoId: widget.sessao.eventoId,
        conteudo: widget.sessao.conteudo,
        topicos: widget.sessao.topicos,
        tempoInicio: agora,
        tempoFim: null,
        createdAt: widget.sessao.createdAt,
        updatedAt: agora,
      );

      await SessaoService.atualizarSessao(widget.sessao.id, sessaoAtualizada);

      // Atualizar o tempo local
      _tempoInicioLocal = agora;

      // Iniciar cronômetro global
      final materia = _getMateria();
      _cronometroService.startCronometro(
        sessaoId: widget.sessao.id,
        materiaNome: materia.nome,
      );

      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao iniciar sessão: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _pauseTimer() {
    _cronometroService.pauseCronometro();
  }

  void _resetTimer() {
    _cronometroService.resetCronometro();
  }

  void _finalizarSessao() async {
    print('>> _finalizarSessao() chamado na CronometragemPage');
    print('>> _isFinalizando: $_isFinalizando');
    print('>> _tempoInicioLocal: $_tempoInicioLocal');
    print('>> Cronômetro ativo: ${_cronometroService.hasActiveSession}');
    print(
      '>> ID da sessão: ${_cronometroService.sessaoId} vs ${widget.sessao.id}',
    );

    setState(() => _isFinalizando = true);

    try {
      // Usar o tempo do cronômetro se estiver ativo, caso contrário calcular manualmente
      Duration duracaoReal;
      DateTime tempoFimReal;

      if (_cronometroService.hasActiveSession &&
          _cronometroService.sessaoId == widget.sessao.id) {
        // Usar o tempo exato do cronômetro
        duracaoReal = _cronometroService.elapsed;
        tempoFimReal = _tempoInicioLocal!.add(duracaoReal);
        print('>> Finalizando com tempo do cronômetro: $duracaoReal');
      } else if (_tempoInicioLocal != null) {
        // Calcular baseado no tempo atual
        tempoFimReal = DateTime.now();
        duracaoReal = tempoFimReal.difference(_tempoInicioLocal!);
        print('>> Finalizando com tempo calculado: $duracaoReal');
      } else {
        throw Exception('Sessão não foi iniciada');
      }

      final sessaoAtualizada = SessaoEstudo(
        id: widget.sessao.id,
        materiaId: widget.sessao.materiaId,
        provaId: widget.sessao.provaId,
        eventoId: widget.sessao.eventoId,
        conteudo: widget.sessao.conteudo,
        topicos: widget.sessao.topicos,
        tempoInicio: _tempoInicioLocal,
        tempoFim: tempoFimReal,
        createdAt: widget.sessao.createdAt,
        updatedAt: DateTime.now(),
      );

      print(
        '>> Salvando sessão - Início: $_tempoInicioLocal, Fim: $tempoFimReal, Duração: $duracaoReal',
      );

      await SessaoService.atualizarSessao(widget.sessao.id, sessaoAtualizada);

      // Atualizar estatísticas com a duração real
      await EstatisticasService.atualizarEstatisticas(duracaoReal);

      // Recarregar estatísticas atualizadas
      await _carregarEstatisticas();

      // Parar cronômetro global
      _cronometroService.stopCronometro();

      if (mounted) {
        // Sempre voltar para a lista de sessões quando finalizar
        Navigator.pop(context, true);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Sessão finalizada - Duração: ${_formatarDuracao(duracaoReal)}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('>> Erro ao finalizar sessão: $e');
      if (mounted) {
        setState(() => _isFinalizando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao finalizar sessão: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatarDuracao(Duration duracao) {
    return '${duracao.inHours.toString().padLeft(2, '0')}:'
        '${(duracao.inMinutes % 60).toString().padLeft(2, '0')}:'
        '${(duracao.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final materia = _getMateria();
    final sessaoFinalizada = widget.sessao.tempoFim != null;
    final sessaoNaoIniciada = _tempoInicioLocal == null;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: 20,
                top: 10,
                right: 20,
                bottom: 20,
              ),
              child: ListenableBuilder(
                listenable: _cronometroService,
                builder: (context, child) {
                  Duration elapsed;

                  if (sessaoFinalizada && _tempoInicioLocal != null) {
                    // Sessão finalizada - usar tempo total da sessão
                    elapsed = widget.sessao.tempoFim!.difference(
                      _tempoInicioLocal!,
                    );
                    print('>> Sessão finalizada - elapsed: $elapsed');
                  } else if (_cronometroService.hasActiveSession &&
                      _cronometroService.sessaoId == widget.sessao.id) {
                    // Cronômetro ativo para esta sessão - usar tempo do cronômetro
                    elapsed = _cronometroService.elapsed;
                    print(
                      '>> Cronômetro ativo - elapsed: $elapsed (service: ${_cronometroService.elapsed})',
                    );
                  } else {
                    // Se não há cronômetro ativo, mostrar zero
                    elapsed = Duration.zero;
                    print('>> Cronômetro não ativo - elapsed: zero');
                  }

                  final isRunning =
                      _cronometroService.isRunning &&
                      _cronometroService.sessaoId == widget.sessao.id;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // back arrow
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // session time
                      Center(
                        child: Text(
                          sessaoFinalizada
                              ? 'Tempo Total'
                              : sessaoNaoIniciada
                              ? 'Pronto para Iniciar'
                              : 'Tempo de sessão',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 24,
                            fontWeight: FontWeight.w400,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Text(
                          _formatarDuracao(elapsed),
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 48,
                            fontWeight: FontWeight.w400,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Recordes e estatísticas
                      if (!_loadingStats) ...[
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
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Icon(
                                Icons.local_fire_department,
                                size: 24,
                                color: Colors.orange,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _melhorTempo > Duration.zero
                                    ? _formatarDuracao(_melhorTempo)
                                    : 'Nenhum recorde ainda',
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        Center(
                          child: CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],

                      const SizedBox(height: 50),
                      // controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          // Pause button
                          ElevatedButton(
                            onPressed: _pauseTimer,
                            style: ElevatedButton.styleFrom(
                              elevation: 4,
                              shadowColor: Colors.black26,
                              backgroundColor:
                                  isRunning
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(
                                        context,
                                      ).colorScheme.outlineVariant,
                              minimumSize: const Size(85, 85),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            child: const Icon(
                              Icons.pause,
                              size: 24,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 22),
                          // Play button
                          ElevatedButton(
                            onPressed: isRunning ? null : _startTimer,
                            style: ElevatedButton.styleFrom(
                              elevation: 4,
                              shadowColor: Colors.black26,
                              backgroundColor:
                                  !isRunning
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(
                                        context,
                                      ).colorScheme.outlineVariant,
                              minimumSize: const Size(85, 85),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            child: const Icon(
                              Icons.play_arrow,
                              size: 24,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 22),
                          // Reset button
                          ElevatedButton(
                            onPressed: _resetTimer,
                            style: ElevatedButton.styleFrom(
                              elevation: 4,
                              shadowColor: Colors.black26,
                              backgroundColor:
                                  Theme.of(context).colorScheme.errorContainer,
                              minimumSize: const Size(85, 85),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            child: Icon(
                              Icons.close,
                              size: 24,
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onErrorContainer,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),

                      // Status da sessão
                      if (!sessaoFinalizada) ...[
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  sessaoNaoIniciada
                                      ? Colors.grey.withOpacity(0.1)
                                      : isRunning
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  sessaoNaoIniciada
                                      ? Icons.schedule
                                      : isRunning
                                      ? Icons.play_circle
                                      : Icons.pause_circle,
                                  color:
                                      sessaoNaoIniciada
                                          ? Colors.grey
                                          : isRunning
                                          ? Colors.green
                                          : Colors.orange,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  sessaoNaoIniciada
                                      ? 'Não iniciada'
                                      : isRunning
                                      ? 'Em andamento'
                                      : 'Pausada',
                                  style: TextStyle(
                                    color:
                                        sessaoNaoIniciada
                                            ? Colors.grey
                                            : isRunning
                                            ? Colors.green
                                            : Colors.orange,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Botão Finalizar
                        if (!sessaoNaoIniciada)
                          Center(
                            child: ElevatedButton(
                              onPressed:
                                  _isFinalizando ? null : _finalizarSessao,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(200, 56),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child:
                                  _isFinalizando
                                      ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                      : const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.stop),
                                          SizedBox(width: 8),
                                          Text('Finalizar Sessão'),
                                        ],
                                      ),
                            ),
                          ),
                      ],

                      const SizedBox(height: 120),
                      if (!isRunning &&
                          elapsed > Duration.zero &&
                          !sessaoFinalizada)
                        Align(
                          alignment: Alignment.centerRight,
                          child: SizedBox(
                            width: 56,
                            height: 56,
                            child: FloatingActionButton(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(24),
                                    ),
                                  ),
                                  builder:
                                      (context) => FractionallySizedBox(
                                        heightFactor: 0.85,
                                        child: SaveSessionSheet(
                                          elapsedTime: elapsed,
                                          materia: materia,
                                          sequencia: _sequencia,
                                          nivel: _nivel,
                                          xp: _xpAtual,
                                          onSave: _finalizarSessao,
                                        ),
                                      ),
                                );
                              },
                              child: const Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ VALIDAR E ENVIAR DADOS
  Future<void> _handleSubmit() async {
    // TODO: Implementar envio dos dados
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dados salvos com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

/// A placeholder bottom sheet for saving a session.
class SaveSessionSheet extends StatefulWidget {
  final Duration elapsedTime;
  final Materia materia;
  final int sequencia;
  final int nivel;
  final int xp;
  final VoidCallback onSave;

  const SaveSessionSheet({
    super.key,
    required this.elapsedTime,
    required this.materia,
    required this.sequencia,
    required this.nivel,
    required this.xp,
    required this.onSave,
  });

  @override
  State<SaveSessionSheet> createState() => _SaveSessionSheetState();
}

class _SaveSessionSheetState extends State<SaveSessionSheet> {
  final TextEditingController _questoesRespondidasController =
      TextEditingController();
  final TextEditingController _questoesAcertadasController =
      TextEditingController();
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    String formattedTime =
        '${widget.elapsedTime.inHours.toString().padLeft(2, '0')}:'
        '${(widget.elapsedTime.inMinutes % 60).toString().padLeft(2, '0')}:'
        '${(widget.elapsedTime.inSeconds % 60).toString().padLeft(2, '0')}';

    // For the progress indicator, assuming 3 hours is the goal
    double progressValue = widget.elapsedTime.inSeconds / (3 * 60 * 60);
    if (progressValue > 1.0) progressValue = 1.0;

    // Calcular XP ganho baseado no tempo
    final minutosEstudo = widget.elapsedTime.inMinutes;
    int xpGanho = (minutosEstudo * 2).clamp(10, 200);

    // Bonus por sequência
    if (widget.sequencia >= 7) {
      xpGanho = (xpGanho * 1.5).round();
    } else if (widget.sequencia >= 3) {
      xpGanho = (xpGanho * 1.2).round();
    }

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          // Main session info card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFDDE0E6)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Row(
              children: [
                // Left side: Materia info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.menu_book, size: 20),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.materia.nome,
                                style: const TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                widget.materia.categoria,
                                style: const TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Right side: progress ring
                Expanded(
                  flex: 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Meta',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const Text(
                        '03h00m',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 80,
                            height: 80,
                            child: CircularProgressIndicator(
                              value: progressValue,
                              strokeWidth: 6,
                              color: Theme.of(context).colorScheme.primary,
                              backgroundColor: Colors.grey[200],
                            ),
                          ),
                          Text(
                            formattedTime,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Metrics card with equal-width columns
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFDDE0E6)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: Row(
              children: [
                // Sequência renovada
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        color: Colors.orange,
                        size: 28,
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${widget.sequencia}',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Sequência',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 9,
                          color: Theme.of(context).colorScheme.outline,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Nível atual
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.emoji_events, color: Colors.amber, size: 28),
                      SizedBox(height: 4),
                      Text(
                        '${widget.nivel}',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Nível atual',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 9,
                          color: Theme.of(context).colorScheme.outline,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Ganho de XP
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.flash_on, color: Colors.yellow, size: 28),
                      SizedBox(height: 4),
                      Text(
                        '+$xpGanho',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.green,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Ganho de XP',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 9,
                          color: Theme.of(context).colorScheme.outline,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Questions answered toggle and fields
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFDDE0E6)),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Exercícios realizados no estudo',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Questões respondidas input styled like other pages
                InputWidget(
                  labelText: 'Quantidade de questões respondidas',
                  controller: _questoesRespondidasController,
                  width: double.infinity,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.question_answer_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                // Questões acertadas input styled like other pages
                InputWidget(
                  labelText: 'Quantidade de questões acertadas',
                  controller: _questoesAcertadasController,
                  width: double.infinity,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.check_circle_outline),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Save button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              width: double.infinity,
              height: 40, // added fixed height
              child: ButtonWidget(
                text: _isSaving ? 'Salvando...' : 'Salvar',
                onPressed:
                    _isSaving
                        ? null
                        : () async {
                          setState(() => _isSaving = true);

                          // Aqui você pode processar os dados dos exercícios
                          final questoesRespondidas =
                              int.tryParse(
                                _questoesRespondidasController.text,
                              ) ??
                              0;
                          final questoesAcertadas =
                              int.tryParse(_questoesAcertadasController.text) ??
                              0;

                          print('Questões respondidas: $questoesRespondidas');
                          print('Questões acertadas: $questoesAcertadas');

                          // Chamar a função de salvar da página pai
                          widget.onSave();
                        },
                color: Theme.of(context).colorScheme.primary,
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
