import 'package:flutter/material.dart';
import 'package:pi5_ms_mobile/src/shared/theme.dart';
import 'package:pi5_ms_mobile/src/components/input_widget.dart';
import 'package:pi5_ms_mobile/src/components/button_widget.dart';
import 'package:pi5_ms_mobile/src/presentation/LoginPage.dart';
import 'package:pi5_ms_mobile/src/presentation/NovaSenhaPage.dart';
import 'package:pi5_ms_mobile/src/presentation/RecuperaSenhaPage.dart';
import 'package:pi5_ms_mobile/src/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class VerificaCodigoPage extends StatefulWidget {
  const VerificaCodigoPage({super.key});

  @override
  State<VerificaCodigoPage> createState() => _VerificaCodigoPageState();
}

class _VerificaCodigoPageState extends State<VerificaCodigoPage> {
  final TextEditingController _codigoController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

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

  // Extrai o token do input do usuário (URL ou token direto)
  String _extractToken(String input) {
    if (input.isEmpty) {
      return '';
    }
    
    // Verifica se é uma URL com parâmetro token
    if (input.contains('?token=')) {
      final uri = Uri.parse(input);
      final token = uri.queryParameters['token'];
      return token ?? input;
    }
    
    // Se for um link completo sem parâmetro de query
    if (input.contains('/reset-password/')) {
      final parts = input.split('/reset-password/');
      if (parts.length > 1) {
        return parts[1];
      }
    }
    
    // Caso contrário, usa o texto como token
    return input;
  }

  Future<void> _verifyCode() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      if (_codigoController.text.isEmpty) {
        throw Exception('Por favor, digite o código de verificação');
      }

      final String input = _codigoController.text.trim();
      String token;
      
      // Verificar se o input é um código ou um link completo
      if (input.length == 8) {
        // É um código de verificação de 8 caracteres
        // Neste caso, precisamos verificar com o backend sem comparação local
        token = input;
      } else {
        // Provavelmente é um link ou token completo
        token = _extractToken(input);
        
        // Se o token extraído estiver vazio, lançar erro
        if (token.isEmpty) {
          throw Exception('Código de verificação inválido');
        }
      }
      
      // Verificar o token com o backend
      final result = await context.read<AuthProvider>().verifyResetToken(token);

      if (result) {
        if (!mounted) return;
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => NovaSenhaPage(inputToken: token),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
      
      // Mostrar mensagem de erro
      _showErrorSnackBar(_errorMessage!);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _codigoController.dispose();
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
                                tooltip: 'Voltar para recuperação de senha',
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
                          'Verifique\no código',
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
                        'Verifique seu e-mail e insira o código de verificação ou cole o link completo que enviamos.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF4A4A4A),
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ),
                    // Campo de código
                    SizedBox(
                      width: 300,
                      height: 60,
                      child: InputWidget(
                        labelText: 'CÓDIGO OU LINK',
                        hintText: 'Cole o link ou digite o código recebido',
                        controller: _codigoController,
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.none,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _verifyCode(),
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Botão Verificar
                    SizedBox(
                      width: 300,
                      child: ButtonWidget(
                        text: _isLoading ? 'VERIFICANDO...' : 'VERIFICAR',
                        onPressed: _isLoading ? null : _verifyCode,
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
                    // Link para enviar código novamente
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RecuperaSenhaPage(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: primaryColor,
                      ),
                      child: const Text(
                        'Enviar código novamente',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Roboto',
                          color: Color(0xFF3A608F),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
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
                        'Voltar ao login',
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
