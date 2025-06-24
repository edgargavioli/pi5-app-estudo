import 'package:flutter/material.dart';
import 'dart:async';
import '../../shared/models/evento_model.dart';
import '../../shared/services/sessao_service.dart';
import '../../shared/services/estatisticas_service.dart';
import '../../shared/services/streak_service.dart';
import '../shared/xp_ganho_feedback_page.dart';
import '../shared/level_up_feedback_page.dart';
import '../../shared/widgets/streak_widget.dart';

class EstudoCronometroPage extends StatefulWidget {
  final SessaoEstudo sessao;

  const EstudoCronometroPage({super.key, required this.sessao});

  @override
  State<EstudoCronometroPage> createState() => _EstudoCronometroPageState();
}

class _EstudoCronometroPageState extends State<EstudoCronometroPage> {
  Timer? _timer;
  int _tempoDecorrido = 0;
  bool _cronometroAtivo = false;

  final _conteudoTextController = TextEditingController();
  final _novoTopicoController = TextEditingController();

  String _conteudoController = '';
  List<String> _topicos = [];

  @override
  void initState() {
    super.initState();
    _conteudoController = widget.sessao.conteudo;
    _topicos = List.from(widget.sessao.topicos);
    _conteudoTextController.text = _conteudoController;

    // Se sessão agendada, verificar se pode ser iniciada
    if (widget.sessao.isAgendada) {
      _verificarSePodemIniciar();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _conteudoTextController.dispose();
    _novoTopicoController.dispose();
    super.dispose();
  }

  void _verificarSePodemIniciar() {
    if (!widget.sessao.podeSerIniciada) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mostrarDialogHorarioIncorreto();
      });
    }
  }

  void _mostrarDialogHorarioIncorreto() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Horário Incorreto'),
            content: Text(
              'Esta sessão está agendada para ${widget.sessao.horarioAgendado != null ? "${widget.sessao.horarioAgendado!.day}/${widget.sessao.horarioAgendado!.month} às ${widget.sessao.horarioAgendado!.hour}:${widget.sessao.horarioAgendado!.minute.toString().padLeft(2, '0')}" : "outro horário"}.\n\nVocê só pode iniciar no horário marcado ou até 2 horas depois.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('Entendi'),
              ),
            ],
          ),
    );
  }

  void _iniciarCronometro() {
    if (widget.sessao.isAgendada && !widget.sessao.podeSerIniciada) {
      _mostrarDialogHorarioIncorreto();
      return;
    }

    setState(() {
      _cronometroAtivo = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _tempoDecorrido++;
      });
    });
  }

  void _pausarCronometro() {
    setState(() {
      _cronometroAtivo = false;
    });
    _timer?.cancel();
  }

  void _finalizarSessao() async {
    _timer?.cancel();

    if (_tempoDecorrido == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inicie o cronômetro antes de finalizar')),
      );
      return;
    }

    // Solicitar questões respondidas/acertadas
    final questoesData = await _mostrarDialogoQuestoes();
    if (questoesData == null) {
      // Usuário cancelou
      return;
    }

    try {
      final tempoInicio =
          widget.sessao.tempoInicio ??
          DateTime.now().subtract(Duration(seconds: _tempoDecorrido));
      final tempoFim = DateTime.now();

      if (widget.sessao.isAgendada) {
        // Sessão agendada - atualizar a existente
        await _finalizarSessaoAgendada(questoesData, tempoFim);
      } else {
        // Sessão livre - criar nova sessão já finalizada
        await _criarSessaoLivre(questoesData, tempoInicio, tempoFim);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao finalizar sessão: $e')));
      }
    }
  }

  Future<Map<String, int>?> _mostrarDialogoQuestoes() async {
    int? totalQuestoes;
    int? questoesAcertadas;

    return await showDialog<Map<String, int>>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final theme = Theme.of(context);
            final colorScheme = theme.colorScheme;

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 8,
              backgroundColor: colorScheme.surface,
              contentPadding: EdgeInsets.zero,
              content: Container(
                width: MediaQuery.of(context).size.width * 0.85,
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
                            colorScheme.primaryContainer.withOpacity(0.8),
                            colorScheme.primaryContainer.withOpacity(0.4),
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
                              color: colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Icon(
                              Icons.quiz_rounded,
                              size: 28,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Questões Respondidas',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Informe quantas questões você resolveu',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Conteúdo
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // Campo total de questões
                          _buildInputField(
                            label: 'Total de questões respondidas',
                            icon: Icons.numbers_rounded,
                            hint: 'Ex: 10, 15, 20...',
                            colorScheme: colorScheme,
                            theme: theme,
                            onChanged: (value) {
                              totalQuestoes = int.tryParse(value);
                              setState(() {});
                            },
                          ),

                          const SizedBox(height: 20),

                          // Campo questões acertadas
                          _buildInputField(
                            label: 'Questões acertadas',
                            icon: Icons.check_circle_rounded,
                            hint: 'Quantas você acertou?',
                            colorScheme: colorScheme,
                            theme: theme,
                            enabled:
                                totalQuestoes != null && totalQuestoes! > 0,
                            onChanged: (value) {
                              questoesAcertadas = int.tryParse(value);
                              setState(() {});
                            },
                          ),

                          const SizedBox(height: 16),

                          // Feedback visual
                          if (totalQuestoes != null &&
                              questoesAcertadas != null &&
                              questoesAcertadas! > totalQuestoes!)
                            _buildFeedbackCard(
                              icon: Icons.warning_amber_rounded,
                              text:
                                  'Questões acertadas não pode ser maior que o total',
                              color: colorScheme.error,
                              backgroundColor: colorScheme.errorContainer,
                            )
                          else if (totalQuestoes != null &&
                              totalQuestoes! > 0 &&
                              questoesAcertadas != null)
                            _buildPerformanceCard(
                              questoesAcertadas: questoesAcertadas!,
                              totalQuestoes: totalQuestoes!,
                              colorScheme: colorScheme,
                              theme: theme,
                            ),
                        ],
                      ),
                    ),

                    // Botões
                    Container(
                      padding: const EdgeInsets.all(24),
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
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: colorScheme.onSurfaceVariant,
                                side: BorderSide(color: colorScheme.outline),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Cancelar'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed:
                                  totalQuestoes == null ||
                                          totalQuestoes! < 0 ||
                                          (totalQuestoes! > 0 &&
                                              (questoesAcertadas == null ||
                                                  questoesAcertadas! >
                                                      totalQuestoes!))
                                      ? null
                                      : () {
                                        Navigator.pop(context, {
                                          'totalQuestoes': totalQuestoes ?? 0,
                                          'questoesAcertadas':
                                              questoesAcertadas ?? 0,
                                        });
                                      },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                                elevation: 2,
                                shadowColor: colorScheme.primary.withOpacity(
                                  0.3,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_rounded, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Finalizar Sessão',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInputField({
    required String label,
    required IconData icon,
    required String hint,
    required ColorScheme colorScheme,
    required ThemeData theme,
    bool enabled = true,
    required Function(String) onChanged,
  }) {
    return TextFormField(
      keyboardType: TextInputType.number,
      enabled: enabled,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(
          icon,
          color:
              enabled
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant.withOpacity(0.5),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
        ),
        filled: true,
        fillColor:
            enabled
                ? colorScheme.surface
                : colorScheme.surfaceContainerHighest.withOpacity(0.3),
        labelStyle: TextStyle(
          color:
              enabled
                  ? colorScheme.onSurfaceVariant
                  : colorScheme.onSurfaceVariant.withOpacity(0.5),
        ),
        hintStyle: TextStyle(
          color: colorScheme.onSurfaceVariant.withOpacity(0.7),
        ),
      ),
    );
  }

  Widget _buildFeedbackCard({
    required IconData icon,
    required String text,
    required Color color,
    required Color backgroundColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceCard({
    required int questoesAcertadas,
    required int totalQuestoes,
    required ColorScheme colorScheme,
    required ThemeData theme,
  }) {
    final percentual = (questoesAcertadas / totalQuestoes) * 100;
    final isExcelente = percentual >= 90;
    final isBom = percentual >= 70;

    Color performanceColor;
    IconData performanceIcon;
    String performanceText;

    if (isExcelente) {
      performanceColor = Colors.green;
      performanceIcon = Icons.emoji_events_rounded;
      performanceText = 'Excelente!';
    } else if (isBom) {
      performanceColor = Colors.orange;
      performanceIcon = Icons.thumb_up_rounded;
      performanceText = 'Bom trabalho!';
    } else {
      performanceColor = colorScheme.primary;
      performanceIcon = Icons.trending_up_rounded;
      performanceText = 'Continue assim!';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
        border: Border.all(color: performanceColor.withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: performanceColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(performanceIcon, color: performanceColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      performanceText,
                      style: TextStyle(
                        color: performanceColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Aproveitamento: ${percentual.toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: performanceColor.withOpacity(0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: performanceColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$questoesAcertadas/$totalQuestoes',
                  style: TextStyle(
                    color: performanceColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: percentual / 100,
            backgroundColor: performanceColor.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(performanceColor),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
        ],
      ),
    );
  }

  Future<void> _finalizarSessaoAgendada(
    Map<String, int> questoesData,
    DateTime tempoFim,
  ) async {
    // Verificar se cumpriu prazo (para sessões agendadas)
    bool? cumpriuPrazo;
    if (widget.sessao.isAgendada && widget.sessao.horarioAgendado != null) {
      final agora = DateTime.now();
      final prazoLimite = widget.sessao.horarioAgendado!.add(
        const Duration(hours: 2),
      );
      cumpriuPrazo = agora.isBefore(prazoLimite);
    }

    // Finalizar a sessão existente com as questões
    await SessaoService.finalizarSessaoComQuestoes(
      widget.sessao.id,
      questoesAcertadas: questoesData['questoesAcertadas']!,
      totalQuestoes: questoesData['totalQuestoes']!,
    );

    // Usar novo serviço balanceado de XP
    final resultado = await EstatisticasService.atualizarEstatisticasBalanceado(
      Duration(seconds: _tempoDecorrido),
      isAgendada: widget.sessao.isAgendada,
      metaTempo: widget.sessao.metaTempo,
      cumpriuPrazo: cumpriuPrazo,
      sessionId: widget.sessao.id,
      questoesAcertadas: questoesData['questoesAcertadas']!,
      totalQuestoes: questoesData['totalQuestoes']!,
    );

    await _processarResultadoFinal(resultado, questoesData);
  }

  Future<void> _criarSessaoLivre(
    Map<String, int> questoesData,
    DateTime tempoInicio,
    DateTime tempoFim,
  ) async {
    // Criar sessão livre já finalizada
    final sessao = await SessaoService.criarEFinalizarSessaoLivre(
      materiaId: widget.sessao.materiaId,
      provaId: widget.sessao.provaId,
      conteudo: _conteudoController,
      topicos: _topicos,
      tempoInicio: tempoInicio,
      tempoFim: tempoFim,
      questoesAcertadas: questoesData['questoesAcertadas']!,
      totalQuestoes: questoesData['totalQuestoes']!,
    );

    // Usar novo serviço balanceado de XP
    final resultado = await EstatisticasService.atualizarEstatisticasBalanceado(
      Duration(seconds: _tempoDecorrido),
      isAgendada: false,
      sessionId: sessao.id,
      questoesAcertadas: questoesData['questoesAcertadas']!,
      totalQuestoes: questoesData['totalQuestoes']!,
    );

    await _processarResultadoFinal(resultado, questoesData);
  }

  Future<void> _processarResultadoFinal(
    Map<String, dynamic> resultado,
    Map<String, int> questoesData,
  ) async {
    if (!mounted) return;

    // Atualizar streak com tempo estudado (em minutos decimais)
    final minutosEstudados = _tempoDecorrido / 60.0;
    final streakResultado = await StreakService.atualizarStreak(
      minutosEstudados,
    );

    if (mounted) {
      // Verificar se ativou a sequência pela primeira vez hoje
      if (streakResultado['success'] == true &&
          streakResultado['activated'] == true) {
        // Mostrar feedback de ativação da sequência
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const StreakActivationFeedback(),
        );

        // Fechar depois de 1.5 segundos
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) Navigator.of(context).pop();
      }

      // Verificar se há novas conquistas de streak
      final newAchievements = streakResultado['newAchievements'] as List? ?? [];
      for (final achievement in newAchievements) {
        if (mounted) {
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder:
                (context) => StreakAchievementDialog(
                  streakDays: achievement['streakDays'] ?? 0,
                  title: achievement['title'] ?? '',
                  description: achievement['description'] ?? '',
                ),
          );
        }
      } // Verificar se subiu de nível para mostrar tela especial
      if (resultado['subiumLevel'] == true) {
        // Primeiro mostrar tela de level up
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => LevelUpFeedbackPage(
                  novoNivel: resultado['nivel'] ?? 1,
                  xpTotal: resultado['xpTotal'] ?? 0,
                  xpProximoNivel:
                      resultado['xpParaProximoNivel'] ??
                      0, // Corrigido: usar xpParaProximoNivel
                  conquista: resultado['conquista'] ?? '',
                ),
          ),
        );
      }

      // Calcular percentual de acerto para feedback adicional
      String motivoXP = 'Sessão concluída';
      if (questoesData['totalQuestoes']! > 0) {
        final percentual =
            (questoesData['questoesAcertadas']! /
                questoesData['totalQuestoes']!) *
            100;
        motivoXP +=
            ' (${questoesData['questoesAcertadas']}/${questoesData['totalQuestoes']} questões - ${percentual.toStringAsFixed(1)}%)';
      } // Depois mostrar feedback normal de XP
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (context) => XpGanhoFeedbackPage(
                xpGanho: resultado['xpGanho'] ?? 0,
                xpTotal: resultado['xpTotal'] ?? 0,
                nivel: resultado['nivel'] ?? 1,
                motivoXP: motivoXP,
                isBonus:
                    widget.sessao.isAgendada &&
                    (resultado['cumpriuPrazo'] ?? false),
                detalhamentoXp:
                    (resultado['detalhamentoXp'] as List<dynamic>?)
                        ?.cast<String>(),
                progressoNivel: resultado['progressoNivel'] as double?,
                xpProximoNivel:
                    resultado['xpParaProximoNivel']
                        as int?, // Corrigido: usar xpParaProximoNivel
              ),
        ),
      );
    }
  }

  void _adicionarTopico() {
    final novoTopico = _novoTopicoController.text.trim();
    if (novoTopico.isNotEmpty && !_topicos.contains(novoTopico)) {
      setState(() {
        _topicos.add(novoTopico);
        _novoTopicoController.clear();
      });
    }
  }

  void _removerTopico(int index) {
    setState(() {
      _topicos.removeAt(index);
    });
  }

  String _formatarTempo(int segundos) {
    final horas = segundos ~/ 3600;
    final minutos = (segundos % 3600) ~/ 60;
    final segs = segundos % 60;

    if (horas > 0) {
      return '${horas.toString().padLeft(2, '0')}:${minutos.toString().padLeft(2, '0')}:${segs.toString().padLeft(2, '0')}';
    } else {
      return '${minutos.toString().padLeft(2, '0')}:${segs.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(widget.sessao.conteudo),
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Informações da sessão (simples)
              if (widget.sessao.isAgendada) _buildSessionInfo(theme),

              const SizedBox(height: 30),

              // Cronômetro centralizado (grande e simples)
              _buildSimpleCronometro(theme),

              const SizedBox(height: 40),

              // Botões grandes e claros
              _buildSimpleButtons(theme),

              const SizedBox(height: 30),

              // Meta de progresso (se houver)
              if (widget.sessao.metaTempo != null) _buildSimpleProgress(theme),

              const Spacer(),

              // Tópicos (mais compacto)
              _buildSimpleTopics(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSessionInfo(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.schedule, color: theme.colorScheme.primary, size: 20),
          const SizedBox(width: 8),
          Text(
            'Sessão Agendada',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (widget.sessao.horarioAgendado != null) ...[
            const Spacer(),
            Text(
              '${widget.sessao.horarioAgendado!.hour}:${widget.sessao.horarioAgendado!.minute.toString().padLeft(2, '0')}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSimpleCronometro(ThemeData theme) {
    return Center(
      child: Column(
        children: [
          // Tempo principal - muito grande e legível
          Text(
            _formatarTempo(_tempoDecorrido),
            style: TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
              color:
                  _cronometroAtivo
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),

          const SizedBox(height: 12),

          // Status simples
          Text(
            _cronometroAtivo ? 'Em andamento' : 'Pausado',
            style: theme.textTheme.titleMedium?.copyWith(
              color:
                  _cronometroAtivo
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleButtons(ThemeData theme) {
    return Row(
      children: [
        // Botão Iniciar/Pausar - grande e destacado
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed:
                _cronometroAtivo ? _pausarCronometro : _iniciarCronometro,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  _cronometroAtivo
                      ? theme.colorScheme.secondary
                      : theme.colorScheme.primary,
              foregroundColor:
                  _cronometroAtivo
                      ? theme.colorScheme.onSecondary
                      : theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _cronometroAtivo ? Icons.pause : Icons.play_arrow,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Text(
                  _cronometroAtivo ? 'PAUSAR' : 'INICIAR',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 16),

        // Botão Finalizar
        Expanded(
          child: OutlinedButton(
            onPressed: _tempoDecorrido > 0 ? _finalizarSessao : null,
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
              side: BorderSide(color: theme.colorScheme.error),
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Column(
              children: [
                Icon(Icons.stop, size: 24),
                const SizedBox(height: 4),
                Text(
                  'FINALIZAR',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleProgress(ThemeData theme) {
    if (widget.sessao.metaTempo == null) return const SizedBox.shrink();

    final metaMinutos = widget.sessao.metaTempo!;
    final metaSegundos = metaMinutos * 60;
    final progresso = (_tempoDecorrido / metaSegundos).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Meta: ${metaMinutos}min',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${(progresso * 100).toInt()}%',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color:
                      progresso >= 1.0
                          ? Colors.green
                          : theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progresso,
            backgroundColor: theme.colorScheme.outline.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              progresso >= 1.0 ? Colors.green : theme.colorScheme.primary,
            ),
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleTopics(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.list_alt, color: theme.colorScheme.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              'Tópicos',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        if (_topicos.isNotEmpty)
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children:
                _topicos.asMap().entries.map((entry) {
                  final index = entry.key;
                  final topico = entry.value;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withOpacity(
                        0.6,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          topico,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (!widget.sessao.isAgendada) ...[
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => _removerTopico(index),
                            child: Icon(
                              Icons.close,
                              size: 16,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
          )
        else
          Text(
            'Nenhum tópico adicionado',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),

        if (!widget.sessao.isAgendada) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text('Adicionar Tópico'),
                        content: TextField(
                          controller: _novoTopicoController,
                          decoration: const InputDecoration(
                            hintText: 'Ex: Funções, Derivadas...',
                            border: OutlineInputBorder(),
                          ),
                          autofocus: true,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancelar'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _adicionarTopico();
                              Navigator.pop(context);
                            },
                            child: const Text('Adicionar'),
                          ),
                        ],
                      ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Adicionar Tópico'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
