import 'package:flutter/material.dart';
import 'package:pi5_ms_mobile/src/components/card_widget.dart';
import 'package:pi5_ms_mobile/src/components/search_widget.dart';
import 'package:pi5_ms_mobile/src/presentation/materias/materias_listagem_page.dart';
import 'package:pi5_ms_mobile/src/presentation/provas/adicionar_prova_page.dart';
import 'package:pi5_ms_mobile/src/presentation/provas/editar_prova_page.dart';
import 'package:pi5_ms_mobile/src/presentation/provas/registrar_resultado_page.dart';
import 'package:pi5_ms_mobile/src/presentation/provas/detalhes_prova_page.dart';
import 'package:pi5_ms_mobile/src/shared/models/prova_model.dart';
import 'package:pi5_ms_mobile/src/shared/services/prova_service.dart';
import 'package:pi5_ms_mobile/src/shared/services/sessao_service.dart';
import 'package:pi5_ms_mobile/src/shared/models/evento_model.dart';
import 'package:intl/intl.dart';
import 'package:pi5_ms_mobile/src/shared/services/gamificacao_service.dart';

class ProvasListagemPage extends StatefulWidget {
  const ProvasListagemPage({super.key});

  @override
  State<ProvasListagemPage> createState() => _ProvasListagemPageState();
}

class _ProvasListagemPageState extends State<ProvasListagemPage> {
  final TextEditingController _searchController = TextEditingController();
  int? _selectedIndex;
  List<Prova> _provas = [];
  List<Prova> _provasFiltradas = [];
  final List<SessaoEstudo> _todasSessoes = [];
  bool _isLoading = true;
  String? _error;

  // Dados de gamificação (calculados dinamicamente)
  Map<String, dynamic> _estatisticasGamificacao = {};
  bool _carregandoGamificacao = true;

  @override
  void initState() {
    super.initState();
    _carregarProvas();
    _carregarEstatisticasGamificacao();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _carregarProvas() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final provas = await ProvaService.listarProvas(forceRefresh: true);
      if (mounted) {
        setState(() {
          _provas = provas;
          _provasFiltradas = provas;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _carregarEstatisticasGamificacao() async {
    setState(() {
      _carregandoGamificacao = true;
    });

    try {
      final stats = await GamificacaoService.obterEstatisticasCompletas();
      if (mounted) {
        setState(() {
          _estatisticasGamificacao = stats;
          _carregandoGamificacao = false;
        });
      }
    } catch (e) {
      print('Erro ao carregar estatísticas de gamificação: $e');
      if (mounted) {
        setState(() {
          _estatisticasGamificacao = {};
          _carregandoGamificacao = false;
        });
      }
    }
  }

  Future<void> _recarregarTudo() async {
    await Future.wait([_carregarProvas(), _carregarEstatisticasGamificacao()]);
  }

  void _filtrarProvas(String query) {
    setState(() {
      if (query.isEmpty) {
        _provasFiltradas = _provas;
      } else {
        _provasFiltradas =
            _provas.where((prova) {
              return prova.titulo.toLowerCase().contains(query.toLowerCase()) ||
                  prova.local.toLowerCase().contains(query.toLowerCase()) ||
                  (prova.descricao?.toLowerCase().contains(
                        query.toLowerCase(),
                      ) ??
                      false);
            }).toList();
      }
      _selectedIndex = null;
    });
  }

  Future<void> _deletarProva(String id) async {
    try {
      await ProvaService.deletarProva(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Prova deletada com sucesso!')),
        );
        _carregarProvas(); // Recarregar a lista
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao deletar prova: $e')));
      }
    }
  }

  Future<void> _adicionarProva() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AdicionarProvaPage()),
    );

    if (result == true) {
      _carregarProvas(); // Recarregar a lista se uma nova prova foi criada
    }
  }

  String _formatarData(DateTime data) {
    return DateFormat('dd/MM/yyyy').format(data);
  }

  String _formatarHorario(DateTime horario) {
    return DateFormat('HH:mm').format(horario);
  }

