import 'package:flutter/material.dart';
import 'package:pi5_ms_mobile/src/shared/theme.dart';
import 'package:pi5_ms_mobile/src/components/input_widget.dart';
import 'package:pi5_ms_mobile/src/components/button_widget.dart';
import 'package:pi5_ms_mobile/src/presentation/LoginPage.dart';
import 'package:pi5_ms_mobile/src/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});
 
  @override
  State<SignupPage> createState() => _SignupPageState();
}
 
class _SignupPageState extends State<SignupPage> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
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

  void _showVerificationDialog() {
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
                'Enviamos um link de verificação para o seu e-mail.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'Por favor, verifique sua caixa de entrada e clique no link para ativar sua conta antes de fazer login.',
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
                'Entendi',
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

  Future<void> _signup() async {
    setState(() {
      _errorMessage = null;
    });
    
    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorSnackBar('As senhas não coincidem');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await context.read<AuthProvider>().register(
        _nameController.text,
        _emailController.text,
        _passwordController.text,
      );
      if (mounted) {
        // Cadastro bem-sucedido, exibe diálogo de verificação de e-mail
        _showVerificationDialog();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          // Verifica se o erro está relacionado a email existente
          final errorString = e.toString().toLowerCase();
          if (errorString.contains('email') && 
              (errorString.contains('already exists') || 
               errorString.contains('já existe') || 
               errorString.contains('already in use') || 
               errorString.contains('já em uso'))) {
            _errorMessage = 'Este e-mail já está cadastrado. Por favor, use outro e-mail.';
          } else {
            _errorMessage = 'Erro no cadastro: ${e.toString()}';
          }
          _showErrorSnackBar(_errorMessage!);
        });
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
                          'Crie a sua\nconta',
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
              flex: 10,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Campo Nome
                    SizedBox(
                      width: 300,
                      height: 56,
                      child: InputWidget(
                        labelText: 'NOME',
                        hintText: 'Digite seu nome completo',
                        controller: _nameController,
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Campo Email
                    SizedBox(
                      width: 300,
                      height: 56,
                      child: InputWidget(
                        labelText: 'EMAIL',
                        hintText: 'Digite seu e-mail',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        errorText: _errorMessage != null && _errorMessage!.contains('e-mail já está cadastrado') 
                          ? 'E-mail já cadastrado' 
                          : null,
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Campo Senha
                    SizedBox(
                      width: 300,
                      height: 56,
                      child: InputWidget(
                        labelText: 'SENHA',
                        hintText: 'Digite sua senha',
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
                    const SizedBox(height: 18),
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
                    // Botão Criar Conta
                    SizedBox(
                      width: 300,
                      child: ButtonWidget(
                        text: _isLoading ? 'Criando conta...' : 'CRIAR CONTA',
                        onPressed: _isLoading ? null : _signup,
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
                        'Já tem conta? Entre aqui',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Roboto',
                          color: Color(0xFF3A608F),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}

// Clipper para a onda na parte inferior do cabeçalho
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
