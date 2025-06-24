import 'package:flutter/material.dart';

class StreakWidget extends StatefulWidget {
  final int currentStreak;
  final bool isActivatedToday;
  final VoidCallback? onTap;
  final bool showAnimation;

  const StreakWidget({
    super.key,
    required this.currentStreak,
    required this.isActivatedToday,
    this.onTap,
    this.showAnimation = false,
  });

  @override
  State<StreakWidget> createState() => _StreakWidgetState();
}

class _StreakWidgetState extends State<StreakWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _scaleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Animação de pulso (para streak ativo)
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Animação de escala (para ativação/conquistas)
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // Iniciar animações se necessário
    if (widget.isActivatedToday) {
      _pulseController.repeat(reverse: true);
    }

    if (widget.showAnimation) {
      _scaleController.forward().then((_) {
        _scaleController.reverse();
      });
    }
  }

  @override
  void didUpdateWidget(StreakWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Controlar animação de pulso baseado no estado
    if (widget.isActivatedToday && !oldWidget.isActivatedToday) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isActivatedToday && oldWidget.isActivatedToday) {
      _pulseController.stop();
      _pulseController.reset();
    }

    // Animação de conquista/ativação
    if (widget.showAnimation && !oldWidget.showAnimation) {
      _scaleController.forward().then((_) {
        _scaleController.reverse();
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = widget.isActivatedToday;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseAnimation, _scaleAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isActive ? Colors.orange.shade100 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      isActive ? Colors.orange.shade300 : Colors.grey.shade300,
                  width: 2,
                ),
                boxShadow:
                    isActive
                        ? [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ]
                        : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Ícone de fogo com animação
                  Transform.scale(
                    scale: isActive ? _pulseAnimation.value : 1.0,
                    child: Icon(
                      Icons.local_fire_department,
                      color:
                          isActive
                              ? Colors.orange.shade600
                              : Colors.grey.shade400,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Contador de streak
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.currentStreak}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color:
                              isActive
                                  ? Colors.orange.shade800
                                  : Colors.grey.shade600,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.currentStreak == 1 ? 'dia' : 'dias',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color:
                              isActive
                                  ? Colors.orange.shade600
                                  : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Widget para mostrar conquista de streak
class StreakAchievementDialog extends StatefulWidget {
  final int streakDays;
  final String title;
  final String description;

  const StreakAchievementDialog({
    super.key,
    required this.streakDays,
    required this.title,
    required this.description,
  });

  @override
  State<StreakAchievementDialog> createState() =>
      _StreakAchievementDialogState();
}

class _StreakAchievementDialogState extends State<StreakAchievementDialog>
    with TickerProviderStateMixin {
  late AnimationController _fireworksController;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _fireworksController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // Iniciar animações
    _scaleController.forward();
    _fireworksController.repeat();
  }

  @override
  void dispose() {
    _fireworksController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Ícone de fogo animado
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Efeito de brilho
                      AnimatedBuilder(
                        animation: _fireworksController,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _fireworksController.value * 2 * 3.14159,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    Colors.orange.withOpacity(0.3),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      // Ícone principal
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.local_fire_department,
                          size: 48,
                          color: Colors.orange.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Título da conquista
                  Text(
                    widget.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // Descrição
                  Text(
                    widget.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Botão de fechar
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text('Continuar'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Widget para mostrar ativação da sequência
class StreakActivationFeedback extends StatefulWidget {
  final VoidCallback? onComplete;

  const StreakActivationFeedback({super.key, this.onComplete});

  @override
  State<StreakActivationFeedback> createState() =>
      _StreakActivationFeedbackState();
}

class _StreakActivationFeedbackState extends State<StreakActivationFeedback>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          size: 48,
                          color: Colors.orange.shade600,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sequência Ativada!',
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