  String _formatarTempoEstudo(int minutos) {
    if (minutos == 0) return '0min';
    final horas = minutos ~/ 60;
    final mins = minutos % 60;

    if (horas > 0) {
      return '${horas}h ${mins}min';
    } else {
      return '${mins}min';
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double padding = screenWidth * 0.01;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Provas'),
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _recarregarTudo,
            tooltip: 'Atualizar dados',
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: padding, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Gauges de gamificação
                Container(
                  height: 32,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child:
                      _carregandoGamificacao
                          ? const Center(child: CircularProgressIndicator())
                          : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildCompactGauge(
                                "Tempo",
                                _estatisticasGamificacao['tempoTotalFormatado'] ??
                                    '0min',
                                (_estatisticasGamificacao['tempoTotalMinutos'] ??
                                            0)
                                        .toDouble() /
                                    180, // Max 3h para 100%
                                Theme.of(context).colorScheme.primary,
                              ),
                              _buildCompactGauge(
                                "Nível ${_estatisticasGamificacao['nivel'] ?? 1}",
                                "${_estatisticasGamificacao['xpTotal'] ?? 0}xp",
                                (_estatisticasGamificacao['progressoNivel'] ??
                                        0.0)
                                    .toDouble(),
                                Colors.amberAccent,
                              ),
                              _buildCompactGauge(
                                "Desempenho",
                                "${(_estatisticasGamificacao['desempenhoMedio'] ?? 0.0).toStringAsFixed(0)}%",
                                ((_estatisticasGamificacao['desempenhoMedio'] ??
                                            0.0) /
                                        100)
                                    .clamp(0.0, 1.0),
                                Theme.of(context).colorScheme.primary,
                              ),
                            ],
                          ),
                ),
                const SizedBox(height: 4),
                SearchBarWidget(
                  controller: _searchController,
                  onSubmitted: _filtrarProvas,
                  onChanged: _filtrarProvas,
                  hintText: 'Pesquisar provas...',
                ),
                const SizedBox(height: 4),
                if (_provas.isNotEmpty && _provas.length < 4)
                  _buildPromotionalCard(),
                Expanded(child: _buildContent()),
              ],
            ),
          ),
          if (_selectedIndex != null)
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIndex = null;
                });
              },
              child: Container(color: Colors.transparent),
            ),
          if (_selectedIndex != null) _buildActionButtons(),
          if (_provas.isEmpty) _buildEmptyStateAddButton(),
        ],
      ),
    );
  }

  Widget _buildEmptyStateAddButton() {
    return Positioned(
      bottom: 24,
      left: 0,
      right: 0,
      child: Center(
        child: TweenAnimationBuilder<double>(
          duration: const Duration(seconds: 1),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: 1.0 + (0.05 * value),
              child: FloatingActionButton.extended(
                heroTag: "main_add_prova_fab",
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                onPressed: _adicionarProva,
                icon: const Icon(Icons.add_circle),
                label: const Text(
                  'Criar Primeira Prova',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                elevation: 6,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar provas',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _carregarProvas,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (_provasFiltradas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              _provas.isEmpty
                  ? 'Nenhuma prova cadastrada'
                  : 'Nenhuma prova encontrada',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _provas.isEmpty
                  ? 'Adicione sua primeira prova usando o botão em destaque abaixo'
                  : 'Tente ajustar os termos da busca',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _carregarProvas,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: _provasFiltradas.length,
        itemBuilder: (context, index) {
          final prova = _provasFiltradas[index];

          return CardWidget(
            title: prova.titulo,
            icon: Icons.article,
            color:
                _selectedIndex == index
                    ? Theme.of(context).colorScheme.primaryContainer
                    : null,
            trailing: Container(
              constraints: const BoxConstraints(maxWidth: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatarData(prova.data),
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(fontSize: 10, height: 1.1),
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _formatarHorario(prova.horario),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      height: 1.1,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  _buildResultadoIndicador(prova),
                ],
              ),
            ),
            onTap: () async {
              final resultado = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (context) => DetalhesProvaPage(prova: prova),
                ),
              );

              if (resultado == true) {
                _carregarProvas(); // Recarregar se houve mudanças
              }
            },
            onLongPress: () {
              setState(() {
                _selectedIndex = index;
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildPromotionalCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: TweenAnimationBuilder<double>(
        duration: const Duration(seconds: 2),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Card(
            elevation: 2 + (value * 2),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primaryContainer,
                    Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1 + (value * 0.1)),
                    blurRadius: 8,
                    spreadRadius: value,
                  ),
                ],
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _adicionarProva,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.add_circle,
                          color: Theme.of(context).colorScheme.onPrimary,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nova Prova',
                              style: Theme.of(
                                context,
                              ).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.onPrimaryContainer,
                              ),
                            ),
                            Text(
                              'Toque para adicionar',
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer
                                    .withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        size: 12,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultadoIndicador(Prova prova) {
    if (prova.foiRealizada && prova.percentualAcerto != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
        decoration: BoxDecoration(
          color:
              prova.percentualAcerto! >= 70
                  ? Colors.green
                  : prova.percentualAcerto! >= 50
                  ? Colors.orange
                  : Colors.red,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '${prova.percentualAcerto}%',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.bold,
            height: 1.0,
          ),
        ),
      );
    } else if (prova.totalQuestoes != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
        decoration: BoxDecoration(
          color: Colors.grey[400],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'Pendente',
          style: TextStyle(
            color: Colors.white,
            fontSize: 8,
            fontWeight: FontWeight.bold,
            height: 1.0,
          ),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Config',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 8,
            fontWeight: FontWeight.bold,
            height: 1.0,
          ),
        ),
      );
    }
  }

  Widget _buildActionButtons() {
    return Positioned(
      bottom: 16,
      right: 16,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildActionButton(
              icon: Icons.delete_outline,
              color: Theme.of(context).colorScheme.error,
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
              onPressed: () async {
                final prova = _provasFiltradas[_selectedIndex!];
                final confirm = await showDialog<bool>(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text('Confirmar exclusão'),
                        content: Text(
                          'Deseja realmente excluir a prova "${prova.titulo}"?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: TextButton.styleFrom(
                              foregroundColor:
                                  Theme.of(context).colorScheme.error,
                            ),
                            child: const Text('Excluir'),
                          ),
                        ],
                      ),
                );

                if (confirm == true) {
                  await _deletarProva(prova.id);
                  setState(() {
                    _selectedIndex = null;
                  });
                }
              },
            ),
            const SizedBox(height: 8),
            _buildActionButton(
              icon: Icons.quiz,
              color: Theme.of(context).colorScheme.onTertiaryContainer,
              backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
              onPressed: () async {
                final prova = _provasFiltradas[_selectedIndex!];

                if (prova.totalQuestoes == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Esta prova não possui número total de questões definido. Não é possível registrar resultado.',
                      ),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RegistrarResultadoPage(prova: prova),
                  ),
                );

                if (result != null) {
                  _carregarProvas();
                }

                setState(() {
                  _selectedIndex = null;
                });
              },
            ),
            const SizedBox(height: 8),
            _buildActionButton(
              icon: Icons.edit,
              color: Theme.of(context).colorScheme.onSecondaryContainer,
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              onPressed: () async {
                final prova = _provasFiltradas[_selectedIndex!];
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProvaPage(prova: prova),
                  ),
                );

                if (result == true) {
                  _carregarProvas();
                }

                setState(() {
                  _selectedIndex = null;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required Color backgroundColor,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(icon, size: 20),
        color: color,
        onPressed: onPressed,
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactGauge(
    String label,
    String valueText,
    double value,
    Color color,
  ) {
    // Garantir que o valor esteja entre 0.0 e 1.0
    final clampedValue = value.clamp(0.0, 1.0);

    return Expanded(
      child: Container(
        height: 32,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Row(
          children: [
            // Label e valor
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: color,
                      height: 1.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    valueText,
                    style: TextStyle(
                      fontSize: 7,
                      color: color.withOpacity(0.8),
                      height: 1.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Barra de progresso
            Expanded(
              flex: 1,
              child: Container(
                height: 4,
                margin: const EdgeInsets.only(left: 4),
                child: LinearProgressIndicator(
                  value: clampedValue,
                  backgroundColor: color.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
