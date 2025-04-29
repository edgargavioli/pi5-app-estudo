import 'package:flutter/material.dart';
import 'package:pi5_ms_mobile/src/shared/theme.dart';
import 'package:pi5_ms_mobile/src/components/input_widget.dart';
import 'package:pi5_ms_mobile/src/components/button_widget.dart';
import 'package:pi5_ms_mobile/src/presentation/LoginPage.dart';
import 'package:pi5_ms_mobile/src/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class NovaSenhaPage extends StatefulWidget {
  final String inputToken;

  const NovaSenhaPage({
    super.key,
    required this.inputToken,
  });

  @override
  State<NovaSenhaPage> createState() => _NovaSenhaPageState();
}

class _NovaSenhaPageState extends State<NovaSenhaPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;
  late String _token;
  
  @override
  void initState() {
    super.initState();
    _token = _extractToken(widget.inputToken);
  }

  String _extractToken(String input) {
    if (input.isEmpty) {
      throw Exception('Token não fornecido');
    }
    
    // Verifica se é uma URL com parâmetro token
    if (input.contains('token=')) {
      final uri = Uri.parse(input);
      final token = uri.queryParameters['token'];
      if (token != null && token.isNotEmpty) {
        return token;
      }
    }
    
    // Verifica se é um link completo sem parâmetro de consulta (o token pode estar no caminho)
    if (input.startsWith('http') || input.startsWith('www')) {
      final uri = Uri.parse(input);
      final pathSegments = uri.pathSegments;
      if (pathSegments.isNotEmpty) {
        // Assume que o último segmento do caminho é o token
        return pathSegments.last;
      }
    }
    
    // Assume que o input é o próprio token
    return input;
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(8),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Senha redefinida com sucesso',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Color(0xff3a608f),
            ),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sua senha foi alterada com sucesso.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'Agora você pode entrar com sua nova senha.',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o diálogo
                // Navega para a tela de login
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: const Text(
                'Ir para login',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff3a608f),
                ),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        );
      },
    );
  }

  Future<void> _resetPassword() async {
    setState(() {
      _errorMessage = null;
    });
    
    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorSnackBar('As senhas não coincidem');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await context.read<AuthProvider>().resetPassword(
        _token,
        _passwordController.text,
      );
      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
        _showErrorSnackBar(_errorMessage!);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xff3a608f);
    
    return Theme(
      data: MaterialTheme(Theme.of(context).textTheme).light(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FF),
        body: Column(
          children: [
            // Header com imagem e título
            Expanded(
              flex: 6,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Topo com botão de voltar e logo
                      Padding(
                        padding: const EdgeInsets.only(top: 30.0),
                        child: Stack(
                          children: [
                            // Botão voltar
                            Align(
                              alignment: Alignment.topLeft,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.arrow_back_ios,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                tooltip: 'Voltar para verificação de código',
                              ),
                            ),
                            // Logo e nome do app
                            Align(
                              alignment: Alignment.topRight,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Meu Estudo',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Image.asset(
                                    'assets/images/logo.png',
                                    width: 70,
                                    height: 70,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Título principal
                      Padding(
                        padding: const EdgeInsets.only(left: 30, bottom: 60),
                        child: const Text(
                          'Defina sua\nnova senha',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Formulário
            Expanded(
              flex: 8,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Texto explicativo
                    const Padding(
                      padding: EdgeInsets.only(bottom: 30),
                      child: Text(
                        'Crie uma nova senha para sua conta. Use uma senha forte com letras, números e símbolos.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF4A4A4A),
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ),
                    // Campo Senha
                    SizedBox(
                      width: 300,
                      height: 56,
                      child: InputWidget(
                        labelText: 'SENHA',
                        hintText: 'Digite sua nova senha',
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey,
                            size: 22,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Campo Confirmar Senha
                    SizedBox(
                      width: 300,
                      height: 56,
                      child: InputWidget(
                        labelText: 'CONFIRMAR SENHA',
                        hintText: 'Digite sua senha novamente',
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey,
                            size: 22,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Botão Salvar
                    SizedBox(
                      width: 300,
                      child: ButtonWidget(
                        text: _isLoading ? 'SALVANDO...' : 'SALVAR NOVA SENHA',
                        onPressed: _isLoading ? null : _resetPassword,
                        color: primaryColor,
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto',
                          color: Colors.white,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Link para Login
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: primaryColor,
                      ),
                      child: const Text(
                        'Cancelar e voltar ao login',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Roboto',
                          color: Color(0xFF3A608F),
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

class BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 70); // lower start

    path.quadraticBezierTo(
      size.width * 0.25,
      size.height - 110,
      size.width * 0.5,
      size.height - 70,
    );

    path.quadraticBezierTo(
      size.width * 0.75,
      size.height - 30,
      size.width,
      size.height - 70,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
