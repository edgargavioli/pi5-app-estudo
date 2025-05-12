import 'package:flutter/material.dart';
import 'package:pi5_ms_mobile/src/components/appbar_widget.dart';
import 'package:pi5_ms_mobile/src/components/drawer_widget.dart';
import 'package:pi5_ms_mobile/src/components/navigation_widget.dart';

class ScaffoldWidget extends StatefulWidget {
  final Widget body;
  final int currentPage;
  final Widget? floatingActionButton;

  const ScaffoldWidget({
    super.key,
    required this.body,
    required this.currentPage,
    this.floatingActionButton,
  });

  @override
  State<ScaffoldWidget> createState() => _ScaffoldWidgetState();
}

class _ScaffoldWidgetState extends State<ScaffoldWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(),
      drawer: DrawerWidget(
        menuItems: [
          MenuItem(
            label: "Início",
            icon: Icons.calendar_today,
            onTap: () => Navigator.pushNamed(context, '/home'),
          ),
          MenuItem(
            label: "Provas",
            icon: Icons.article,
            onTap: () => Navigator.pushNamed(context, '/provas'),
          ),
          MenuItem(
            label: "Cronograma",
            icon: Icons.calendar_today,
            onTap: () => Navigator.pushNamed(context, '/cronograma'),
          ),
          MenuItem(label: "Matérias", icon: Icons.book),
          MenuItem(
            label: "Desempenho", 
            icon: Icons.assessment,
            onTap: () => Navigator.pushNamed(context, '/desempenho'),
          ),
          MenuItem(
            label: "Histórico", 
            icon: Icons.history,
            onTap: () => Navigator.pushNamed(context, '/historico'),
          ),
          MenuItem(label: "Perfil", icon: Icons.person),
        ],
      ), // opcional
      body: widget.body,
      floatingActionButton: widget.floatingActionButton,
      bottomNavigationBar: NavigationWidget(currentIndex: widget.currentPage),
    );
  }
}
