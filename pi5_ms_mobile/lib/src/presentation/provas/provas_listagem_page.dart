import 'package:flutter/material.dart';
import 'package:pi5_ms_mobile/src/presentation/provas/adicionar_prova_page.dart';
import 'package:pi5_ms_mobile/src/presentation/provas/editar_prova_page.dart';
import 'package:pi5_ms_mobile/src/presentation/provas/detalhes_prova_page.dart';
import 'package:pi5_ms_mobile/src/shared/models/prova_model.dart';
import 'package:pi5_ms_mobile/src/shared/services/prova_service.dart';
import 'package:pi5_ms_mobile/src/shared/widgets/modern_dialog.dart';
import 'package:pi5_ms_mobile/src/shared/widgets/custom_snackbar.dart';
import 'package:intl/intl.dart';
import 'package:pi5_ms_mobile/src/shared/services/gamificacao_backend_service.dart';
import 'package:pi5_ms_mobile/src/shared/services/estatisticas_service.dart';
import 'package:pi5_ms_mobile/src/shared/services/estatisticas_provas_service.dart';

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
  bool _isLoading = true;
  String? _error;
  // Dados de gamificação (calculados dinamicamente)
  Map<String, dynamic> _estatisticasGamificacao = {};
  bool _carregandoGamificacao = true;
  // Dados de estatísticas de provas
  Map<String, dynamic> _estatisticasProvas = {};
  bool _carregandoEstatisticasProvas = true;
  // Para posicionamento do menu de ações
  final Map<int, GlobalKey> _itemKeys = {};
  @override
  void initState() {
    super.initState();
    _carregarProvas();
    _carregarEstatisticasGamificacao();
    _carregarEstatisticasProvas();
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
          _provasFiltradas = List.from(provas); // Criar uma nova lista
          _isLoading = false;
        });
        // Limpar busca quando recarregar
        _searchController.clear();
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
      // Carregar dados de gamificação
      final progressao =
          await GamificacaoBackendService.obterEstatisticasCompletas();

      // Carregar estatísticas de sessões do backend
      final estatisticasSessoes =
          await EstatisticasService.obterEstatisticasGerais();
      print('🔍 Dados de progressão: $progressao');
      print('🔍 Estatísticas de sessões: $estatisticasSessoes');

      // Tratamento defensivo para evitar erros de tipo
      final stats = <String, dynamic>{};

      // Dados de gamificação (XP, nível) - tratamento seguro
      if (progressao != null) {
        stats['nivel'] = progressao['nivel'] ?? 1;
        stats['xpTotal'] = progressao['xpTotal'] ?? 0;
        final progressoValue = progressao['progressoNivel'];
        stats['progressoNivel'] =
            (progressoValue is num) ? progressoValue.toDouble() : 0.0;
      } else {
        stats['nivel'] = 1;
        stats['xpTotal'] = 0;
        stats['progressoNivel'] = 0.0;
      }

      // Dados de sessões de estudo (tempo, desempenho) - tratamento seguro
      if (estatisticasSessoes != null && estatisticasSessoes['geral'] != null) {
        final geral = estatisticasSessoes['geral'];

        stats['tempoTotalMinutos'] = geral['tempoTotalMinutos'] ?? 0;
        stats['tempoTotalFormatado'] = geral['tempoTotalFormatado'] ?? '0min';
        stats['totalSessoes'] = geral['totalSessoes'] ?? 0;
        stats['totalQuestoes'] = geral['totalQuestoes'] ?? 0;
        stats['questoesAcertadas'] = geral['questoesAcertadas'] ?? 0;

        final desempenhoValue = geral['desempenho'];
        stats['desempenhoMedio'] =
            (desempenhoValue is num) ? desempenhoValue.toDouble() : 0.0;
      } else {
        stats['tempoTotalMinutos'] = 0;
        stats['tempoTotalFormatado'] = '0min';
        stats['desempenhoMedio'] = 0.0;
        stats['totalSessoes'] = 0;
        stats['totalQuestoes'] = 0;
        stats['questoesAcertadas'] = 0;
      }

      print('📊 Stats finais processados: $stats');

      if (mounted) {
        setState(() {
          _estatisticasGamificacao = stats;
          _carregandoGamificacao = false;
        });
      }
    } catch (e) {
      print('❌ Erro ao carregar estatísticas de gamificação: $e');
      print('❌ Stack trace: ${StackTrace.current}');

      if (mounted) {
        setState(() {
          // Usar valores padrão em caso de erro
          _estatisticasGamificacao = {
            'nivel': 1,
            'xpTotal': 0,
            'progressoNivel': 0.0,
            'tempoTotalMinutos': 0,
            'tempoTotalFormatado': '0min',
            'desempenhoMedio': 0.0,
            'totalSessoes': 0,
            'totalQuestoes': 0,
            'questoesAcertadas': 0,
          };
          _carregandoGamificacao = false;
        });
      }
    }
  }

  Future<void> _carregarEstatisticasProvas() async {
    setState(() {
      _carregandoEstatisticasProvas = true;
    });

    try {
      final estatisticasProvas =
          await EstatisticasProvasService.obterEstatisticasPorStatus();

      if (mounted) {
        setState(() {
          _estatisticasProvas = estatisticasProvas;
          _carregandoEstatisticasProvas = false;
        });
      }
    } catch (e) {
      print('❌ Erro ao carregar estatísticas das provas: $e');

      if (mounted) {
        setState(() {
          _estatisticasProvas = {
            'total': 0,
            'pendentes': 0,
            'concluidas': 0,
            'canceladas': 0,
            'percentualConcluidas': 0.0,
            'percentualPendentes': 100.0,
            'percentualCanceladas': 0.0,
          };
          _carregandoEstatisticasProvas = false;
        });
      }
    }
  }

  Future<void> _recarregarTudo() async {
    await Future.wait([
      _carregarProvas(),
      _carregarEstatisticasGamificacao(),
      _carregarEstatisticasProvas(),
    ]);
  }

  void _abrirModalBusca() {
    // Resetar filtros antes de abrir o modal
    _searchController.clear();
    setState(() {
      _provasFiltradas = _provas;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setModalState) => Container(
                  height: MediaQuery.of(context).size.height * 0.8,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Handle
                      Container(
                        margin: const EdgeInsets.only(top: 12),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      // Header
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.search,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Buscar Provas',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                      ),
                      // Search field
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          controller: _searchController,
                          autofocus: true,
                          onChanged: (value) {
                            setModalState(() {
                              _filtrarProvas(value);
                            });
                            // Atualiza a tela principal também
                            setState(() {});
                          },
                          decoration: InputDecoration(
                            hintText: 'Digite o nome da prova...',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon:
                                _searchController.text.isNotEmpty
                                    ? IconButton(
                                      onPressed: () {
                                        _searchController.clear();
                                        setModalState(() {
                                          _filtrarProvas('');
                                        });
                                        // Atualiza a tela principal também
                                        setState(() {});
                                      },
                                      icon: const Icon(Icons.clear),
                                    )
                                    : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Results
                      Expanded(
                        child:
                            _searchController.text.isEmpty
                                ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.search,
                                        size: 64,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.outline,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Digite para buscar provas',
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.titleMedium,
                                      ),
                                    ],
                                  ),
                                )
                                : _provasFiltradas.isEmpty
                                ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.search_off,
                                        size: 64,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.outline,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Nenhuma prova encontrada',
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.titleMedium,
                                      ),
                                    ],
                                  ),
                                )
                                : ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  itemCount: _provasFiltradas.length,
                                  itemBuilder: (context, index) {
                                    final prova = _provasFiltradas[index];
                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      child: ListTile(
                                        leading: Icon(
                                          Icons.quiz,
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                        ),
                                        title: Text(prova.titulo),
                                        subtitle: Text(prova.local),
                                        trailing: _buildResultadoIndicador(
                                          prova,
                                        ),
                                        onTap: () {
                                          Navigator.pop(context);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      DetalhesProvaPage(
                                                        prova: prova,
                                                      ),
                                            ),
                                          ).then((result) {
                                            if (result == true) {
                                              _carregarProvas();
                                            }
                                          });
                                        },
                                      ),
                                    );
                                  },
                                ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
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
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _carregarProvas,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopAddButton() {
    return Container(
      margin: const EdgeInsets.all(16),
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _adicionarProva,
        icon: const Icon(Icons.add),
        label: const Text('Criar Primeira Prova'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // Verifica se há filtro de busca ativo
  bool get _temFiltroAtivo => _searchController.text.isNotEmpty;

  // Limpa o filtro de busca
  void _limparFiltro() {
    _searchController.clear();
    setState(() {
      _provasFiltradas = List.from(_provas);
      _selectedIndex = null;
    });
  }

  Widget _buildFilterIndicator() {
    if (!_temFiltroAtivo) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.filter_alt,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Filtro ativo: "${_searchController.text}"',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _limparFiltro,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.close,
                  color: Theme.of(context).colorScheme.primary,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _filtrarProvas(String query) {
    setState(() {
      if (query.isEmpty) {
        _provasFiltradas = List.from(_provas);
      } else {
        final queryLower = query.toLowerCase();
        _provasFiltradas =
            _provas.where((prova) {
              final tituloMatch = prova.titulo.toLowerCase().contains(
                queryLower,
              );
              final localMatch = prova.local.toLowerCase().contains(queryLower);
              final descricaoMatch =
                  prova.descricao?.toLowerCase().contains(queryLower) ?? false;

              return tituloMatch || localMatch || descricaoMatch;
            }).toList();
      }
      _selectedIndex = null;
    });
  }

  Future<void> _deletarProva(String id) async {
    try {
      await ProvaService.deletarProva(id);
      if (mounted) {
        CustomSnackBar.showSuccess(context, 'Prova deletada com sucesso!');
        // Limpar busca e recarregar a lista
        _searchController.clear();
        _carregarProvas();
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
      // Limpar busca e recarregar a lista
      _searchController.clear();
      _carregarProvas();
    }
  }

  String _formatarData(DateTime data) {
    return DateFormat('dd/MM/yyyy').format(data);
  }

  String _formatarHorario(DateTime horario) {
    return DateFormat('HH:mm').format(horario);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Provas'),
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          // Botão de busca que abre modal
          if (_provas.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: _abrirModalBusca,
              tooltip: 'Buscar provas',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _recarregarTudo,
            tooltip: 'Atualizar dados',
          ),
          // Botão fixo de adicionar quando há provas
          if (_provas.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _adicionarProva,
              tooltip: 'Adicionar prova',
            ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? _buildErrorState()
              : Column(
                children: [
                  // Botão fixo no topo quando não há provas
                  if (_provas.isEmpty) _buildTopAddButton(),
                  // Gauges de gamificação (só quando há provas)
                  if (_provas.isNotEmpty) _buildGamificationGauges(),
                  // Indicador de filtro ativo
                  if (_provas.isNotEmpty) _buildFilterIndicator(),
                  // Card promocional (só quando há provas)
                  if (_provas.isNotEmpty) _buildPromotionalCard(),
                  // Conteúdo principal
                  Expanded(child: _buildContent()),
                ],
              ),
    );
  }

  Widget _buildGamificationGauges() {
    return Container(
      height: 90,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child:
          _carregandoGamificacao || _carregandoEstatisticasProvas
              ? const Center(child: CircularProgressIndicator())
              : Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildCompactGauge(
                    "Tempo",
                    _estatisticasGamificacao['tempoTotalFormatado'] ?? '0min',
                    (_estatisticasGamificacao['tempoTotalMinutos'] ?? 0)
                            .toDouble() /
                        180,
                    Theme.of(context).colorScheme.primary,
                  ),
                  _buildCompactGauge(
                    "Nível ${_estatisticasGamificacao['nivel'] ?? 1}",
                    "${_estatisticasGamificacao['xpTotal'] ?? 0}xp",
                    (_estatisticasGamificacao['progressoNivel'] ?? 0.0)
                        .toDouble(),
                    Colors.amber.shade700,
                  ),
                  // Escolher entre desempenho e provas concluídas baseado nos dados disponíveis
                  (_estatisticasProvas['total'] ?? 0) > 0
                      ? _buildCompactGauge(
                        "Provas",
                        "${_estatisticasProvas['concluidas'] ?? 0}/${_estatisticasProvas['total'] ?? 0}",
                        (_estatisticasProvas['percentualConcluidas'] ?? 0.0) /
                            100,
                        Colors.green.shade600,
                      )
                      : _buildCompactGauge(
                        "Desempenho",
                        "${(_estatisticasGamificacao['desempenhoMedio'] ?? 0.0).toStringAsFixed(0)}%",
                        ((_estatisticasGamificacao['desempenhoMedio'] ?? 0.0) /
                                100)
                            .clamp(0.0, 1.0),
                        Theme.of(context).colorScheme.primary,
                      ),
                ],
              ),
    );
  }

  Widget _buildContent() {
    if (_provasFiltradas.isEmpty && _provas.isNotEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64),
            SizedBox(height: 16),
            Text('Nenhuma prova encontrada'),
          ],
        ),
      );
    }

    if (_provas.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _carregarProvas,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: _provasFiltradas.length,
        itemBuilder: (context, index) {
          final prova = _provasFiltradas[index];

          if (!_itemKeys.containsKey(index)) {
            _itemKeys[index] = GlobalKey();
          }

          return Column(
            children: [
              _buildProvaCard(prova, index),
              if (_selectedIndex == index) _buildActionMenu(prova),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;

        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: availableHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),

                  // Ícone principal
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 1500),
                    curve: Curves.elasticOut,
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: 0.8 + (value * 0.2),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [
                                Theme.of(
                                  context,
                                ).colorScheme.primaryContainer.withOpacity(0.3),
                                Theme.of(
                                  context,
                                ).colorScheme.primaryContainer.withOpacity(0.1),
                                Colors.transparent,
                              ],
                              stops: const [0.3, 0.7, 1.0],
                            ),
                            borderRadius: BorderRadius.circular(64),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.2),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.quiz_outlined,
                            size: 64,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Título
                  Text(
                    'Nenhuma prova cadastrada',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 12),

                  // Subtítulo
                  Text(
                    'Organize seus estudos criando sua primeira prova',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(
                    height: 80,
                  ), // Espaço para não sobrepor o botão
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionMenu(Prova prova) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scaleY: value,
          alignment: Alignment.topCenter,
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withOpacity(0.15),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildInlineActionButton(
                    icon: Icons.edit_rounded,
                    label: 'Editar',
                    color: Colors.blue[600]!,
                    onPressed: () async {
                      setState(() => _selectedIndex = null);
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProvaPage(prova: prova),
                        ),
                      );
                      if (result == true) _carregarProvas();
                    },
                  ),
                  _buildInlineActionButton(
                    icon: Icons.delete_rounded,
                    label: 'Excluir',
                    color: Colors.red[600]!,
                    onPressed: () async {
                      setState(() => _selectedIndex = null);
                      final confirm = await _showDeleteDialog(prova);
                      if (confirm == true) _deletarProva(prova.id);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<bool?> _showDeleteDialog(Prova prova) {
    return ModernDialog.showConfirmDialog(
      context: context,
      icon: Icons.delete_outline_rounded,
      iconColor: Colors.red,
      title: 'Confirmar exclusão',
      content: 'Tem certeza que deseja excluir a prova "${prova.titulo}"?',
      infoText:
          'Esta ação é irreversível e removerá todos os dados associados à prova.',
      infoColor: Colors.red,
      cancelText: 'Cancelar',
      confirmText: 'Excluir',
      confirmColor: Colors.red,
      isDestructive: true,
    );
  }

  void _mostrarMenuStatus(Prova prova) async {
    final statusOptions = [
      {
        'value': StatusProva.PENDENTE,
        'label': 'Pendente',
        'icon': Icons.schedule,
        'color': Colors.orange,
      },
      {
        'value': StatusProva.CONCLUIDA,
        'label': 'Concluída',
        'icon': Icons.check_circle,
        'color': Colors.green,
      },
      {
        'value': StatusProva.CANCELADA,
        'label': 'Cancelada',
        'icon': Icons.cancel,
        'color': Colors.red,
      },
    ];

    await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle indicator
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alterar Status',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      prova.materia?.nome ?? 'Prova',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              // Status options
              ...statusOptions.map((option) {
                final isSelected = prova.status == option['value'];
                return ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (option['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      option['icon'] as IconData,
                      color: option['color'] as Color,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    option['label'] as String,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color:
                          isSelected
                              ? (option['color'] as Color)
                              : Colors.grey[800],
                    ),
                  ),
                  trailing:
                      isSelected
                          ? Icon(Icons.check, color: option['color'] as Color)
                          : null,
                  selected: isSelected,
                  onTap: () {
                    Navigator.pop(context);
                    if (!isSelected) {
                      _atualizarStatusProva(
                        prova,
                        option['value'] as StatusProva,
                      );
                    }
                  },
                );
              }).toList(),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Future<void> _atualizarStatusProva(
    Prova prova,
    StatusProva novoStatus,
  ) async {
    try {
      // Mostrar indicador de carregamento
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 12),
              Text('Atualizando status...'),
            ],
          ),
          duration: Duration(seconds: 1),
        ),
      ); // Chamar o serviço para atualizar o status
      await ProvaService.atualizarStatus(prova.id, novoStatus);

      // Atualizar a prova localmente
      setState(() {
        final index = _provas.indexWhere((p) => p.id == prova.id);
        if (index != -1) {
          _provas[index] = _provas[index].copyWith(status: novoStatus);
        }

        final indexFiltrada = _provasFiltradas.indexWhere(
          (p) => p.id == prova.id,
        );
        if (indexFiltrada != -1) {
          _provasFiltradas[indexFiltrada] = _provasFiltradas[indexFiltrada]
              .copyWith(status: novoStatus);
        }
      });

      // Recarregar estatísticas das provas
      _carregarEstatisticasProvas(); // Mostrar mensagem de sucesso
      String statusLabel;
      switch (novoStatus) {
        case StatusProva.CONCLUIDA:
          statusLabel = 'concluída';
          break;
        case StatusProva.CANCELADA:
          statusLabel = 'cancelada';
          break;
        default:
          statusLabel = 'pendente';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status da prova atualizado para $statusLabel'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Mostrar mensagem de erro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar status: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildPromotionalCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 4,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primaryContainer.withOpacity(0.9),
                Theme.of(context).colorScheme.primaryContainer.withOpacity(0.6),
              ],
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: _adicionarProva,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.add_circle_rounded,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Adicionar Nova Prova',
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Organize seus estudos',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Theme.of(context).colorScheme.primary,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProvaCard(Prova prova, int index) {
    final isSelected = _selectedIndex == index;

    return Container(
      key: _itemKeys[index],
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            if (_selectedIndex == index) {
              setState(() => _selectedIndex = null);
              return;
            }

            if (_selectedIndex != null) {
              setState(() => _selectedIndex = null);
              return;
            }

            final resultado = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (context) => DetalhesProvaPage(prova: prova),
              ),
            );

            if (resultado == true) _carregarProvas();
          },
          onLongPress: () {
            setState(() {
              _selectedIndex = _selectedIndex == index ? null : index;
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? Theme.of(
                        context,
                      ).colorScheme.primaryContainer.withOpacity(0.1)
                      : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color:
                    isSelected
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.4)
                        : Theme.of(
                          context,
                        ).colorScheme.outline.withOpacity(0.12),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      isSelected
                          ? Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.15)
                          : Colors.black.withOpacity(0.06),
                  blurRadius: isSelected ? 16 : 10,
                  offset: Offset(0, isSelected ? 6 : 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary.withOpacity(0.15),
                        Theme.of(context).colorScheme.primary.withOpacity(0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.quiz_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prova.titulo,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              prova.local,
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 16,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatarData(prova.data),
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.access_time_outlined,
                            size: 16,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatarHorario(prova.horario),
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      if (prova.materias.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.subject_outlined,
                              size: 16,
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                prova.materias.map((m) => m.nome).join(', '),
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.copyWith(
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  children: [
                    _buildStatusIndicador(prova),
                    const SizedBox(height: 8),
                    _buildResultadoIndicador(prova),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicador(Prova prova) {
    Color cor;
    String texto;
    IconData icone;

    switch (prova.status) {
      case StatusProva.CONCLUIDA:
        cor = Colors.green;
        texto = 'Concluída';
        icone = Icons.check_circle;
        break;
      case StatusProva.CANCELADA:
        cor = Colors.red;
        texto = 'Cancelada';
        icone = Icons.cancel;
        break;
      case StatusProva.PENDENTE:
        cor = Colors.orange;
        texto = 'Pendente';
        icone = Icons.schedule;
        break;
    }

    return GestureDetector(
      onTap: () => _mostrarMenuStatus(prova),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: cor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: cor.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, color: cor, size: 12),
            const SizedBox(width: 4),
            Text(
              texto,
              style: TextStyle(
                color: cor,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultadoIndicador(Prova prova) {
    // Como a lógica de resultados agora está nas sessões de estudo,
    // vamos apenas mostrar se a prova está agendada ou já passou
    final agora = DateTime.now();
    final dataProva = DateTime(
      prova.data.year,
      prova.data.month,
      prova.data.day,
      prova.horario.hour,
      prova.horario.minute,
    );

    if (dataProva.isBefore(agora)) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.blue[400],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history, color: Colors.white, size: 14),
            SizedBox(width: 4),
            Text(
              'Realizada',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    } else {
      // Calcular quantos dias faltam para a prova
      final diasRestantes = dataProva.difference(agora).inDays;
      final horasRestantes = dataProva.difference(agora).inHours;

      String texto;
      Color cor;
      IconData icone;

      if (diasRestantes > 7) {
        texto = 'Agendada';
        cor = Colors.green[600]!;
        icone = Icons.event_available;
      } else if (diasRestantes > 1) {
        texto = '${diasRestantes}d';
        cor = Colors.orange[600]!;
        icone = Icons.schedule;
      } else if (horasRestantes > 0) {
        texto = '${horasRestantes}h';
        cor = Colors.red[600]!;
        icone = Icons.access_time;
      } else {
        texto = 'Hoje';
        cor = Colors.red[700]!;
        icone = Icons.priority_high;
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: cor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cor.withOpacity(0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, color: cor, size: 14),
            const SizedBox(width: 4),
            Text(
              texto,
              style: TextStyle(
                color: cor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildInlineActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.25), width: 1),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
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
    final clampedValue = value.clamp(0.0, 1.0);

    return Expanded(
      child: Container(
        height: 90,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.12), color.withOpacity(0.08)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.2), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.12),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  valueText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color.withOpacity(0.8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: color.withOpacity(0.15),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: clampedValue,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withOpacity(0.8)],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
