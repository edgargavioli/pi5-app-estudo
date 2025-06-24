import 'package:flutter/material.dart';
import 'dart:math' as math;

class LevelUpFeedbackPage extends StatefulWidget {
  final int novoNivel;
  final int xpTotal;
  final int xpProximoNivel;
  final String conquista;

  const LevelUpFeedbackPage({
    super.key,
    required this.novoNivel,
    required this.xpTotal,
    required this.xpProximoNivel,
    this.conquista = '',
  });

  @override
  State<LevelUpFeedbackPage> createState() => _LevelUpFeedbackPageState();
}

class _LevelUpFeedbackPageState extends State<LevelUpFeedbackPage>
    with TickerProviderStateMixin {
  late AnimationController _explosionController;
  late AnimationController _scaleController;
  late AnimationController _textController;
  late AnimationController _particlesController;

  late Animation<double> _explosionAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _textAnimation;
  late Animation<double> _particlesAnimation;

  @override
  void initState() {
    super.initState();

    // Controladores de animação
    _explosionController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _particlesController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    // Animações
    _explosionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _explosionController, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _textAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    _particlesAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _particlesController, curve: Curves.linear),
    );

    // Iniciar animações sequenciais
    _startAnimations();
  }

  void _startAnimations() async {
    // Explosão inicial
    _explosionController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    // Escala do nível
    _scaleController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    // Texto e partículas
    _textController.forward();
    _particlesController.forward();
  }

  @override
  void dispose() {
    _explosionController.dispose();
    _scaleController.dispose();
    _textController.dispose();
    _particlesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Fundo com gradiente dourado
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [
                  Colors.amber.withOpacity(0.3),
                  Colors.deepOrange.withOpacity(0.2),
                  Colors.black,
                ],
              ),
            ),
          ),

          // Partículas animadas
          _buildParticles(),

          // Conteúdo principal
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Explosão de fundo
                AnimatedBuilder(
                  animation: _explosionAnimation,
                  builder: (context, child) {
                    return Container(
                      width: 300 * _explosionAnimation.value,
                      height: 300 * _explosionAnimation.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.amber.withOpacity(
                              0.6 * (1 - _explosionAnimation.value),
                            ),
                            Colors.orange.withOpacity(
                              0.3 * (1 - _explosionAnimation.value),
                            ),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // Nível com animação
                AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.amber,
                              Colors.orange,
                              Colors.deepOrange,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withOpacity(0.5),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'NÍVEL',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                              Text(
                                '${widget.novoNivel}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 40),

                // Texto principal com animação
                AnimatedBuilder(
                  animation: _textAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _textAnimation.value,
                      child: Transform.translate(
                        offset: Offset(0, 50 * (1 - _textAnimation.value)),
                        child: Column(
                          children: [
                            // Título principal
                            Text(
                              'PARABÉNS!',
                              style: TextStyle(
                                color: Colors.amber,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 3,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.5),
                                    offset: const Offset(2, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 16),

                            Text(
                              'Você subiu para o nível ${widget.novoNivel}!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 24),

                            // Conquista (se houver)
                            if (widget.conquista.isNotEmpty) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                    color: Colors.amber.withOpacity(0.5),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.emoji_events,
                                      color: Colors.amber,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      widget.conquista,
                                      style: TextStyle(
                                        color: Colors.amber,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],

                            // Informações de XP
                            _buildXpInfo(theme),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 50),

                // Botão continuar
                AnimatedBuilder(
                  animation: _textAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _textAnimation.value,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 8,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'CONTINUAR',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildXpInfo(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: [
          Text(
            'XP Total: ${widget.xpTotal}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Próximo nível: ${widget.xpProximoNivel} XP',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildParticles() {
    return AnimatedBuilder(
      animation: _particlesAnimation,
      builder: (context, child) {
        return Stack(
          children: List.generate(30, (index) {
            final random = math.Random(index);
            final size = MediaQuery.of(context).size;

            return Positioned(
              left: random.nextDouble() * size.width,
              top: random.nextDouble() * size.height,
              child: Transform.rotate(
                angle:
                    _particlesAnimation.value *
                    2 *
                    math.pi *
                    (index % 2 == 0 ? 1 : -1),
                child: Opacity(
                  opacity:
                      (math.sin(_particlesAnimation.value * math.pi * 2) + 1) /
                      2 *
                      0.8,
                  child: Icon(
                    [Icons.star, Icons.auto_awesome, Icons.flash_on][index % 3],
                    color:
                        [Colors.amber, Colors.orange, Colors.yellow][index % 3],
                    size: 12 + (random.nextDouble() * 8),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
