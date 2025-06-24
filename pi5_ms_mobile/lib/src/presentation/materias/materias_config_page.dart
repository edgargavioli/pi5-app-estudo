import 'package:flutter/material.dart';
import 'package:pi5_ms_mobile/src/components/card_widget.dart';
import 'package:pi5_ms_mobile/src/shared/models/materia_model.dart';
import 'package:pi5_ms_mobile/src/shared/services/materia_service.dart';
import 'package:pi5_ms_mobile/src/shared/widgets/modern_dialog.dart';
import 'package:pi5_ms_mobile/src/shared/widgets/custom_snackbar.dart';

class ConfigMateriaPage extends StatefulWidget {
  const ConfigMateriaPage({super.key});

  @override
  State<ConfigMateriaPage> createState() => _ConfigMateriaPageState();
}

class _ConfigMateriaPageState extends State<ConfigMateriaPage> {
  List<Materia> _materias = [];
  List<Materia> _materiasAdicionadas = [];
  List<Materia> _materiasNaoUsadas = [];
  String? _materiaSelecionada;
  String _filtroSelecionado = 'Todas as Matérias';
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _carregarMaterias();
  }

  Future<void> _carregarMaterias() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final materias = await MateriaService.listarMaterias();

      setState(() {
        _materias = materias;
        _materiasAdicionadas = [
          ...materias,
        ]; // Por enquanto, todas as matérias são consideradas "ativas"
        _materiasNaoUsadas = []; // Lista vazia inicialmente
        _materiaSelecionada = materias.isNotEmpty ? materias.first.id : null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erro ao carregar matérias: $e';
      });
    }
  }

  Future<void> _adicionarMateria() async {
    if (_materiaSelecionada != null) {
      final materiaExistente = _materias.firstWhere(
        (m) => m.id == _materiaSelecionada,
        orElse:
            () => Materia(
              id: '',
              nome: '',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
      );

      if (materiaExistente.id.isNotEmpty &&
          !_materiasAdicionadas.any((m) => m.id == materiaExistente.id)) {
        setState(() {
          _materiasAdicionadas.add(materiaExistente);
          _materiasNaoUsadas.removeWhere((m) => m.id == materiaExistente.id);
        });
      }
    }
  }

  Future<void> _criarNovaMateria(String nome, String categoria) async {
    try {
      // Criar objeto Materia
      final novaMateria = Materia(
        id: '', // Será preenchido pela API
        nome: nome,
        disciplina: categoria,
        descricao: categoria,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final materiaCreated = await MateriaService.criarMateria(novaMateria);

      setState(() {
        _materias.add(materiaCreated);
        _materiasNaoUsadas.add(materiaCreated);
        _materiaSelecionada = materiaCreated.id;
      });
      CustomSnackBar.showSuccess(
        context,
        'Matéria "$nome" criada com sucesso!',
      );
    } catch (e) {
      CustomSnackBar.showError(context, 'Erro ao criar matéria: $e');
    }
  }

  Future<void> _removerMateria(Materia materia) async {
    setState(() {
      _materiasAdicionadas.removeWhere((m) => m.id == materia.id);
      if (!_materiasNaoUsadas.any((m) => m.id == materia.id)) {
        _materiasNaoUsadas.add(materia);
      }
    });
  }

  Future<void> _deletarMateria(Materia materia) async {
    try {
      // Mostrar indicador de carregamento
      ModernDialog.showLoadingDialog(
        context: context,
        message: 'Deletando matéria...',
        accentColor: Colors.red,
      );

      await MateriaService.deletarMateria(materia.id);

      // Fechar o diálogo de carregamento
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      setState(() {
        _materias.removeWhere((m) => m.id == materia.id);
        _materiasNaoUsadas.removeWhere((m) => m.id == materia.id);
        _materiasAdicionadas.removeWhere((m) => m.id == materia.id);

        // Se a matéria deletada era a selecionada, selecionar outra
        if (_materiaSelecionada == materia.id) {
          _materiaSelecionada =
              _materias.isNotEmpty ? _materias.first.id : null;
        }
      });
      CustomSnackBar.showSuccess(
        context,
        'Matéria "${materia.nome}" deletada com sucesso!',
      );
    } catch (e) {
      // Fechar o diálogo de carregamento se ainda estiver aberto
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
      String errorMessage = e.toString().replaceFirst('Exception: ', '');

      // Verificar se é erro de dependência
      if (errorMessage.contains('possui provas ou sessões') ||
          errorMessage.contains('associadas') ||
          errorMessage.contains('500')) {
        errorMessage =
            'Não é possível deletar "${materia.nome}" pois ela possui provas ou sessões de estudo associadas. Remova primeiro as dependências.';
        CustomSnackBar.showWarning(context, errorMessage);
      } else if (errorMessage.contains('404')) {
        errorMessage = 'Matéria "${materia.nome}" não encontrada.';
        CustomSnackBar.showError(context, errorMessage);
      } else if (errorMessage.contains('403')) {
        errorMessage = 'Você não tem permissão para deletar esta matéria.';
        CustomSnackBar.showError(context, errorMessage);
      } else {
        CustomSnackBar.showError(context, errorMessage);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Configurações - Matérias'),
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Configurações - Matérias'),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _carregarMaterias,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    final filteredMaterias =
        _materiasAdicionadas.where((materia) {
          switch (_filtroSelecionado) {
            case 'Exatas':
              return materia.categoria.toLowerCase().contains('exatas');
            case 'Humanas':
              return materia.categoria.toLowerCase().contains('humanas');
            case 'Biológicas':
              return materia.categoria.toLowerCase().contains('biológicas');
            case 'Todas as Matérias':
            default:
              return true;
          }
        }).toList();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Configurações - Matérias'),
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregarMaterias,
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _carregarMaterias,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Seção: Adicionar matéria
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Adicionar Nova Matéria",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (_materias.isNotEmpty) ...[
                        DropdownButtonFormField<String>(
                          value: _materiaSelecionada,
                          items:
                              _materias
                                  .map(
                                    (materia) => DropdownMenuItem(
                                      value: materia.id,
                                      child: Text(
                                        '${materia.nome} (${materia.categoria})',
                                      ),
                                    ),
                                  )
                                  .toList()
                                ..add(
                                  DropdownMenuItem(
                                    value: "nova_materia",
                                    child: Text(
                                      "Criar nova matéria...",
                                      style: TextStyle(
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ),
                          onChanged: (value) {
                            if (value == "nova_materia") {
                              _mostrarDialogNovaMateria();
                            } else {
                              setState(() => _materiaSelecionada = value);
                            }
                          },
                          decoration: const InputDecoration(
                            labelText: "Selecionar matéria",
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: _adicionarMateria,
                            icon: const Icon(Icons.add),
                            label: const Text("Adicionar matéria"),
                          ),
                        ),
                      ] else ...[
                        ElevatedButton.icon(
                          onPressed: _mostrarDialogNovaMateria,
                          icon: const Icon(Icons.add),
                          label: const Text("Criar primeira matéria"),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Seção: Matérias por disciplina
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Matérias por Disciplina",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 12),

                      DropdownButtonFormField<String>(
                        value: _filtroSelecionado,
                        onChanged: (value) {
                          setState(() => _filtroSelecionado = value!);
                        },
                        decoration: const InputDecoration(
                          labelText: 'Filtrar por Disciplina',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Todas as Matérias',
                            child: Text('Todas as Matérias'),
                          ),
                          DropdownMenuItem(
                            value: 'Exatas',
                            child: Text('Exatas'),
                          ),
                          DropdownMenuItem(
                            value: 'Humanas',
                            child: Text('Humanas'),
                          ),
                          DropdownMenuItem(
                            value: 'Biológicas',
                            child: Text('Biológicas'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Lista de matérias filtradas
                      if (filteredMaterias.isNotEmpty) ...[
                        Text(
                          "Matérias ativas (${filteredMaterias.length})",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...filteredMaterias.map(
                          (materia) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: CardWidget(
                              title: '${materia.nome} (${materia.categoria})',
                              icon: Icons.book,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.remove_circle,
                                      color: theme.colorScheme.secondary,
                                    ),
                                    onPressed: () => _removerMateria(materia),
                                    tooltip: 'Remover da lista ativa',
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: theme.colorScheme.error,
                                    ),
                                    onPressed: () => _confirmarDelecao(materia),
                                    tooltip: 'Deletar permanentemente',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "Nenhuma matéria encontrada para este filtro",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Seção: Matérias não utilizadas
              if (_materiasNaoUsadas.isNotEmpty) ...[
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Matérias Não Utilizadas",
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 12),

                        Text(
                          "Disponíveis (${_materiasNaoUsadas.length})",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ..._materiasNaoUsadas.map(
                          (materia) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: CardWidget(
                              title: '${materia.nome} (${materia.categoria})',
                              icon: Icons.book_outlined,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.add_circle,
                                      color: theme.colorScheme.primary,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _materiasAdicionadas.add(materia);
                                        _materiasNaoUsadas.remove(materia);
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: theme.colorScheme.error,
                                    ),
                                    onPressed: () => _confirmarDelecao(materia),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Espaço extra para o FloatingActionButton
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "materias_config_save_fab",
        backgroundColor: theme.colorScheme.primary,
        onPressed: () {
          Navigator.pop(context, _materiasAdicionadas);
        },
        icon: Icon(Icons.check, color: theme.colorScheme.onPrimary),
        label: Text(
          "Salvar",
          style: TextStyle(color: theme.colorScheme.onPrimary),
        ),
      ),
    );
  }

  void _mostrarDialogNovaMateria() {
    String novaMateria = "";
    String categoria = "Exatas";

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.surface,
                  Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withOpacity(0.8),
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ícone
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.school_outlined,
                    size: 32,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),

                const SizedBox(height: 20),

                // Título
                Text(
                  'Criar nova matéria',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                // Campo nome
                TextField(
                  onChanged: (text) => novaMateria = text,
                  decoration: InputDecoration(
                    labelText: "Nome da matéria",
                    filled: true,
                    fillColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                    ),
                  ),
                  autofocus: true,
                ),

                const SizedBox(height: 16),

                // Dropdown categoria
                DropdownButtonFormField<String>(
                  value: categoria,
                  decoration: InputDecoration(
                    labelText: "Disciplina",
                    filled: true,
                    fillColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: "Exatas", child: Text("Exatas")),
                    DropdownMenuItem(value: "Humanas", child: Text("Humanas")),
                    DropdownMenuItem(
                      value: "Biológicas",
                      child: Text("Biológicas"),
                    ),
                    DropdownMenuItem(value: "Línguas", child: Text("Línguas")),
                  ],
                  onChanged: (value) => categoria = value ?? "Exatas",
                ),

                const SizedBox(height: 24),

                // Botões
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Theme.of(
                                context,
                              ).colorScheme.outline.withOpacity(0.3),
                            ),
                          ),
                        ),
                        child: Text(
                          'Cancelar',
                          style: Theme.of(
                            context,
                          ).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (novaMateria.isNotEmpty) {
                            Navigator.pop(context);
                            _criarNovaMateria(novaMateria, categoria);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Criar',
                          style: Theme.of(
                            context,
                          ).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmarDelecao(Materia materia) async {
    final confirmou = await ModernDialog.showConfirmDialog(
      context: context,
      icon: Icons.delete_outline_rounded,
      iconColor: Colors.red,
      title: 'Deletar matéria',
      content: 'Tem certeza que deseja deletar a matéria "${materia.nome}"?',
      infoText:
          'Esta ação não pode ser desfeita. A matéria só pode ser deletada se não tiver provas ou sessões de estudo associadas.',
      infoColor: Colors.orange,
      cancelText: 'Cancelar',
      confirmText: 'Deletar',
      confirmColor: Colors.red,
      isDestructive: true,
    );

    if (confirmou == true) {
      _deletarMateria(materia);
    }
  }

  // Filtros por área
  List<Materia> get materiasExatas {
    return _materias
        .where((materia) => materia.categoria.toLowerCase().contains('exatas'))
        .toList();
  }

  List<Materia> get materiasHumanas {
    return _materias
        .where((materia) => materia.categoria.toLowerCase().contains('humanas'))
        .toList();
  }

  List<Materia> get materiasBiologicas {
    return _materias
        .where(
          (materia) => materia.categoria.toLowerCase().contains('biológicas'),
        )
        .toList();
  }
}
