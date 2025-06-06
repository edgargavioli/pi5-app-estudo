import 'package:flutter/material.dart';
import '../shared/services/cronometro_service.dart';

class CronometroFlutuanteWidget extends StatefulWidget {
  final VoidCallback? onTapCronometro;
  
  const CronometroFlutuanteWidget({
    Key? key,
    this.onTapCronometro,
  }) : super(key: key);

  @override
  State<CronometroFlutuanteWidget> createState() => _CronometroFlutuanteWidgetState();
}

class _CronometroFlutuanteWidgetState extends State<CronometroFlutuanteWidget> {
  // Posição inicial do widget
  double _x = 16.0; // right: 16
  double _y = 50.0; // top: 50
  
  // Para controlar se está sendo arrastado
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: CronometroService(),
      builder: (context, child) {
        final cronometroService = CronometroService();
        
        // Só mostrar se há sessão ativa E está rodando
        if (!cronometroService.hasActiveSession || !cronometroService.isRunning) {
          return const SizedBox.shrink();
        }

        return Positioned(
          left: _x,
          top: _y,
          child: GestureDetector(
            // Detectar quando começa a arrastar
            onPanStart: (details) {
              setState(() {
                _isDragging = true;
              });
            },
            // Atualizar posição durante o arraste
            onPanUpdate: (details) {
              setState(() {
                // Obter o tamanho da tela
                final screenSize = MediaQuery.of(context).size;
                final widgetWidth = 180.0; // Largura aproximada do widget
                final widgetHeight = 40.0; // Altura aproximada do widget
                
                // Atualizar posição com limites da tela
                _x = (_x + details.delta.dx).clamp(0.0, screenSize.width - widgetWidth);
                _y = (_y + details.delta.dy).clamp(0.0, screenSize.height - widgetHeight - 100); // -100 para não cobrir navegação
              });
            },
            // Quando termina o arraste
            onPanEnd: (details) {
              setState(() {
                _isDragging = false;
              });
              
              // Opcional: fazer o widget "grudar" nas bordas
              _snapToEdge();
            },
            // Tap para navegar
            onTap: _isDragging ? null : widget.onTapCronometro,
            child: AnimatedContainer(
              duration: Duration(milliseconds: _isDragging ? 0 : 300),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _isDragging 
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.8)
                    : Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(_isDragging ? 0.3 : 0.2),
                    blurRadius: _isDragging ? 12 : 8,
                    offset: Offset(0, _isDragging ? 4 : 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Indicador visual de que pode ser arrastado
                  if (_isDragging) ...[
                    Icon(
                      Icons.drag_indicator,
                      color: Colors.white.withOpacity(0.7),
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                  ],
                  
                  // Ícone do cronômetro (sempre timer já que só aparece quando rodando)
                  const Icon(
                    Icons.timer,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  
                  // Tempo atual
                  Text(
                    cronometroService.formatDuration(cronometroService.elapsed),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  
                  const SizedBox(width: 8),
                  
                  // Botões de controle (só mostrar se não estiver arrastando)
                  if (!_isDragging) ...[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Botão pause (já que só aparece quando rodando)
                        GestureDetector(
                          onTap: () {
                            cronometroService.pauseCronometro();
                          },
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.pause,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 4),
                        
                        // Botão finalizar sessão
                        GestureDetector(
                          onTap: () {
                            _finalizarSessao();
                          },
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Método para fazer o widget "grudar" na borda mais próxima
  void _snapToEdge() {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final widgetWidth = 180.0;
    
    // Se está mais próximo da esquerda, vai para a esquerda
    // Se está mais próximo da direita, vai para a direita
    if (_x < screenWidth / 2) {
      setState(() {
        _x = 16.0; // Margem da esquerda
      });
    } else {
      setState(() {
        _x = screenWidth - widgetWidth - 16.0; // Margem da direita
      });
    }
  }

  void _finalizarSessao() async {
    final cronometroService = CronometroService();
    
    // Confirmar se realmente quer finalizar
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finalizar Sessão'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Deseja ir para a tela de cronometragem para finalizar a sessão?'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.timer,
                    color: Theme.of(context).primaryColor,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    cronometroService.formatDuration(cronometroService.elapsed),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tempo atual da sessão',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Você será redirecionado para a tela de cronometragem onde poderá salvar observações e finalizar a sessão.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Ir para Cronometragem'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      // Navegar para a tela de cronometragem
      Navigator.pushNamed(context, '/cronometragem');
    }
  }

  void _showStopDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8),
              Text('Parar Cronômetro'),
            ],
          ),
          content: const Text(
            'Tem certeza que deseja parar o cronômetro? O tempo será perdido se não salvar a sessão.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                CronometroService().stopCronometro();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cronômetro parado'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
              child: const Text(
                'Parar',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
} 