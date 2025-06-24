import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:pi5_ms_mobile/src/shared/models/materia_model.dart';
import 'package:pi5_ms_mobile/src/shared/models/prova_model.dart';
import 'package:pi5_ms_mobile/src/shared/services/prova_service.dart';
import 'package:pi5_ms_mobile/src/shared/services/materia_service.dart';
import 'package:pi5_ms_mobile/src/shared/widgets/custom_snackbar.dart';

class EditProvaPage extends StatefulWidget {
  final Prova prova;

  const EditProvaPage({super.key, required this.prova});

  @override
  State<EditProvaPage> createState() => _EditProvaPageState();
}

class _EditProvaPageState extends State<EditProvaPage> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController dataProvaController = TextEditingController();
  final TextEditingController localController = TextEditingController();
  final TextEditingController descricaoController = TextEditingController();
  final TextEditingController materiaController = TextEditingController();
  DateTime? _dataSelecionada;
  TimeOfDay? _horarioSelecionado;
  List<Materia> _materias = [];
  List<String> _materiasSelecionadasIds = [];
  bool _isLoading = false;
  bool _isCreatingMateria = false;

  @override
  void initState() {
    super.initState();
    _preencherDados();
    _carregarMaterias();
  }

  void _preencherDados() {
    nomeController.text = widget.prova.titulo;
    descricaoController.text = widget.prova.descricao ?? '';
    localController.text = widget.prova.local;
    _dataSelecionada = widget.prova.data;
    _horarioSelecionado = TimeOfDay.fromDateTime(widget.prova.horario);
    _materiasSelecionadasIds = List.from(widget.prova.materiasIds);

    // Formatando data para exibição
    if (_dataSelecionada != null) {
      final formato = DateFormat('dd/MM/yyyy');
      dataProvaController.text = formato.format(_dataSelecionada!);
    }
  }

  Future<void> _carregarMaterias() async {
    try {
      final materias = await MateriaService.listarMaterias();
      setState(() {
        _materias = materias;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao carregar matérias: $e')));
    }
  }

  Future<void> _selecionarData() async {
    DateTime? data = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (data != null) {
      setState(() {
        _dataSelecionada = data;
        final formato = DateFormat('dd/MM/yyyy');
        dataProvaController.text = formato.format(data);
      });
    }
  }

  Future<void> _selecionarHorario() async {
    TimeOfDay? horario = await showTimePicker(
      context: context,
      initialTime: _horarioSelecionado ?? TimeOfDay.now(),
    );

    if (horario != null) {
      setState(() {
        _horarioSelecionado = horario;
      });
    }
  }

  Future<void> _salvarProva() async {
    if (!_validarCampos()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Combinando data e horário em UTC
      final dataHorario = DateTime.utc(
        _dataSelecionada!.year,
        _dataSelecionada!.month,
        _dataSelecionada!.day,
        _horarioSelecionado!.hour,
        _horarioSelecionado!.minute,
      );

      // Data da prova também em UTC
      final dataProva = DateTime.utc(
        _dataSelecionada!.year,
        _dataSelecionada!.month,
        _dataSelecionada!.day,
      );

      final provaAtualizada = Prova(
        id: widget.prova.id,
        titulo: nomeController.text,
        descricao:
            descricaoController.text.isEmpty ? null : descricaoController.text,
        data: dataProva,
        horario: dataHorario,
        local: localController.text,
        materiasIds: _materiasSelecionadasIds,
        filtros: widget.prova.filtros, // Mantém os filtros existentes
        createdAt: widget.prova.createdAt,
        updatedAt: DateTime.now().toUtc(),
      );

      await ProvaService.atualizarProva(widget.prova.id, provaAtualizada);
      if (mounted) {
        CustomSnackBar.showSuccess(context, 'Prova atualizada com sucesso!');

        Navigator.of(context).pop(true); // Indica que houve alteração
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.showError(context, 'Erro ao atualizar prova: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _validarCampos() {
    if (nomeController.text.isEmpty) {
      CustomSnackBar.showWarning(context, 'Por favor, insira o nome da prova');
      return false;
    }
    if (_dataSelecionada == null) {
      CustomSnackBar.showWarning(
        context,
        'Por favor, selecione a data da prova',
      );
      return false;
    }
    if (_horarioSelecionado == null) {
      CustomSnackBar.showWarning(
        context,
        'Por favor, selecione o horário da prova',
      );
      return false;
    }
    if (localController.text.isEmpty) {
      CustomSnackBar.showWarning(context, 'Por favor, insira o local da prova');
      return false;
    }
    if (_materiasSelecionadasIds.isEmpty) {
      CustomSnackBar.showWarning(
        context,
        'Por favor, selecione pelo menos uma matéria',
      );
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: BackButton(color: colorScheme.onSurface),
        title: Text(
          'Editar Prova',
          style: TextStyle(color: colorScheme.onSurface),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _campoTexto('Nome da prova', nomeController),
                    const SizedBox(height: 12),
                    _campoTexto('Descrição (opcional)', descricaoController),
                    const SizedBox(height: 12),
                    _campoTextoData('Data da prova', dataProvaController),
                    const SizedBox(height: 12),
                    _campoHorario(),
                    const SizedBox(height: 12),
                    _campoTexto('Local da prova', localController),
                    const SizedBox(height: 12),
                    _campoMateria(),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: FloatingActionButton(
                  heroTag: "editar_prova_save_fab",
                  backgroundColor: colorScheme.primary,
                  tooltip: 'Salvar alterações',
                  onPressed: _isLoading ? null : _salvarProva,
                  child:
                      _isLoading
                          ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: colorScheme.onPrimary,
                              strokeWidth: 2,
                            ),
                          )
                          : Icon(Icons.check, color: colorScheme.onPrimary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _campoTexto(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _campoTextoData(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      readOnly: true,
      onTap: _selecionarData,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: const Icon(Icons.calendar_today),
      ),
    );
  }

  Widget _campoHorario() {
    return TextField(
      readOnly: true,
      onTap: _selecionarHorario,
      decoration: InputDecoration(
        labelText: 'Horário da prova',
        border: const OutlineInputBorder(),
        suffixIcon: const Icon(Icons.access_time),
        hintText:
            _horarioSelecionado != null
                ? _horarioSelecionado!.format(context)
                : 'Selecione o horário',
      ),
    );
  }

  Widget _campoMateria() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.school,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Matérias da Prova',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Toque nas matérias para selecioná-las:',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),

            if (_materias.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      'Nenhuma matéria disponível',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
            else
              _buildMateriasSelection(),

            if (_materiasSelecionadasIds.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_materiasSelecionadasIds.length} matéria${_materiasSelecionadasIds.length > 1 ? 's' : ''} selecionada${_materiasSelecionadasIds.length > 1 ? 's' : ''}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMateriasSelection() {
    // Agrupar matérias por categoria
    final Map<String, List<Materia>> materiasPorCategoria = {};
    for (final materia in _materias) {
      final categoria =
          materia.categoria.isNotEmpty ? materia.categoria : 'Outras';
      materiasPorCategoria.putIfAbsent(categoria, () => []).add(materia);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mostrar as matérias por categoria
        ...materiasPorCategoria.entries.map((entry) {
          final categoria = entry.key;
          final materias = entry.value;
          final isFirstCategory =
              materiasPorCategoria.entries.first.key == categoria;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título da categoria
              Padding(
                padding: const EdgeInsets.only(bottom: 8, top: 12),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 16,
                      decoration: BoxDecoration(
                        color: _getCategoriaColor(categoria),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      categoria,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _getCategoriaColor(categoria),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getCategoriaColor(categoria).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${materias.length}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: _getCategoriaColor(categoria),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Chips das matérias + chip criar nova matéria (na primeira categoria)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  // Incluir o chip de criar nova matéria apenas na primeira categoria
                  if (isFirstCategory) _buildCreateMateriaChip(),

                  // Chips das matérias desta categoria
                  ...materias.map((materia) {
                    final isSelected = _materiasSelecionadasIds.contains(
                      materia.id,
                    );
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _materiasSelecionadasIds.remove(materia.id);
                          } else {
                            _materiasSelecionadasIds.add(materia.id);
                          }
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color:
                                isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.outline,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow:
                              isSelected
                                  ? [
                                    BoxShadow(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                  : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isSelected) ...[
                              Icon(
                                Icons.check_circle,
                                size: 16,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                              const SizedBox(width: 6),
                            ],
                            Text(
                              materia.nome,
                              style: TextStyle(
                                color:
                                    isSelected
                                        ? Theme.of(
                                          context,
                                        ).colorScheme.onPrimary
                                        : Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                fontWeight:
                                    isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),

              if (entry != materiasPorCategoria.entries.last)
                const SizedBox(height: 8),
            ],
          );
        }),

        // Se não há matérias, mostrar apenas o chip de criar nova matéria
        if (materiasPorCategoria.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [_buildCreateMateriaChip()],
            ),
          ),
      ],
    );
  }

  Color _getCategoriaColor(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'exatas':
        return Colors.blue;
      case 'humanas':
        return Colors.green;
      case 'biológicas':
      case 'biologicas':
        return Colors.orange;
      case 'línguas':
      case 'linguas':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Future<void> _criarNovaMateria() async {
    final TextEditingController nomeMateria = TextEditingController();
    final TextEditingController descricaoMateria = TextEditingController();
    String? categoriaSelecionada = 'Exatas';

    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header do dialog
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Theme.of(
                              context,
                            ).colorScheme.primaryContainer.withOpacity(0.8),
                            Theme.of(
                              context,
                            ).colorScheme.primaryContainer.withOpacity(0.4),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Icon(
                              Icons.school_rounded,
                              size: 32,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Nova Matéria',
                            style: Theme.of(
                              context,
                            ).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Adicione uma nova matéria aos seus estudos',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Campos do formulário
                    _buildDialogInputField(
                      label: 'Nome da matéria',
                      controller: nomeMateria,
                      icon: Icons.book_rounded,
                      hint: 'Ex: Matemática, História, Química...',
                      isRequired: true,
                    ),

                    const SizedBox(height: 16),

                    _buildDialogInputField(
                      label: 'Descrição',
                      controller: descricaoMateria,
                      icon: Icons.description_rounded,
                      hint: 'Adicione uma descrição opcional',
                      maxLines: 2,
                    ),

                    const SizedBox(height: 16),

                    // Dropdown de categoria melhorado
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.category_rounded,
                              size: 18,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Categoria',
                              style: Theme.of(
                                context,
                              ).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '*',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
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
                              color: Theme.of(
                                context,
                              ).colorScheme.outline.withOpacity(0.2),
                            ),
                          ),
                          child: DropdownButtonFormField<String>(
                            value: categoriaSelecionada,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
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
                              color: Theme.of(context).colorScheme.primary,
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
                              setStateDialog(() {
                                categoriaSelecionada = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Botões de ação
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed:
                                _isCreatingMateria
                                    ? null
                                    : () {
                                      Navigator.of(context).pop(false);
                                    },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
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
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: ElevatedButton(
                            onPressed:
                                _isCreatingMateria
                                    ? null
                                    : () async {
                                      if (nomeMateria.text.trim().isEmpty) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: const Row(
                                              children: [
                                                Icon(
                                                  Icons.warning_rounded,
                                                  color: Colors.white,
                                                ),
                                                SizedBox(width: 8),
                                                Text(
                                                  'Por favor, insira o nome da matéria',
                                                ),
                                              ],
                                            ),
                                            backgroundColor:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.error,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      setStateDialog(() {
                                        _isCreatingMateria = true;
                                      });

                                      try {
                                        // Criar objeto Materia
                                        final novaMateria = Materia(
                                          id: '', // Será preenchido pela API
                                          nome: nomeMateria.text.trim(),
                                          disciplina:
                                              categoriaSelecionada ?? 'Outras',
                                          descricao:
                                              descricaoMateria.text
                                                      .trim()
                                                      .isEmpty
                                                  ? null
                                                  : descricaoMateria.text
                                                      .trim(),
                                          createdAt: DateTime.now(),
                                          updatedAt: DateTime.now(),
                                        );

                                        final materiaCreated =
                                            await MateriaService.criarMateria(
                                              novaMateria,
                                            );

                                        // Adicionar à lista local
                                        setState(() {
                                          _materias.add(materiaCreated);
                                          // Selecionar automaticamente a nova matéria
                                          _materiasSelecionadasIds.add(
                                            materiaCreated.id,
                                          );
                                        });

                                        if (mounted) {
                                          Navigator.of(context).pop(true);
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Row(
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(6),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white
                                                          .withOpacity(0.2),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            20,
                                                          ),
                                                    ),
                                                    child: const Icon(
                                                      Icons
                                                          .check_circle_rounded,
                                                      color: Colors.white,
                                                      size: 20,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        const Text(
                                                          'Matéria criada com sucesso!',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        Text(
                                                          '"${materiaCreated.nome}" foi adicionada e selecionada',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.white
                                                                .withOpacity(
                                                                  0.9,
                                                                ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              backgroundColor: Colors.green,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              duration: const Duration(
                                                seconds: 4,
                                              ),
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Row(
                                                children: [
                                                  const Icon(
                                                    Icons.error_rounded,
                                                    color: Colors.white,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      'Erro ao criar matéria: $e',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              backgroundColor:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.error,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                          );
                                        }
                                      } finally {
                                        if (mounted) {
                                          setStateDialog(() {
                                            _isCreatingMateria = false;
                                          });
                                        }
                                      }
                                    },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              foregroundColor:
                                  Theme.of(context).colorScheme.onPrimary,
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
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                    : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.add_rounded),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Criar Matéria',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.onPrimary,
                                          ),
                                        ),
                                      ],
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
      },
    );
  }

  // Métodos auxiliares para o dialog de criação de matéria
  Widget _buildDialogInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? hint,
    int maxLines = 1,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              Text(
                '*',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
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
            fillColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
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

  Widget _buildCreateMateriaChip() {
    return GestureDetector(
      onTap: _isCreatingMateria ? null : _criarNovaMateria,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.primaryContainer.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isCreatingMateria)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                  strokeWidth: 2,
                ),
              )
            else
              Icon(
                Icons.add,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
            const SizedBox(width: 8),
            Text(
              'Criar Nova Matéria',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Tela de editar prova
