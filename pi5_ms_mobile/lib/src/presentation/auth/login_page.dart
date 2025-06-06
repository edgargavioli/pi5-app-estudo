import 'package:flutter/material.dart';
import 'package:pi5_ms_mobile/src/shared/theme.dart';
import 'package:pi5_ms_mobile/src/components/input_widget.dart';
import 'package:pi5_ms_mobile/src/presentation/auth/registro_page.dart';
import 'package:pi5_ms_mobile/src/presentation/auth/recuperar_senha_page.dart';
import 'package:pi5_ms_mobile/src/shared/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback? onLogin;
  const LoginPage({super.key, this.onLogin});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isLoading = false;
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
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _controller.dispose();
    super.dispose();
  }

  /// 🔐 FAZER LOGIN
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (result.success) {
        // ✅ LOGIN SUCESSO
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // Callback para notificar sucesso
        widget.onLogin?.call();
        
        // Navegar para home
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        // ❌ LOGIN FALHOU
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

  /// ⚠️ MOSTRAR ERRO
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// ✅ VALIDAR EMAIL
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email é obrigatório';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Email inválido';
    }
    return null;
  }

  /// ✅ VALIDAR SENHA
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Senha é obrigatória';
    }
    // Não validar tamanho no login - usuários podem ter senhas antigas válidas
    return null;
  }

  Widget _buildBreathingWidget(Widget child) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _breathingAnimation.value,
          child: child,
        );
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
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
              ),
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
                                image: AssetImage('assets/images/login_header.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          height: 260,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Meu Estudo',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onPrimary,
                                      fontSize: 18,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  _buildBreathingWidget(
                                    Image.asset(
                                      'assets/images/logo.png',
                                      width: 80,
                                      height: 80,
                                      color: Theme.of(context).colorScheme.onPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Cadastre-se agora e organize\nseu caminho para a aprovação',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onPrimary,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                      shadows: [
                                        Shadow(
                                          offset: const Offset(0, 1),
                                          blurRadius: 3.0,
                                          color: Colors.black.withOpacity(0.3),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Entre na sua conta',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Roboto',
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Acesse sua conta para continuar seus estudos',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Roboto',
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 40),
                          
                          // 📧 EMAIL
                          InputWidget(
                            controller: _emailController,
                            labelText: 'Email',
                            hintText: 'Digite seu email',
                            width: double.infinity,
                            keyboardType: TextInputType.emailAddress,
                            validator: _validateEmail,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.email_outlined),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // 🔑 SENHA
                          InputWidget(
                            controller: _passwordController,
                            labelText: 'Senha',
                            hintText: 'Digite sua senha',
                            width: double.infinity,
                            obscureText: _obscurePassword,
                            validator: _validatePassword,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _handleLogin(),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          
                          // 🔐 BOTÃO LOGIN
                          _buildBreathingWidget(
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.85,
                              child: ButtonWidget(
                                text: _isLoading ? 'Entrando...' : 'Entrar',
                                onPressed: _isLoading ? () {} : _handleLogin,
                                color: Theme.of(context).colorScheme.primary,
                                isLoading: _isLoading,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // 🔗 ESQUECEU SENHA
                          TextButton(
                            onPressed: _isLoading ? null : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RecuperaSenhaPage(),
                                ),
                              );
                            },
                            child: Text(
                              'Esqueceu a Senha?',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Roboto',
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // 📝 BOTÃO CRIAR CONTA
                          _buildBreathingWidget(
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.85,
                              child: ButtonWidget(
                                text: 'Criar conta',
                                onPressed: _isLoading ? () {} : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const SignupPage(),
                                    ),
                                  );
                                },
                                color: Theme.of(context).colorScheme.secondary,
                                textColor: Theme.of(context).colorScheme.onSecondary,
                                outlined: true,
                              ),
                            ),
                          ),
                        ],
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

class BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 60);

    path.quadraticBezierTo(
      size.width * 0.25,
      size.height - 120,
      size.width * 0.5,
      size.height - 60,
    );

    path.quadraticBezierTo(
      size.width * 0.75,
      size.height - 20,
      size.width,
      size.height - 60,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class ButtonWidget extends StatelessWidget {
  final String text;
  final TextStyle? textStyle;
  final VoidCallback onPressed;
  final Color? color;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;
  final RoundedRectangleBorder? shape;
  final bool outlined;
  final bool isLoading;

  const ButtonWidget({
    super.key,
    required this.text,
    this.textStyle,
    required this.onPressed,
    this.shape,
    this.padding,
    this.color,
    this.textColor,
    this.outlined = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorSelected = color ?? Color(0xFF2F5C9A);
    final textColorSelected = textColor ?? Color(0xFFFFFFFF);

    final style = ButtonStyle(
      backgroundColor:
          outlined
              ? WidgetStateProperty.all(Colors.transparent)
              : WidgetStateProperty.all(colorSelected),
      foregroundColor: WidgetStateProperty.all(textColorSelected),
      padding: WidgetStateProperty.all(
        padding ?? const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      ),
      minimumSize: WidgetStateProperty.all(const Size.fromHeight(48)),
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
        shape ??
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side:
                  outlined
                      ? BorderSide(color: colorSelected, width: 1.4)
                      : BorderSide.none,
            ),
      ),
      elevation: WidgetStateProperty.all(outlined ? 0 : 2),
    );

    // 🎛️ CONTEÚDO DO BOTÃO (com ou sem loading)
    Widget buttonContent = isLoading
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(textColorSelected),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                text,
                style: textStyle ??
                    const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          )
        : Text(
            text,
            style: textStyle ??
                const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
          );

    return SizedBox(
      width: 300,
      height: 42,
      child: outlined
          ? OutlinedButton(
              style: style,
              onPressed: isLoading ? null : onPressed,
              child: buttonContent,
            )
          : ElevatedButton(
              style: style,
              onPressed: isLoading ? null : onPressed,
              child: buttonContent,
            ),
    );
  }
}
