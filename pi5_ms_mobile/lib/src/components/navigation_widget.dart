import 'package:flutter/material.dart';

class NavigationWidget extends StatefulWidget {
  final int currentPage;

  const NavigationWidget({super.key, required this.currentPage});

  @override
  State<NavigationWidget> createState() => _NavigationWidgetState();
}

class _NavigationWidgetState extends State<NavigationWidget> {
  late int _selectedIndex;

  final List<NavigationDestination> destinations = [
    const NavigationDestination(icon: Icon(Icons.home), label: 'Início'),
    const NavigationDestination(icon: Icon(Icons.article), label: 'Provas'),
    const NavigationDestination(
      icon: Icon(Icons.calendar_today),
      label: 'Cronograma',
    ),
    const NavigationDestination(icon: Icon(Icons.history), label: 'Histórico'),
    const NavigationDestination(
      icon: Icon(Icons.assessment),
      label: 'Desempenho',
    ),
    const NavigationDestination(icon: Icon(Icons.person), label: 'Perfil'),
  ];

  final List<String> routes = [
    '/home',
    '/provas',
    '/cronograma',
    '/historico',
    '/desempenho',
    '/perfil',
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentPage;
  }

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: _selectedIndex,
      destinations: destinations,
      onDestinationSelected: _onDestinationSelected,
    );
  }
}
