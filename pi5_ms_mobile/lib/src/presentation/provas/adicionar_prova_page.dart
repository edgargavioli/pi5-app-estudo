import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../components/input_widget.dart';
import '../../shared/models/prova_model.dart';
import '../../shared/services/prova_service.dart';
import '../../shared/services/materia_service.dart';

class AdicionarProvaPage extends StatefulWidget {
  const AdicionarProvaPage({super.key});

  @override
  State<AdicionarProvaPage> createState() => _AdicionarProvaPageState();
}

class _AdicionarProvaPageState extends State<AdicionarProvaPage> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController dataProvaController = TextEditingController();
  final TextEditingController localController = TextEditingController();
  final TextEditingController descricaoController = TextEditingController();
  final TextEditingController totalQuestoesController = TextEditingController();

  DateTime? _dataSelecionada;
  TimeOfDay? _horarioSelecionado;
  List<Materia> _materias = [];
  final List<String> _materiasSelecionadasIds = [];
  bool _isLoading = false;
  bool _isCreatingMateria = false;

  @override
  void initState() {
    super.initState();
    _carregarMaterias();
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

  Future<void> _criarNovaMateria() async {
    final TextEditingController nomeMateria = TextEditingController();
    final TextEditingController categoriaMateria = TextEditingController();
    String? categoriaSelecionada = 'Exatas';

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(
                    Icons.add_circle,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  const Text('Nova Matéria'),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InputWidget(
                      labelText: 'Nome da matéria',
                      controller: nomeMateria,
                      width: double.infinity,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: categoriaSelecionada,
                      decoration: const InputDecoration(
                        labelText: 'Categoria',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: const [
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
                        DropdownMenuItem(
                          value: 'Línguas',
                          child: Text('Línguas'),
                        ),
                        DropdownMenuItem(
                          value: 'Outras',
                          child: Text('Outras'),
                        ),
                      ],
                      onChanged: (value) {
                        setStateDialog(() {
                          categoriaSelecionada = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed:
                      _isCreatingMateria
                          ? null
                          : () {
                            Navigator.of(context).pop(false);
                          },
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed:
                      _isCreatingMateria
                          ? null
                          : () async {
                            if (nomeMateria.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Por favor, insira o nome da matéria',
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
                                disciplina: categoriaSelecionada ?? 'Outras',
                                descricao: categoriaSelecionada ?? 'Outras',
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
                                _materiasSelecionadasIds.add(materiaCreated.id);
                              });

                              if (mounted) {
                                Navigator.of(context).pop(true);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Matéria "${materiaCreated.nome}" criada e selecionada!',
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Erro ao criar matéria: $e'),
                                    backgroundColor: Colors.red,
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
                  child:
                      _isCreatingMateria
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Text('Criar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _selecionarData() async {
    DateTime? data = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
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
      initialTime: TimeOfDay.now(),
    );

    if (horario != null) {
      setState(() {
        _horarioSelecionado = horario;
      });
    }
  }

  Future<void> _criarProva() async {
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

      // Converter total de questões se fornecido
      int? totalQuestoes;
      if (totalQuestoesController.text.isNotEmpty) {
        totalQuestoes = int.tryParse(totalQuestoesController.text);
        if (totalQuestoes == null || totalQuestoes <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Total de questões deve ser um número válido maior que zero',
              ),
            ),
          );
          return;
        }
      }

      final novaProva = Prova(
        id: '', // Será gerado pelo backend
        titulo: nomeController.text,
        descricao:
            descricaoController.text.isEmpty ? null : descricaoController.text,
        data: dataProva,
        horario: dataHorario,
        local: localController.text,
        materiasIds: _materiasSelecionadasIds,
        filtros: null,
        totalQuestoes: totalQuestoes,
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
      );

      await ProvaService.criarProva(novaProva);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Prova criada com sucesso!')),
        );

        Navigator.of(context).pop(true); // Indica que uma prova foi criada
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao criar prova: $e')));
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, insira o nome da prova')),
      );
      return false;
    }

    if (_dataSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione a data da prova')),
      );
      return false;
    }

    if (_horarioSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione o horário da prova'),
        ),
      );
      return false;
    }

    if (localController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, insira o local da prova')),
      );
      return false;
    }

    if (_materiasSelecionadasIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione pelo menos uma matéria'),
        ),
      );
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Adicionar Prova',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(height: 32),

              InputWidget(
                labelText: 'Nome da prova',
                controller: nomeController,
                width: double.infinity,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.title_outlined),
                ),
              ),
              const SizedBox(height: 12),

              InputWidget(
                labelText: 'Descrição (opcional)',
                controller: descricaoController,
                width: double.infinity,
                maxLines: 3,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.description_outlined),
                ),
              ),
              const SizedBox(height: 12),

              InputWidget(
                labelText: 'Data da prova',
                controller: dataProvaController,
                width: double.infinity,
                readOnly: true,
                onTap: _selecionarData,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.calendar_today_outlined),
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
              ),
              const SizedBox(height: 12),

              // Campo de horário
              TextField(
                readOnly: true,
                onTap: _selecionarHorario,
                decoration: InputDecoration(
                  labelText: 'Horário da prova',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.access_time_outlined),
                  suffixIcon: const Icon(Icons.access_time),
                  hintText:
                      _horarioSelecionado != null
                          ? _horarioSelecionado!.format(context)
                          : 'Selecione o horário',
                ),
              ),
              const SizedBox(height: 12),

              InputWidget(
                labelText: 'Local da prova',
                controller: localController,
                width: double.infinity,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 12),

              InputWidget(
                labelText: 'Total de questões (opcional)',
                controller: totalQuestoesController,
                width: double.infinity,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                hintText: 'Ex: 10, 20, 50...',
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.format_list_numbered_outlined),
                ),
              ),
              const SizedBox(height: 12),

              // Seleção múltipla de matérias
              Card(
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
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Toque nas matérias para selecioná-las:',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
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
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Nenhuma matéria disponível',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildCreateMateriaChip(),
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
              ),

              const SizedBox(height: 80), // Espaço para o botão flutuante
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "adicionar_prova_save_fab",
        onPressed: _isLoading ? null : _criarProva,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child:
            _isLoading
                ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.onPrimary,
                    strokeWidth: 2,
                  ),
                )
                : Icon(
                  Icons.check,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
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
          color:
              _isCreatingMateria
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.7)
                  : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
            style: BorderStyle.values[1], // dashed style
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
                  color: Theme.of(context).colorScheme.onPrimary,
                  strokeWidth: 2,
                ),
              )
            else
              Icon(
                Icons.add,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
            const SizedBox(width: 6),
            Text(
              'Criar Nova Matéria',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color:
                    _isCreatingMateria
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.primary,
              ),
            ),
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
                padding: const EdgeInsets.only(bottom: 8, top: 16),
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
}
