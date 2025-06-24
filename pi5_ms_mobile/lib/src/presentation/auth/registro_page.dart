import 'package:flutter/material.dart';
import 'package:pi5_ms_mobile/src/shared/theme.dart';
import 'package:pi5_ms_mobile/src/components/input_widget.dart';
import 'package:pi5_ms_mobile/src/components/button_widget.dart';
import 'package:pi5_ms_mobile/src/presentation/auth/login_page.dart';
import 'package:pi5_ms_mobile/src/shared/services/auth_service.dart';
import 'package:pi5_ms_mobile/src/shared/services/validation_service.dart';
import 'package:pi5_ms_mobile/src/components/password_strength_indicator.dart';
import 'package:pi5_ms_mobile/src/shared/widgets/custom_snackbar.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage>
    with SingleTickerProviderStateMixin {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  late AnimationController _controller;
  late Animation<double> _breathingAnimation;

  // 🔐 INSTÂNCIA DO SERVIÇO DE AUTENTICAÇÃO
  final AuthService _authService = AuthService();

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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _controller.dispose();
    super.dispose();
  }

  /// 📝 FAZER REGISTRO
  Future<void> _handleRegister() async {
    // Validar formulário antes de enviar
    if (!_formKey.currentState!.validate()) {
      _showErrorSnackBar('Por favor, corrija os erros no formulário');
      return;
    }

    // Validação adicional usando o ValidationService
    final validationErrors = ValidationService.validateRegistrationForm(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
    );

    final hasErrors = validationErrors.values.any((error) => error != null);
    if (hasErrors) {
      final errorMessages = validationErrors.entries
          .where((entry) => entry.value != null)
          .map((entry) => entry.value!)
          .join('\n');

      _showErrorSnackBar('Erros de validação:\n$errorMessages');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (result.success) {
        // ✅ REGISTRO SUCESSO
        if (mounted) {
          CustomSnackBar.showSuccess(
            context,
            result.message,
            duration: const Duration(seconds: 2),
          );

          // Navegar para home
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        }
      } else {
        // ❌ REGISTRO FALHOU
        _showErrorSnackBar(result.message);
      }
    } catch (e) {
      _showErrorSnackBar('Erro inesperado: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 🚨 MOSTRAR MENSAGEM DE ERRO
  void _showErrorSnackBar(String message) {
    if (mounted) {
      CustomSnackBar.showError(
        context,
        message,
        duration: const Duration(seconds: 4),
      );
    }
  }

  /// ✅ VALIDAR NOME
  String? _validateName(String? value) {
    return ValidationService.validateName(value);
  }

  /// ✅ VALIDAR EMAIL
  String? _validateEmail(String? value) {
    return ValidationService.validateEmail(value);
  }

  /// ✅ VALIDAR SENHA
  String? _validatePassword(String? value) {
    return ValidationService.validatePassword(value, isRegistration: true);
  }

  /// ✅ VALIDAR CONFIRMAÇÃO DE SENHA
  String? _validateConfirmPassword(String? value) {
    return ValidationService.validatePasswordConfirmation(
      value,
      _passwordController.text,
    );
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
        body: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top,
            ),
            child: IntrinsicHeight(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      children: [
                        ClipPath(
                          clipper: BottomWaveClipper(),
                          child: Container(
                            width: double.infinity,
                            height: 260,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(
                                  'assets/images/login_header.png',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          height: 260,
                          padding: const EdgeInsets.only(
                            left: 24,
                            right: 24,
                            top: 16,
                            bottom: 30,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 25.0),
                                child: Stack(
                                  children: [
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).padding.top +
                                          8,
                                    ),
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.arrow_back_ios,
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.onPrimary,
                                        ),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Meu Estudo',
                                            style: TextStyle(
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.onPrimary,
                                              fontSize: 25,
                                              fontFamily: 'Roboto',
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          _buildBreathingWidget(
                                            Image.asset(
                                              'assets/images/logo.png',
                                              width: 120,
                                              height: 120,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Criar Conta',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 32),
                            InputWidget(
                              controller: _nameController,
                              labelText: 'Nome',
                              hintText: 'Ex: João Silva',
                              width: double.infinity,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              validator: _validateName,
                            ),
                            const SizedBox(height: 20),
                            InputWidget(
                              controller: _emailController,
                              labelText: 'Email',
                              hintText: 'Ex: joao.silva@email.com',
                              width: double.infinity,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                              validator: _validateEmail,
                            ),
                            const SizedBox(height: 20),
                            InputWidget(
                              controller: _passwordController,
                              labelText: 'Senha',
                              hintText: 'Digite uma senha forte',
                              width: double.infinity,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  tooltip:
                                      _obscurePassword
                                          ? 'Mostrar senha'
                                          : 'Ocultar senha',
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              validator: _validatePassword,
                              onChanged: (value) {
                                setState(
                                  () {},
                                ); // Para atualizar o indicador de força
                              },
                            ),

                            // Indicador de força da senha
                            PasswordStrengthIndicator(
                              password: _passwordController.text,
                              showDetails: true,
                            ),
                            const SizedBox(height: 24),
                            InputWidget(
                              controller: _confirmPasswordController,
                              labelText: 'Confirmar Senha',
                              hintText: 'Digite a mesma senha novamente',
                              width: double.infinity,
                              obscureText: _obscureConfirmPassword,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  tooltip:
                                      _obscureConfirmPassword
                                          ? 'Mostrar senha'
                                          : 'Ocultar senha',
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirmPassword =
                                          !_obscureConfirmPassword;
                                    });
                                  },
                                ),
                              ),
                              validator: _validateConfirmPassword,
                            ),
                            const SizedBox(height: 40),
                            SizedBox(
                              width: double.infinity,
                              child: ButtonWidget(
                                text:
                                    _isLoading
                                        ? 'Criando conta...'
                                        : 'Criar Conta',
                                onPressed:
                                    _isLoading
                                        ? () {}
                                        : () => _handleRegister(),
                                color: Theme.of(context).colorScheme.primary,
                                isLoading: _isLoading,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginPage(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Já tem uma conta? Faça login',
                                style: TextStyle(fontSize: 14),
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
          ),
        ),
      ),
    );
  }
}

// Copy of the clipper used in LoginPage
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
