import 'package:flutter/material.dart';

class BottonNavBarWidget extends StatefulWidget {
  final PageController pageController;
  final ValueNotifier<int> currentIndex;

  const BottonNavBarWidget({
    super.key,
    required this.pageController,
    required this.currentIndex,
  });

  @override
  State<BottonNavBarWidget> createState() => _BottonNavBarWidgetState();
}

class _BottonNavBarWidgetState extends State<BottonNavBarWidget> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: widget.currentIndex,
      builder: (context, currentIndex, _) {
        return Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
              width: 0.5,
            ),
          ),
          child: NavigationBar(
            backgroundColor: Theme.of(context).colorScheme.surface,
            selectedIndex: currentIndex,
            onDestinationSelected: (index) {
              widget.currentIndex.value = index;
              widget.pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home), label: ''),
              NavigationDestination(icon: Icon(Icons.article), label: ''),
              NavigationDestination(
                icon: Icon(Icons.calendar_today),
                label: '',
              ),
              NavigationDestination(icon: Icon(Icons.history), label: ''),
              NavigationDestination(icon: Icon(Icons.bar_chart), label: ''),
              NavigationDestination(icon: Icon(Icons.person), label: ''),
            ],
          ),
        );
      },
    );
  }
}
