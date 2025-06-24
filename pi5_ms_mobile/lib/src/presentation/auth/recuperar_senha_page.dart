import 'package:flutter/material.dart';
import 'package:pi5_ms_mobile/src/shared/theme.dart';
import 'package:pi5_ms_mobile/src/components/input_widget.dart';
import 'package:pi5_ms_mobile/src/components/button_widget.dart';
import 'package:pi5_ms_mobile/src/presentation/auth/verificar_codigo_page.dart';

class RecuperaSenhaPage extends StatefulWidget {
  const RecuperaSenhaPage({super.key});

  @override
  State<RecuperaSenhaPage> createState() => _RecuperaSenhaPageState();
}

class _RecuperaSenhaPageState extends State<RecuperaSenhaPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  late AnimationController _controller;
  late Animation<double> _breathingAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _breathingAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Widget _buildBreathingWidget(Widget child) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(scale: _breathingAnimation.value, child: child);
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: MaterialTheme(Theme.of(context).textTheme).light(),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                flex: 7,
                child: ClipPath(
                  clipper: BottomWaveClipper(),
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/login_header.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    padding: const EdgeInsets.only(
                      left: 24,
                      right: 24,
                      top: 10,
                      bottom: 30,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Stack(
                            children: [
                              Align(
                                alignment: Alignment.topLeft,
                                child: IconButton(
                                  icon: Icon(
                                    Icons.arrow_back_ios,
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                              Align(
                                alignment: Alignment.topRight,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Meu Estudo',
                                      style: TextStyle(
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.onPrimary,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                            0.04,
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    _buildBreathingWidget(
                                      Image.asset(
                                        'assets/images/logo.png',
                                        width:
                                            MediaQuery.of(context).size.width *
                                            0.18,
                                        height:
                                            MediaQuery.of(context).size.width *
                                            0.18,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.onPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 30),
                            child: Text(
                              'Recuperar\nsenha',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.07,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 11,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.85,
                        child: InputWidget(
                          labelText: 'EMAIL',
                          hintText: 'edgar@gmail.com',
                          controller: _emailController,
                        ),
                      ),
                      const SizedBox(height: 40),
                      _buildBreathingWidget(
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.85,
                          child: ButtonWidget(
                            text: 'Enviar código',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => const VerificaCodigoPage(),
                                ),
                              );
                            },
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Voltar ao login',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Roboto',
                            color: Theme.of(context).colorScheme.primary,
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
      ),
    );
  }
}

class BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 40);

    path.quadraticBezierTo(
      size.width * 0.25,
      size.height - 100,
      size.width * 0.5,
      size.height - 40,
    );

    path.quadraticBezierTo(
      size.width * 0.75,
      size.height + 20,
      size.width,
      size.height - 40,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
