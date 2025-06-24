import 'package:flutter/material.dart';
import 'package:pi5_ms_mobile/src/components/navigation_widget.dart';
import 'package:pi5_ms_mobile/src/components/pageview/page_view.dart';
import 'package:pi5_ms_mobile/src/components/cronometro_flutuante_widget.dart';
import 'package:pi5_ms_mobile/src/shared/services/cronometro_service.dart';
import 'package:pi5_ms_mobile/src/routes/app_routes.dart';

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

  void _navegarParaCronometro() {
    final cronometroService = CronometroService();
    if (cronometroService.hasActiveSession) {
      // Mostrar diálogo informando sobre o novo fluxo de estudos
      _showEstudosInfoDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PI5 MS Mobile'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'materias':
                  Navigator.pushNamed(context, AppRoutes.materias);
                  break;
                case 'estudos':
                  // Mostrar um aviso sobre o novo fluxo de estudos
                  _showEstudosInfoDialog();
                  break;
                case 'perfil':
                  Navigator.pushNamed(context, AppRoutes.perfil);
                  break;
                case 'logout':
                  _showLogoutDialog();
                  break;
              }
            },
            itemBuilder:
                (BuildContext context) => [
                  const PopupMenuItem<String>(
                    value: 'materias',
                    child: Row(
                      children: [
                        Icon(Icons.library_books),
                        SizedBox(width: 8),
                        Text('Matérias'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'estudos',
                    child: Row(
                      children: [
                        Icon(Icons.book),
                        SizedBox(width: 8),
                        Text('Estudos'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'perfil',
                    child: Row(
                      children: [
                        Icon(Icons.person),
                        SizedBox(width: 8),
                        Text('Perfil'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout),
                        SizedBox(width: 8),
                        Text('Sair'),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: Stack(
        children: [
          PageViewWidget(
            pageController: _pageController,
            currentIndex: _currentIndex,
          ),
          // Cronômetro flutuante
          CronometroFlutuanteWidget(onTapCronometro: _navegarParaCronometro),
        ],
      ),
      bottomNavigationBar: BottonNavBarWidget(
        pageController: _pageController,
        currentIndex: _currentIndex,
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sair'),
          content: const Text('Tem certeza que deseja sair da aplicação?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                AppRoutes.logout(context);
              },
              child: const Text('Sair'),
            ),
          ],
        );
      },
    );
  }

  void _showEstudosInfoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Estudos'),
          content: const Text(
            'Para uma melhor experiência de estudos, acesse a página de estudos através de uma prova específica. '
            'Vá para "Provas" e selecione a prova que deseja estudar.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, AppRoutes.estudos);
              },
              child: const Text('Continuar mesmo assim'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, AppRoutes.provas);
              },
              child: const Text('Ir para Provas'),
            ),
          ],
        );
      },
    );
  }
}
