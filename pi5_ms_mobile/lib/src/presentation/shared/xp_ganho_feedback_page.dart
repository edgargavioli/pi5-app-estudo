import 'package:flutter/material.dart';
import 'dart:math' as math;

class XpGanhoFeedbackPage extends StatefulWidget {
  final int xpGanho;
  final int xpTotal;
  final int nivel;
  final String motivoXP;
  final bool isBonus;
  final bool isPenalidade;
  final List<String>? detalhamentoXp;
  final double? progressoNivel;
  final int? xpProximoNivel;

  const XpGanhoFeedbackPage({
    super.key,
    required this.xpGanho,
    required this.xpTotal,
    required this.nivel,
    required this.motivoXP,
    this.isBonus = false,
    this.isPenalidade = false,
    this.detalhamentoXp,
    this.progressoNivel,
    this.xpProximoNivel,
  });

  @override
  State<XpGanhoFeedbackPage> createState() => _XpGanhoFeedbackPageState();
}

class _XpGanhoFeedbackPageState extends State<XpGanhoFeedbackPage>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late AnimationController _xpCountController;
  late AnimationController _sparkleController;

  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<int> _xpCountAnimation;
  late Animation<double> _sparkleAnimation;

  @override
  void initState() {
    super.initState();

    // Controladores de animação
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _xpCountController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    ); // Animações
    _slideAnimation = Tween<double>(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.elasticInOut),
    ); // Garantir que o valor é um inteiro válido e positivo
    final endValue = (widget.xpGanho.abs().clamp(1, 9999)).toInt();
    _xpCountAnimation = IntTween(begin: 0, end: endValue).animate(
      CurvedAnimation(parent: _xpCountController, curve: Curves.easeOut),
    );

    _sparkleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _sparkleController, curve: Curves.easeInOut),
    );

    // Iniciar animações
    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _slideController.forward();

    await Future.delayed(const Duration(milliseconds: 600));
    _xpCountController.forward();

    await Future.delayed(const Duration(milliseconds: 800));
    _pulseController.repeat(reverse: true);

    // Sparkles para bônus
    if (widget.isBonus) {
      await Future.delayed(const Duration(milliseconds: 500));
      _sparkleController.repeat();
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pulseController.dispose();
    _xpCountController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.8),
      body: Stack(
        children: [
          // Sparkles animados para bônus
          if (widget.isBonus) _buildSparkles(),

          // Conteúdo principal
          Center(
            child: AnimatedBuilder(
              animation: _slideAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _slideAnimation.value * 200),
                  child: Container(
                    margin: const EdgeInsets.all(32),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: _getGradientColors(),
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: _getPrimaryColor().withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Ícone principal
                        AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseAnimation.value,
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _getMainIcon(),
                                  size: 60,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 24),

                        // Título
                        Text(
                          _getTitulo(),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 16),

                        // XP ganho com animação
                        AnimatedBuilder(
                          animation: _xpCountAnimation,
                          builder: (context, child) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  widget.isBonus
                                      ? '+'
                                      : (widget.isPenalidade ? '' : '+'),
                                  style: theme.textTheme.displayMedium
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                Text(
                                  '${_xpCountAnimation.value}',
                                  style: theme.textTheme.displayMedium
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.star_rounded,
                                  color: Colors.amber,
                                  size: 32,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'XP',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        // Motivo
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.motivoXP,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Progress do nível
                        _buildNivelProgress(theme), const SizedBox(height: 32),

                        // Botão continuar
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // Como usamos pushReplacement no cronômetro, apenas um pop é suficiente
                              Navigator.pop(context, true);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: _getPrimaryColor(),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.check_rounded),
                            label: Text(
                              'Continuar',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSparkles() {
    return AnimatedBuilder(
      animation: _sparkleAnimation,
      builder: (context, child) {
        return Stack(
          children: List.generate(20, (index) {
            final random = math.Random(index);
            final size = MediaQuery.of(context).size;

            return Positioned(
              left: random.nextDouble() * size.width,
              top: random.nextDouble() * size.height,
              child: Transform.rotate(
                angle: _sparkleAnimation.value * 2 * math.pi,
                child: Opacity(
                  opacity:
                      (math.sin(_sparkleAnimation.value * math.pi * 2) + 1) / 2,
                  child: Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 16 + (random.nextDouble() * 12),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildNivelProgress(ThemeData theme) {
    final progressPercent = widget.progressoNivel ?? 0.0;
    final xpProximo = widget.xpProximoNivel ?? 1000;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Nível ${widget.nivel}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${widget.xpTotal} XP',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progressPercent,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Faltam $xpProximo XP para o próximo nível',
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
        ),

        // Detalhamento do XP ganho (se disponível)
        if (widget.detalhamentoXp != null &&
            widget.detalhamentoXp!.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detalhamento do XP:',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...widget.detalhamentoXp!.map(
                  (detalhe) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '• $detalhe',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Color _getPrimaryColor() {
    if (widget.isBonus) return Colors.green;
    if (widget.isPenalidade) return Colors.orange;
    return Colors.blue;
  }

  List<Color> _getGradientColors() {
    final primary = _getPrimaryColor();
    return [primary, primary.withOpacity(0.8)];
  }

  IconData _getMainIcon() {
    if (widget.isBonus) return Icons.emoji_events_rounded;
    if (widget.isPenalidade) return Icons.schedule_rounded;
    return Icons.star_rounded;
  }

  String _getTitulo() {
    if (widget.isBonus) return 'Bônus de Pontualidade!';
    if (widget.isPenalidade) return 'Estudo Fora do Prazo';
    return 'Parabéns!';
  }
}
