import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pi5_ms_mobile/src/providers/auth_provider.dart';
import 'package:pi5_ms_mobile/src/shared/theme.dart';
import 'package:pi5_ms_mobile/src/components/input_widget.dart';
import 'package:pi5_ms_mobile/src/components/button_widget.dart';
import 'package:pi5_ms_mobile/src/presentation/SignupPage.dart';
import 'package:pi5_ms_mobile/src/presentation/RecuperaSenhaPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() {
      _errorMessage = null;
    });
    
    if (_formKey.currentState?.validate() ?? false) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.login(
        _emailController.text,
        _passwordController.text,
      );

      if (authProvider.isAuthenticated) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else if (authProvider.error != null && mounted) {
        setState(() {
          _errorMessage = authProvider.error;
        });
        _showErrorSnackBar(authProvider.error!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final primaryColor = const Color(0xff3a608f);

    return Theme(
      data: MaterialTheme(Theme.of(context).textTheme).light(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FF),
        body: Column(
          children: [
            // Header com imagem e logo
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
                      const SizedBox(height: 30),
                      // Logo e nome do app
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                      const Spacer(),
                      // Mensagem principal
                      const Padding(
                        padding: EdgeInsets.only(bottom: 60),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Cadastre-se agora e organize\nseu caminho para a aprovação',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white, 
                              fontSize: 22,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Formulário de login
            Expanded(
              flex: 8,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Campo Email
                      SizedBox(
                        width: 300,
                        height: 56,
                        child: InputWidget(
                          labelText: 'EMAIL',
                          hintText: 'Digite seu e-mail',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          errorText: _errorMessage != null && _errorMessage!.toLowerCase().contains('email') 
                            ? 'E-mail inválido' 
                            : null,
                        ),
                      ),
                      const SizedBox(height: 24),
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
                          errorText: _errorMessage != null && _errorMessage!.toLowerCase().contains('senha') 
                            ? 'Senha incorreta' 
                            : null,
                        ),
                      ),
                      // Link Esqueceu Senha
                      SizedBox(
                        width: 300,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const RecuperaSenhaPage()),
                              );
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                            child: const Text(
                              'Esqueceu a senha?',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Roboto',
                                color: Color(0xFF3A608F),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Botão Entrar
                      SizedBox(
                        width: 300,
                        child: ButtonWidget(
                          text: authProvider.isLoading ? 'Entrando...' : 'ENTRAR',
                          onPressed: authProvider.isLoading ? null : _handleLogin,
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
                      // Botão Criar Conta
                      SizedBox(
                        width: 300,
                        child: ButtonWidget(
                          text: 'CRIAR CONTA',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SignupPage()),
                            );
                          },
                          color: Colors.white,
                          textColor: primaryColor,
                          textStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Roboto',
                            color: primaryColor,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: primaryColor, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
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
    path.lineTo(0, size.height - 70); 

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
