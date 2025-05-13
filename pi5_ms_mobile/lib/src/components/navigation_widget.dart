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
    const NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
    const NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
    const NavigationDestination(
      icon: Icon(Icons.notifications),
      label: 'Notifications',
    ),
    const NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
  ];

  final List<String> routes = ['/home', '/provas', '/historico', '/profile'];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentPage;
  }

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pushNamed(context, routes[index]);
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
