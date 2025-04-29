import 'package:flutter/material.dart';
import 'package:pi5_ms_mobile/src/shared/theme.dart';
import 'package:pi5_ms_mobile/src/components/input_widget.dart';
import 'package:pi5_ms_mobile/src/components/button_widget.dart';
import 'package:pi5_ms_mobile/src/presentation/LoginPage.dart';
import 'package:pi5_ms_mobile/src/presentation/VerificaCodigoPage.dart';
import 'package:pi5_ms_mobile/src/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class RecuperaSenhaPage extends StatefulWidget {
  const RecuperaSenhaPage({super.key});

  @override
  State<RecuperaSenhaPage> createState() => _RecuperaSenhaPageState();
}

class _RecuperaSenhaPageState extends State<RecuperaSenhaPage> {
  final TextEditingController _emailController = TextEditingController();
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

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Verifique seu e-mail',
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
                'Enviamos um código de verificação para o seu e-mail.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'Por favor, verifique sua caixa de entrada e use o código para redefinir sua senha.',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o diálogo
                // Navega para a tela de verificação de código
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const VerificaCodigoPage()),
                );
              },
              child: const Text(
                'Continuar',
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

  Future<void> _recoverPassword() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      // Verifica se o campo de email está vazio
      if (_emailController.text.trim().isEmpty) {
        throw Exception('Por favor, digite um e-mail válido');
      }

      await context.read<AuthProvider>().recoverPassword(
        _emailController.text,
      );
      
      // Se chegou aqui, é porque não houve exceção
      if (mounted) {
        // Mostra diálogo de sucesso
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        // Formatar mensagem de erro para remover "Exception: "
        String errorMsg = e.toString();
        if (errorMsg.startsWith('Exception: ')) {
          errorMsg = errorMsg.substring('Exception: '.length);
        }
        
        setState(() {
          _errorMessage = errorMsg;
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
                                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                tooltip: 'Voltar para o login',
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
                          'Recupere a\nsua senha',
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
                        'Digite seu e-mail abaixo e enviaremos um link para redefinir sua senha.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF4A4A4A),
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ),
                    // Campo Email
                    SizedBox(
                      width: 300,
                      height: 56,
                      child: InputWidget(
                        labelText: 'EMAIL',
                        hintText: 'Digite seu e-mail',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        errorText: _errorMessage != null ? 'E-mail inválido' : null,
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Botão Enviar E-mail
                    SizedBox(
                      width: 300,
                      child: ButtonWidget(
                        text: _isLoading ? 'ENVIANDO...' : 'ENVIAR E-MAIL',
                        onPressed: _isLoading ? null : _recoverPassword,
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
                        Navigator.of(context).pop();
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
  
  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
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

