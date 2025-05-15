import 'package:flutter/material.dart';
import 'package:pi5_ms_mobile/src/components/navigation_widget.dart';
import 'package:pi5_ms_mobile/src/components/pageview/page_view.dart';

class ScaffoldWidget extends StatefulWidget {
  const ScaffoldWidget({super.key});

  @override
  State<ScaffoldWidget> createState() => _ScaffoldWidgetState();
}

class _ScaffoldWidgetState extends State<ScaffoldWidget> {
  final PageController _pageController = PageController();
  final ValueNotifier<int> _currentIndex = ValueNotifier<int>(0);

  @override
  void dispose() {
    _pageController.dispose();
    _currentIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'materia') {
                // Do something for Option 1
              }
            },
            itemBuilder:
                (BuildContext context) => [
                  const PopupMenuItem<String>(
                    value: 'materia',
                    child: Text('Configurar matérias'),
                  ),
                ],
          ),
        ],
      ),
      body: PageViewWidget(
        pageController: _pageController,
        currentIndex: _currentIndex,
      ),
      bottomNavigationBar: BottonNavBarWidget(
        pageController: _pageController,
        currentIndex: _currentIndex,
      ),
    );
  }
}
