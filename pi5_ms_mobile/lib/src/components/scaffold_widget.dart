import 'package:flutter/material.dart';
import 'package:pi5_ms_mobile/src/components/appbar_widget.dart';
import 'package:pi5_ms_mobile/src/components/drawer_widget.dart';
import 'package:pi5_ms_mobile/src/components/navigation_widget.dart';

class ScaffoldWidget extends StatefulWidget {
  final Widget body;
  final int currentPage;

  const ScaffoldWidget({
    super.key,
    required this.body,
    required this.currentPage,
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
          MenuItem(label: "Início", icon: Icons.home),
          MenuItem(label: "Provas", icon: Icons.article),
          MenuItem(label: "Cronograma", icon: Icons.calendar_today),
          MenuItem(label: "Matérias", icon: Icons.book),
          MenuItem(label: "Desenpenho", icon: Icons.assessment),
          MenuItem(label: "Histórico", icon: Icons.history),
          MenuItem(label: "Perfil", icon: Icons.person),
        ],
      ), // opcional
      body: widget.body,
      bottomNavigationBar: NavigationWidget(currentIndex: widget.currentPage),
    );
  }
}
