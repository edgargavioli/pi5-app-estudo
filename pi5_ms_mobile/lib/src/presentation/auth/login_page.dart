import 'package:flutter/material.dart';
import 'package:pi5_ms_mobile/src/shared/theme.dart';
import 'package:pi5_ms_mobile/src/components/input_widget.dart';
import 'package:pi5_ms_mobile/src/presentation/inicio_page.dart';
import 'package:pi5_ms_mobile/src/presentation/auth/registro_page.dart';
import 'package:pi5_ms_mobile/src/presentation/auth/recuperar_senha_page.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback onLogin;
  const LoginPage({super.key, required this.onLogin});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: MaterialTheme(Theme.of(context).textTheme).light(),
      child: Scaffold(
        backgroundColor: Color(0xFFF8F9FF),
        body: Column(
          children: [
            Expanded(
              flex: 1,
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
                  padding: EdgeInsets.only(
                    left: 24,
                    right: 24,
                    top: 10,
                    bottom: 40,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 30),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Meu Estudo',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Image.asset(
                            'assets/images/logo.png',
                            width: 90,
                            height: 90,
                            color: Colors.white,
                          ),
                        ],
                      ),
                      const SizedBox(height: 80),
                      const Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Cadastre-se agora e organize\nseu caminho para a aprovação',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 22),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    SizedBox(
                      width: 300,
                      height: 56,
                      child: InputWidget(
                        labelText: 'EMAIL',
                        hintText: 'edgar@email.com',
                        controller: _emailController,
                      ),
                    ),
                    const SizedBox(height: 34),
                    SizedBox(
                      width: 300,
                      height: 56,
                      child: InputWidget(
                        labelText: 'SENHA',
                        hintText: '********',
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 0),
                    Container(
                      width: 300,
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RecuperaSenhaPage(),
                            ),
                          );
                        },
                        child: const Text(
                          'Esqueceu a Senha?',
                          style: TextStyle(color: Color(0xFF4A4A4A)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ButtonWidget(
                      text: 'Entrar',
                      onPressed: () {
                        widget.onLogin();
                        Navigator.pushReplacementNamed(context, '/home');
                      },
                      color: const Color(0xff3a608f),
                    ),
                    const SizedBox(height: 34),
                    ButtonWidget(
                      text: 'Criar conta',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignupPage(),
                          ),
                        );
                      },
                      color: const Color(0xFF73777F),
                      textColor: const Color(0xFF191C20),
                      outlined: true,
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
    _passwordController.dispose();
    super.dispose();
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

class ButtonWidget extends StatelessWidget {
  final String text;
  final TextStyle? textStyle;
  final VoidCallback onPressed;
  final Color? color;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;
  final RoundedRectangleBorder? shape;
  final bool outlined;

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

    return SizedBox(
      width: 300,
      height: 42,
      child:
          outlined
              ? OutlinedButton(
                style: style,
                onPressed: onPressed,
                child: Text(
                  text,
                  style:
                      textStyle ??
                      const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              )
              : ElevatedButton(
                style: style,
                onPressed: onPressed,
                child: Text(
                  text,
                  style:
                      textStyle ??
                      const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
    );
  }
}
