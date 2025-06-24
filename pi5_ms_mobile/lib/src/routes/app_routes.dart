import 'package:flutter/material.dart';
import 'package:pi5_ms_mobile/src/presentation/auth/login_page.dart';
import 'package:pi5_ms_mobile/src/presentation/inicio_page.dart';
import 'package:pi5_ms_mobile/src/presentation/auth/registro_page.dart';
import 'package:pi5_ms_mobile/src/presentation/splash/splash_page.dart';
import 'package:pi5_ms_mobile/src/presentation/materias/materias_listagem_page.dart';
import 'package:pi5_ms_mobile/src/presentation/materias/adicionar_materia_page.dart';
import 'package:pi5_ms_mobile/src/presentation/provas/provas_listagem_page.dart';
import 'package:pi5_ms_mobile/src/presentation/provas/adicionar_prova_page.dart';
import 'package:pi5_ms_mobile/src/presentation/provas/editar_prova_page.dart';
import 'package:pi5_ms_mobile/src/presentation/cronograma/cronograma_page.dart';

import 'package:pi5_ms_mobile/src/presentation/desempenho/desempenho_page.dart';
import 'package:pi5_ms_mobile/src/presentation/user/perfil_usuario_page.dart';
import 'package:pi5_ms_mobile/src/components/scaffold_widget.dart';
import 'package:pi5_ms_mobile/src/shared/services/auth_service.dart';

class AppRoutes {
  // 🌊 ROTA DA SPLASH SCREEN
  static const String splash = '/splash';

  // 🔐 ROTAS DE AUTENTICAÇÃO
  static const String login = '/login';
  static const String register = '/register';

  // 🏠 ROTAS PRINCIPAIS
  static const String initial = '/';
  static const String home = '/home';

  // 📚 ROTAS FUNCIONAIS (usando páginas existentes)
  static const String inicio = '/inicio';
  static const String materias = '/materias/listagem';
  static const String materiasAdd = '/materias/adicionar';
  static const String provas = '/provas';
  static const String provasAdd = '/provas/adicionar';
  static const String provasEditar = '/provas/editar';
  static const String cronograma = '/cronograma';
  static const String estudos = '/estudos';

  static const String desempenho = '/desempenho';
  static const String perfil = '/perfil';

  // 🛡️ INSTÂNCIA DO AUTHSERVICE
  static final AuthService _authService = AuthService();

  /// 🗺️ MAPA DE ROTAS
  static Map<String, WidgetBuilder> get routes {
    return {
      initial: (context) => const SplashPage(),
      splash: (context) => const SplashPage(),
      login: (context) => LoginPage(onLogin: () => _handleLogin(context)),
      register: (context) => const SignupPage(),
      home: (context) => _protectedRoute(context, const ScaffoldWidget()),
      inicio: (context) => _protectedRoute(context, const InicioPage()),
      materias:
          (context) =>
              _protectedRoute(context, _getMateriaListagemPage(context)),
      materiasAdd:
          (context) =>
              _protectedRoute(context, _getMateriaAdicionarPage(context)),
      provas: (context) => _protectedRoute(context, const ProvasListagemPage()),
      provasAdd:
          (context) => _protectedRoute(context, const AdicionarProvaPage()),
      provasEditar:
          (context) => _protectedRoute(context, _getProvaEditarPage(context)),
      cronograma: (context) => _protectedRoute(context, const CronogramaPage()),
      estudos:
          (context) => _protectedRoute(context, const ProvasListagemPage()),

      desempenho: (context) => _protectedRoute(context, const DesempenhoPage()),
      perfil: (context) => _protectedRoute(context, const PerfilUsuarioPage()),
    };
  }

  /// 🔒 ROTA PROTEGIDA (requer autenticação)
  static Widget _protectedRoute(BuildContext context, Widget page) {
    // Verificar se está logado
    if (!_authService.isAuthenticated) {
      // Redirecionar para login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, login);
      });
      return const _LoadingPage(message: 'Verificando autenticação...');
    }
    return page;
  }

  /// ✅ HANDLER PARA LOGIN BEM-SUCEDIDO
  static void _handleLogin(BuildContext context) {
    Navigator.pushReplacementNamed(context, home);
  }

  /// 🚪 LOGOUT E REDIRECIONAMENTO
  static Future<void> logout(BuildContext context) async {
    await _authService.logout();
    Navigator.pushNamedAndRemoveUntil(context, login, (route) => false);
  }

  // === HELPERS PARA PÁGINAS COM PARÂMETROS === //
  static Widget _getMateriaListagemPage(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    return MateriasListagemPage(
      title: args?['title'] ?? 'Matérias',
      provaId: args?['provaId']?.toString() ?? '',
    );
  }

  static Widget _getMateriaAdicionarPage(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    return AdicionarMateriaPage(materias: args?['materias'] ?? <String>[]);
  }

  static Widget _getProvaEditarPage(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args == null || args['prova'] == null) {
      // Se não há prova para editar, volta para a listagem
      Future.microtask(() => Navigator.pushReplacementNamed(context, provas));
      return const SizedBox.shrink();
    }
    return EditProvaPage(prova: args['prova']);
  }
}

/// 🔄 TELA DE LOADING
class _LoadingPage extends StatelessWidget {
  final String message;

  const _LoadingPage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(message, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
