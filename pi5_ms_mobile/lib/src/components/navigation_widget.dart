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

class _BottonNavBarWidgetState extends State<BottonNavBarWidget>
    with TickerProviderStateMixin {
  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.home_rounded,
      activeIcon: Icons.home,
      label: 'Início',
      color: const Color(0xFF2196F3),
    ),
    NavigationItem(
      icon: Icons.quiz_outlined,
      activeIcon: Icons.quiz,
      label: 'Provas',
      color: const Color(0xFF4CAF50),
    ),
    NavigationItem(
      icon: Icons.schedule_outlined,
      activeIcon: Icons.schedule,
      label: 'Agenda',
      color: const Color(0xFFFF9800),
    ),
    NavigationItem(
      icon: Icons.analytics_outlined,
      activeIcon: Icons.analytics,
      label: 'Stats',
      color: const Color(0xFFF44336),
    ),
    NavigationItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Perfil',
      color: const Color(0xFF00BCD4),
    ),
  ];
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 375;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return ValueListenableBuilder<int>(
      valueListenable: widget.currentIndex,
      builder: (context, currentIndex, _) {
        return Container(
          height: 85,
          margin: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: bottomPadding > 0 ? 20 : 24,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 20,
                offset: const Offset(0, -4),
                spreadRadius: 0,
              ),
            ],
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.1),
              width: 0.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Row(
              children:
                  _navigationItems.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final isSelected = currentIndex == index;

                    return Expanded(
                      child: _buildNavigationItem(
                        item: item,
                        index: index,
                        isSelected: isSelected,
                        isSmallScreen: isSmallScreen,
                      ),
                    );
                  }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavigationItem({
    required NavigationItem item,
    required int index,
    required bool isSelected,
    required bool isSmallScreen,
  }) {
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Container do ícone
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? item.color.withValues(alpha: 0.15)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isSelected ? item.activeIcon : item.icon,
                color:
                    isSelected
                        ? item.color
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                size: 22,
              ),
            ),

            // Espaçamento
            const SizedBox(height: 4),

            // Label com tamanho adequado
            Flexible(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color:
                      isSelected
                          ? item.color
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                  letterSpacing: 0.1,
                  height: 1.1,
                ),
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    // Vibração sutil (se disponível)
    if (widget.currentIndex.value != index) {
      widget.currentIndex.value = index;
      widget.pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }
}

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Color color;

  NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.color,
  });
}
