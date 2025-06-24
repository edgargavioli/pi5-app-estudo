import 'package:flutter/material.dart';
import 'package:pi5_ms_mobile/src/shared/services/auth_service.dart';
import 'package:pi5_ms_mobile/src/routes/app_routes.dart';

/// 🌊 Tela de Splash personalizada com waves e logo
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Configurar animações
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    // Iniciar sequência
    _startSplashSequence();
  }

  Future<void> _startSplashSequence() async {
    // Iniciar animação
    _animationController.forward();

    // Aguardar tempo da animação + delay adicional
    await Future.delayed(const Duration(milliseconds: 3500));

    // Navegar para próxima tela
    if (mounted) {
      await _navigateToNextScreen();
    }
  }

  Future<void> _navigateToNextScreen() async {
    final authService = AuthService();

    try {
      // Verificar se usuário está autenticado
      if (authService.isAuthenticated) {
        // Usuário logado - ir para home
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      } else {
        // Usuário não logado - ir para login
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    } catch (e) {
      // Em caso de erro, ir para login
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFF1976D2), // Cor base de fundo
        ),
        child: Stack(
          children: [
            // Background com imagem de waves
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/login_header.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // Overlay com gradient para suavizar
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF1976D2).withOpacity(0.3),
                      const Color(0xFF1565C0).withOpacity(0.5),
                    ],
                  ),
                ),
              ),
            ),

            // Conteúdo principal
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Center(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Transform.translate(
                      offset: Offset(0, _slideAnimation.value),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo com animação
                          ScaleTransition(
                            scale: _scaleAnimation,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(25),
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  width: 150,
                                  height: 150,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Título com animação
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Text(
                              'Meu Estudo',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2.0,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Subtítulo
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Text(
                              'Organize seus estudos, alcance seus objetivos',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                height: 1.4,
                              ),
                            ),
                          ),

                          const SizedBox(height: 80),

                          // Indicador de carregamento
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: SizedBox(
                              width: 50,
                              height: 50,
                              child: CircularProgressIndicator(
                                strokeWidth: 4,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
