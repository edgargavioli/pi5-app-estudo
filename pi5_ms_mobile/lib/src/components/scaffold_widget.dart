import 'package:flutter/material.dart';
import 'package:pi5_ms_mobile/src/components/appbar_widget.dart';
import 'package:pi5_ms_mobile/src/components/drawer_widget.dart';
import 'package:pi5_ms_mobile/src/components/navigation_widget.dart';
import 'package:pi5_ms_mobile/src/presentation/CronogramaPage.dart';
import 'package:pi5_ms_mobile/src/presentation/DesempenhoPage.dart';
import 'package:pi5_ms_mobile/src/presentation/HomePage.dart';
import 'package:pi5_ms_mobile/src/presentation/historico/HistoricoPage.dart';
import 'package:pi5_ms_mobile/src/presentation/provas/ProvasListagemPage.dart';
import 'package:pi5_ms_mobile/src/presentation/user/UserProfilePageMain.dart';

class ScaffoldWidget extends StatefulWidget {
  final Widget body;
  final int currentPage;
  final Widget? floatingActionButton;
  final AppBar? appBar;

  const ScaffoldWidget({
    super.key,
    required this.body,
    required this.currentPage,
    this.floatingActionButton,
    this.appBar,
  });

  @override
  State<ScaffoldWidget> createState() => _ScaffoldWidgetState();
}

class _ScaffoldWidgetState extends State<ScaffoldWidget> {
  final List<String> _routes = [
    '/home',
    '/provas',
    '/cronograma',
    '/historico',
    '/desempenho',
    '/perfil',
  ];

  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.currentPage;
  }

  void _navigateTo(int index) {
    if (index >= 0 && index < _routes.length) {
      setState(() {
        _currentPage = index; // Atualiza o índice atual
      });
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) {
            return _getPageByRoute(_routes[index]);
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0); // Começa da direita
            const end = Offset.zero; // Termina no centro
            const curve = Curves.easeInOut;

            var tween = Tween(
              begin: begin,
              end: end,
            ).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(position: offsetAnimation, child: child);
          },
        ),
      );
    }
  }

  Widget _getPageByRoute(String route) {
    switch (route) {
      case '/home':
        return const HomePage(title: "PI5 MS Mobile");
      case '/provas':
        return const ProvaslistagemPage();
      case '/cronograma':
        return const CronogramaPage();
      case '/historico':
        return const HistoricoPage();
      case '/desempenho':
        return const DesempenhoPage();
      case '/perfil':
        return const UserProfilePageMain();
      default:
        return const HomePage(title: "PI5 MS Mobile");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.appBar ?? AppBarWidget(),
      drawer: DrawerWidget(
        menuItems: [
          MenuItem(
            label: "Início",
            icon: Icons.calendar_today,
            onTap: () => _navigateTo(0),
          ),
          MenuItem(
            label: "Provas",
            icon: Icons.article,
            onTap: () => _navigateTo(1),
          ),
          MenuItem(
            label: "Cronograma",
            icon: Icons.calendar_today,
            onTap: () => _navigateTo(2),
          ),
          MenuItem(label: "Matérias", icon: Icons.book),
          MenuItem(
            label: "Desempenho",
            icon: Icons.assessment,
            onTap: () => _navigateTo(4),
          ),
          MenuItem(
            label: "Histórico",
            icon: Icons.history,
            onTap: () => _navigateTo(3),
          ),
          MenuItem(
            label: "Perfil",
            icon: Icons.person,
            onTap: () => _navigateTo(5),
          ),
        ],
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null) {
            if (details.primaryVelocity! < 0) {
              // Deslizar para a esquerda (próxima página)
              _navigateTo(_currentPage + 1);
            } else if (details.primaryVelocity! > 0) {
              // Deslizar para a direita (página anterior)
              _navigateTo(_currentPage - 1);
            }
          }
        },
        child: widget.body,
      ),
      floatingActionButton: widget.floatingActionButton,
      bottomNavigationBar: NavigationWidget(currentPage: _currentPage),
    );
  }
}
