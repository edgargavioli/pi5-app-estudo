import 'package:flutter/material.dart';
import 'package:pi5_ms_mobile/src/presentation/HomePage.dart';
import 'package:pi5_ms_mobile/src/presentation/provas/ProvasListagemPage.dart';

class NavigationWidget extends StatelessWidget {
  final int currentIndex;

  const NavigationWidget({super.key, required this.currentIndex});

  void _onItemTapped(BuildContext context, int index) {
    if (index != currentIndex) {
      Widget nextPage;

      switch (index) {
        case 0:
          nextPage = const HomePage(title: "PI5 MS Mobile");
          break;
        case 1:
          nextPage = const ProvaslistagemPage();
          break;
        // case 2:
        //   nextPage = const PerfilPage();
        //   break;
        default:
          return;
      }

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => nextPage,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0); // horizontal slide
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            var tween = Tween(
              begin: begin,
              end: end,
            ).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _onItemTapped(context, index),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
        BottomNavigationBarItem(icon: Icon(Icons.edit), label: 'Provas'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
      ],
    );
  }
}
