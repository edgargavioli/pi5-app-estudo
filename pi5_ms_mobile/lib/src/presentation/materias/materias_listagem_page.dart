import 'package:flutter/material.dart';
import 'package:pi5_ms_mobile/src/presentation/provas/editar_prova_page.dart';
import '../../shared/models/materia_model.dart';
import '../../shared/models/prova_model.dart';
import '../../shared/services/materia_service.dart';
import '../../shared/services/prova_service.dart';
import '../../shared/widgets/modern_dialog.dart';
import '../../shared/widgets/custom_snackbar.dart';

class MateriasListagemPage extends StatefulWidget {
  final String title;
  final String provaId; // Mudado para String (UUID)

  const MateriasListagemPage({
    super.key,
    required this.title,
    required this.provaId,
  });

  @override
  State<MateriasListagemPage> createState() => _MateriasListagemPageState();
}

class _MateriasListagemPageState extends State<MateriasListagemPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  String _selectedCategoria = 'Exatas';

  Prova? _prova;
  List<Prova> _todasProvas = [];
  Prova? _provaFiltroSelecionada;
  List<Materia> _materiasVinculadas = [];
  List<Materia> _materiasNaoUtilizadas = [];
  bool _isLoading = true;
  bool _isCreatingMateria = false;
  bool _isFormularioExpandido = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _carregarDados();
    // Adicionar listener para pesquisa em tempo real
    _searchController.addListener(_filtrarConteudo);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filtrarConteudo);
    _searchController.dispose();
    _nomeController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _carregarDados() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      }); // Verificar se temos um provaId válido
      if (widget.provaId.isEmpty) {
        // Modo geral: carregar matérias utilizadas e não utilizadas
        final todasProvas = await ProvaService.listarProvas();
        final materiasUtilizadas =
            await MateriaService.listarMateriasUtilizadas();
        final materiasNaoUtilizadas =
            await MateriaService.listarMateriasNaoUtilizadas(); // Adicionar matérias de exemplo se não há dados (apenas para desenvolvimento)
        List<Materia> materiasUtilizadasFinal = materiasUtilizadas;
        List<Materia> materiasNaoUtilizadasFinal = materiasNaoUtilizadas;

        // Remover dados mockados - deixar as listas vazias se não há dados reais
        // As listas agora ficam conforme retornadas do backend        // Filtrar matérias por prova selecionada se houver filtro
        if (_provaFiltroSelecionada != null) {
          try {
            materiasUtilizadasFinal =
                await MateriaService.listarMateriasPorProva(
                  _provaFiltroSelecionada!.id,
                );
          } catch (e) {
            materiasUtilizadasFinal = [];
          }
        }
        if (mounted) {
          setState(() {
            _prova = null;
            _todasProvas = todasProvas;
            _materiasVinculadas = materiasUtilizadasFinal;
            _materiasNaoUtilizadas = materiasNaoUtilizadasFinal;
            _isLoading = false;

            // Validar se a prova selecionada ainda existe na lista
            if (_provaFiltroSelecionada != null) {
              final provaAindaExiste = _todasProvas.any(
                (prova) => prova.id == _provaFiltroSelecionada!.id,
              );
              if (!provaAindaExiste) {
                _provaFiltroSelecionada = null;
              }
            }
          });
        }
        return;
      } // Modo prova específica: carregar prova e suas matérias
      final prova = await ProvaService.buscarPorId(widget.provaId);

      List<Materia> materiasVinculadas = [];
      if (prova.materias.isNotEmpty) {
        materiasVinculadas = prova.materias;
      } else if (prova.materiasIds.isNotEmpty) {
        for (String materiaId in prova.materiasIds) {
          try {
            final materia = await MateriaService.buscarPorId(materiaId);
            materiasVinculadas.add(materia);
          } catch (e) {
            // Matéria não encontrada, ignorar
          }
        }
      } // Carregar também as matérias não utilizadas para permitir adição
      final materiasNaoUtilizadas =
          await MateriaService.listarMateriasNaoUtilizadas();

      if (mounted) {
        setState(() {
          _prova = prova;
          _materiasVinculadas = materiasVinculadas;
          _materiasNaoUtilizadas = materiasNaoUtilizadas;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Erro ao carregar dados: $e';
        });
      }
    }
  }

  void _filtrarConteudo() {
    // Implementar filtro em tempo real se necessário
    // Por enquanto, já que é apenas uma matéria, não há muito o que filtrar
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, overflow: TextOverflow.ellipsis),
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_prova != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProvaPage(prova: _prova!),
                  ),
                );

                if (result == true) {
                  _carregarDados(); // Recarregar os dados se houve edição
                }
              },
              tooltip: 'Editar prova',
            ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? _buildErrorWidget(theme)
              : _buildContent(theme, screenSize),
    );
  }

  Widget _buildErrorWidget(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar dados',
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _carregarDados,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme, Size screenSize) {
    // Se estamos em modo de filtro, não mostrar tela vazia mesmo se não há resultados
    final ehModoFiltro = _provaFiltroSelecionada != null;

    // Verificar se não há matérias cadastradas (apenas quando não é filtro)
    final temMaterias =
        _materiasVinculadas.isNotEmpty || _materiasNaoUtilizadas.isNotEmpty;

    if (!temMaterias && !ehModoFiltro) {
      return _buildEmptyStateView(theme);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          _buildHeaderCard(theme),
          const SizedBox(height: 32),

          // Seção de matérias por vestibular (utilizadas)
          _buildSecaoMateriasUtilizadas(theme),
          const SizedBox(height: 32),

          // Seção de matérias não utilizadas com card de criação
          _buildSecaoMateriasNaoUtilizadas(theme),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(ThemeData theme) {
    final isProvaEspecifica = _prova != null;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              isProvaEspecifica ? Icons.assignment : Icons.library_books,
              color: theme.colorScheme.primary,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isProvaEspecifica
                        ? 'Configurações - ${_prova!.titulo}'
                        : 'Configurações - Matérias',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    isProvaEspecifica
                        ? 'Gerencie as matérias desta prova'
                        : 'Gerencie todas as matérias do sistema',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecaoMateriasUtilizadas(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título da seção
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Matérias por vestibular',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Filtro por prova (apenas em modo geral)
        if (widget.provaId.isEmpty && _todasProvas.isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.filter_list_rounded,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Filtrar por prova',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<Prova?>(
                  value: _getValidatedProvaFiltro(),
                  decoration: InputDecoration(
                    hintText: 'Selecione uma prova...',
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: theme.colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: [
                    DropdownMenuItem<Prova?>(
                      value: null,
                      child: Text(
                        'Todas as matérias utilizadas',
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    ..._todasProvas.map(
                      (prova) => DropdownMenuItem<Prova?>(
                        value: prova,
                        child: Text(
                          prova.titulo,
                          style: TextStyle(color: theme.colorScheme.onSurface),
                        ),
                      ),
                    ),
                  ],
                  onChanged: (Prova? novaProva) {
                    setState(() {
                      _provaFiltroSelecionada = novaProva;
                    });
                    _carregarDados();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Lista de matérias utilizadas
        if (_materiasVinculadas.isNotEmpty)
          ...List.generate(_materiasVinculadas.length, (index) {
            final materia = _materiasVinculadas[index];
            return _buildMateriaSimpleCard(materia, true, theme);
          })
        else
          _buildEmptyCard(
            _provaFiltroSelecionada != null
                ? 'Nenhuma matéria encontrada para "${_provaFiltroSelecionada!.titulo}"'
                : 'Nenhuma matéria vinculada a provas ainda',
            _provaFiltroSelecionada != null
                ? 'Esta prova ainda não possui matérias vinculadas.'
                : 'As matérias criadas aparecerão aqui quando forem vinculadas a provas.',
            theme,
          ),
      ],
    );
  }

  Widget _buildSecaoMateriasNaoUtilizadas(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título da seção
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Matérias não utilizadas',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.secondary,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Card expansível de criação de matéria
        _buildCardCriacaoMateria(theme),
        const SizedBox(height: 12),

        // Lista de matérias não utilizadas
        if (_materiasNaoUtilizadas.isNotEmpty)
          ...List.generate(_materiasNaoUtilizadas.length, (index) {
            final materia = _materiasNaoUtilizadas[index];
            return _buildMateriaSimpleCard(materia, false, theme);
          })
        else
          _buildEmptyCard(
            'Nenhuma matéria disponível para exclusão',
            'Todas as matérias estão sendo utilizadas em provas.',
            theme,
          ),
      ],
    );
  }

  Widget _buildCardCriacaoMateria(ThemeData theme) {
    return Card(
      elevation: 2,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primaryContainer.withOpacity(0.8),
              theme.colorScheme.primaryContainer.withOpacity(0.4),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header do card
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Icon(
                    Icons.school_rounded,
                    size: 28,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nova Matéria',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        _isFormularioExpandido
                            ? 'Preencha os dados da nova matéria'
                            : 'Clique para adicionar uma nova matéria',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                // Botão de minimizar/expandir
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isFormularioExpandido = !_isFormularioExpandido;
                      if (!_isFormularioExpandido) {
                        // Limpar campos ao minimizar
                        _nomeController.clear();
                        _descricaoController.clear();
                        _selectedCategoria = 'Exatas';
                      }
                    });
                  },
                  icon: Icon(
                    _isFormularioExpandido
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: theme.colorScheme.primary,
                    size: 28,
                  ),
                  tooltip: _isFormularioExpandido ? 'Minimizar' : 'Expandir',
                ),
              ],
            ),

            // Formulário (apenas visível quando expandido)
            if (_isFormularioExpandido) ...[
              const SizedBox(height: 24),

              // Campos do formulário
              _buildInputField(
                label: 'Nome da matéria',
                controller: _nomeController,
                icon: Icons.book_rounded,
                hint: 'Ex: Matemática, História, Química...',
                isRequired: true,
              ),

              const SizedBox(height: 16),

              _buildInputField(
                label: 'Descrição',
                controller: _descricaoController,
                icon: Icons.description_rounded,
                hint: 'Adicione uma descrição opcional',
                maxLines: 2,
              ),

              const SizedBox(height: 16),

              // Dropdown de categoria
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.category_rounded,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Categoria',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '*',
                        style: TextStyle(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategoria,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerHighest
                            .withOpacity(0.3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: theme.colorScheme.primary,
                      ),
                      items: [
                        _buildCategoryItem(
                          'Exatas',
                          Icons.calculate_rounded,
                          Colors.blue,
                        ),
                        _buildCategoryItem(
                          'Humanas',
                          Icons.psychology_rounded,
                          Colors.green,
                        ),
                        _buildCategoryItem(
                          'Biológicas',
                          Icons.biotech_rounded,
                          Colors.orange,
                        ),
                        _buildCategoryItem(
                          'Línguas',
                          Icons.translate_rounded,
                          Colors.purple,
                        ),
                        _buildCategoryItem(
                          'Outras',
                          Icons.category_rounded,
                          Colors.grey,
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategoria = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Botão de criar matéria
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isCreatingMateria ? null : _adicionarMateria,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      _isCreatingMateria
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add_rounded),
                              const SizedBox(width: 8),
                              Text(
                                'Criar Matéria',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onPrimary,
                                ),
                              ),
                            ],
                          ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMateriaSimpleCard(
    Materia materia,
    bool isVinculada,
    ThemeData theme,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color:
                isVinculada
                    ? theme.colorScheme.primaryContainer
                    : theme.colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            Icons.book,
            color:
                isVinculada
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSecondaryContainer,
            size: 18,
          ),
        ),
        title: Text(
          materia.nome,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle:
            materia.descricao != null && materia.descricao!.isNotEmpty
                ? Text(
                  materia.descricao!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
                : null,
        trailing:
            isVinculada
                ? Icon(
                  Icons.remove_circle_outline,
                  color: theme.colorScheme.error,
                  size: 20,
                )
                : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Mostrar botão de adicionar à prova se há filtro selecionado
                    if (_provaFiltroSelecionada != null)
                      IconButton(
                        icon: Icon(
                          Icons.add_circle_outline,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                        onPressed: () => _vincularMateriaAProva(materia),
                        tooltip: 'Adicionar à prova',
                      ),
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: theme.colorScheme.error,
                        size: 20,
                      ),
                      onPressed: () => _deletarMateria(materia),
                      tooltip: 'Deletar matéria',
                    ),
                  ],
                ),
        onTap: isVinculada ? () => _removerMateriaDeProva(materia) : null,
      ),
    );
  }

  Widget _buildEmptyCard(String title, String subtitle, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 40,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Método para exibir tela vazia elegante quando não há matérias cadastradas
  Widget _buildEmptyStateView(ThemeData theme) {
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

                  // Ícone principal animado
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
                                theme.colorScheme.primaryContainer.withOpacity(
                                  0.3,
                                ),
                                theme.colorScheme.primaryContainer.withOpacity(
                                  0.1,
                                ),
                                Colors.transparent,
                              ],
                              stops: const [0.3, 0.7, 1.0],
                            ),
                            borderRadius: BorderRadius.circular(64),
                            border: Border.all(
                              color: theme.colorScheme.primary.withOpacity(0.2),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.school_outlined,
                            size: 64,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Título
                  Text(
                    'Nenhuma matéria cadastrada',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 12),

                  // Subtítulo
                  Text(
                    'Organize seus estudos criando suas primeiras matérias',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  // Card de criação expandido diretamente na tela vazia
                  _buildCardCriacaoMateria(theme),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Métodos de ação
  Future<void> _removerMateriaDeProva(Materia materia) async {
    if (_provaFiltroSelecionada == null) {
      CustomSnackBar.showWarning(
        context,
        'Selecione uma prova para remover a matéria',
      );
      return;
    }
    final bool? confirmar = await ModernDialog.showConfirmDialog(
      context: context,
      icon: Icons.remove_circle_outline_rounded,
      iconColor: Colors.orange,
      title: 'Remover matéria da prova',
      content:
          'Tem certeza que deseja remover "${materia.nome}" da prova "${_provaFiltroSelecionada!.titulo}"?',
      infoText:
          'A matéria será movida para "Não utilizadas" se não estiver em uso em outras provas.',
      infoColor: Colors.blue,
      cancelText: 'Cancelar',
      confirmText: 'Remover',
      confirmColor: Colors.orange,
      isDestructive: true,
    );

    if (confirmar != true) return;

    try {
      // Mostrar indicador de carregamento
      ModernDialog.showLoadingDialog(
        context: context,
        message: 'Removendo matéria...',
        accentColor: Colors.orange,
      ); // Desvincular matéria da prova
      await MateriaService.desvincularMateriaDeProva(
        _provaFiltroSelecionada!.id,
        materia.id,
      );

      // Fechar diálogo de carregamento
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
      if (mounted) {
        CustomSnackBar.showSuccess(
          context,
          'Matéria "${materia.nome}" removida da prova com sucesso!',
        );
        // Recarregar dados mantendo filtro
        await _recarregarDadosComFiltro();
      }
    } catch (e) {
      // Fechar diálogo de carregamento
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
      if (mounted) {
        CustomSnackBar.showError(context, 'Erro ao remover matéria: $e');
      }
    }
  }

  Future<void> _vincularMateriaAProva(Materia materia) async {
    if (_provaFiltroSelecionada == null) {
      CustomSnackBar.showWarning(
        context,
        'Selecione uma prova para vincular a matéria',
      );
      return;
    }
    final bool? confirmar = await ModernDialog.showConfirmDialog(
      context: context,
      icon: Icons.add_circle_outline_rounded,
      iconColor: Colors.green,
      title: 'Vincular matéria à prova',
      content:
          'Tem certeza que deseja vincular "${materia.nome}" à prova "${_provaFiltroSelecionada!.titulo}"?',
      infoText:
          'A matéria será associada à prova e aparecerá na seção "Matérias por vestibular".',
      infoColor: Colors.green,
      cancelText: 'Cancelar',
      confirmText: 'Vincular',
      confirmColor: Colors.green,
    );

    if (confirmar != true) return;

    try {
      // Mostrar indicador de carregamento
      ModernDialog.showLoadingDialog(
        context: context,
        message: 'Vinculando matéria...',
        accentColor: Colors.green,
      );

      // Vincular matéria à prova
      await MateriaService.vincularMateriaAProva(
        _provaFiltroSelecionada!.id,
        materia.id,
      );

      // Fechar diálogo de carregamento
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
      if (mounted) {
        CustomSnackBar.showSuccess(
          context,
          'Matéria "${materia.nome}" vinculada à prova com sucesso!',
        );
        // Recarregar dados mantendo filtro
        await _recarregarDadosComFiltro();
      }
    } catch (e) {
      // Fechar diálogo de carregamento
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
      if (mounted) {
        CustomSnackBar.showError(context, 'Erro ao vincular matéria: $e');
      }
    }
  }

  // Método para validar se a prova do filtro ainda é válida
  Prova? _getValidatedProvaFiltro() {
    if (_provaFiltroSelecionada == null) return null;

    // Verificar se a prova ainda existe na lista atual
    final provaValida = _todasProvas.firstWhere(
      (prova) => prova.id == _provaFiltroSelecionada!.id,
      orElse:
          () => _provaFiltroSelecionada!, // Retorna a original se não encontrar
    );

    // Se não encontrar na lista, retornar null
    if (!_todasProvas.any((prova) => prova.id == _provaFiltroSelecionada!.id)) {
      return null;
    }

    return provaValida;
  }

  // Método auxiliar para recarregar dados mantendo o filtro
  Future<void> _recarregarDadosComFiltro() async {
    final filtroAnterior = _provaFiltroSelecionada;
    await _carregarDados();

    // Restaurar filtro se a prova ainda existir
    if (filtroAnterior != null && mounted) {
      final provaNaLista = _todasProvas.firstWhere(
        (prova) => prova.id == filtroAnterior.id,
        orElse:
            () => filtroAnterior, // Retorna a prova anterior se não encontrar
      );

      if (_todasProvas.any((prova) => prova.id == filtroAnterior.id)) {
        setState(() {
          _provaFiltroSelecionada = provaNaLista;
        });
      }
    }
  }

  Future<void> _deletarMateria(Materia materia) async {
    // Confirmar deleção
    final bool? confirmar = await ModernDialog.showConfirmDialog(
      context: context,
      icon: Icons.delete_outline_rounded,
      iconColor: Colors.red,
      title: 'Deletar matéria',
      content: 'Tem certeza que deseja deletar a matéria "${materia.nome}"?',
      infoText: 'Esta ação é irreversível!',
      infoColor: Colors.red,
      cancelText: 'Cancelar',
      confirmText: 'Deletar',
      confirmColor: Colors.red,
      isDestructive: true,
    );

    if (confirmar != true) return;

    try {
      // Mostrar indicador de carregamento
      ModernDialog.showLoadingDialog(
        context: context,
        message: 'Deletando matéria...',
        accentColor: Colors.red,
      );

      await MateriaService.deletarMateria(materia.id);

      // Fechar diálogo de carregamento
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
      if (mounted) {
        CustomSnackBar.showSuccess(
          context,
          'Matéria "${materia.nome}" deletada com sucesso!',
        );

        // Recarregar dados
        _carregarDados();
      }
    } catch (e) {
      // Fechar diálogo de carregamento
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
      if (mounted) {
        String errorMessage = 'Erro ao deletar matéria: $e';

        // Tratar erros específicos
        if (e.toString().contains(
          'possui provas ou sessoes de estudo associadas',
        )) {
          errorMessage =
              'Não é possível deletar "${materia.nome}" pois ela possui provas ou sessões de estudo associadas. Remova primeiro as dependências.';
          CustomSnackBar.showWarning(context, errorMessage);
        } else if (e.toString().contains('404')) {
          errorMessage = 'Matéria "${materia.nome}" não encontrada.';
          CustomSnackBar.showError(context, errorMessage);
        } else if (e.toString().contains('403')) {
          errorMessage = 'Você não tem permissão para deletar esta matéria.';
          CustomSnackBar.showError(context, errorMessage);
        } else {
          CustomSnackBar.showError(context, errorMessage);
        }
      }
    }
  }

  // Método para adicionar nova matéria
  Future<void> _adicionarMateria() async {
    final nome = _nomeController.text.trim();
    final descricao = _descricaoController.text.trim();
    if (nome.isEmpty) {
      CustomSnackBar.showWarning(
        context,
        'Por favor, insira o nome da matéria',
      );
      return;
    }

    setState(() {
      _isCreatingMateria = true;
    });

    try {
      // Criar objeto Materia
      final novaMateria = Materia(
        id: '', // Será preenchido pela API
        nome: nome,
        disciplina: _selectedCategoria,
        descricao: descricao.isEmpty ? null : descricao,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final materiaCreated = await MateriaService.criarMateria(novaMateria);

      // Limpar campos
      _nomeController.clear();
      _descricaoController.clear();
      setState(() {
        _selectedCategoria = 'Exatas';
      }); // Mostrar sucesso
      if (mounted) {
        CustomSnackBar.showSuccess(
          context,
          'Matéria "${materiaCreated.nome}" criada com sucesso!',
        );

        // Recarregar dados
        _carregarDados();
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.showError(context, 'Erro ao criar matéria: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingMateria = false;
        });
      }
    }
  }

  // Widgets auxiliares para o card de criação de matéria
  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? hint,
    int maxLines = 1,
    bool isRequired = false,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              Text(
                '*',
                style: TextStyle(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(
              0.3,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  DropdownMenuItem<String> _buildCategoryItem(
    String value,
    IconData icon,
    Color color,
  ) {
    return DropdownMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.w500, color: color),
          ),
        ],
      ),
    );
  }
}
