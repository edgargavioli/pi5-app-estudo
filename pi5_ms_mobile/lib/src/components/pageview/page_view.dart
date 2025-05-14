import 'package:flutter/material.dart';
import 'package:pi5_ms_mobile/src/presentation/cronograma/cronograma_page.dart';
import 'package:pi5_ms_mobile/src/presentation/historico/historico_page.dart';
import 'package:pi5_ms_mobile/src/presentation/inicio_page.dart';
import 'package:pi5_ms_mobile/src/presentation/provas/provas_listagem_page.dart';
import 'package:pi5_ms_mobile/src/presentation/user/perfil_usuario_page.dart';

class PageViewWidget extends StatefulWidget {
  final PageController pageController;
  final ValueNotifier<int> currentIndex;

  const PageViewWidget({
    super.key,
    required this.pageController,
    required this.currentIndex,
  });

  @override
  State<PageViewWidget> createState() => _PageViewWidgetState();
}

class _PageViewWidgetState extends State<PageViewWidget> {
  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: widget.pageController,
      onPageChanged: (index) => widget.currentIndex.value = index,
      children: <Widget>[
        HomePage(title: 'P5 MS Mobile'),
        ProvaslistagemPage(),
        CronogramaPage(),
        HistoricoPage(),
        UserProfilePageMain(),
      ],
    );
  }
}
