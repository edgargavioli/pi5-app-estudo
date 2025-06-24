import 'package:flutter/material.dart';
import 'package:pi5_ms_mobile/src/components/loading_widget.dart';
import 'package:pi5_ms_mobile/src/shared/models/materia_model.dart';
import 'package:pi5_ms_mobile/src/shared/models/prova_model.dart';
import 'package:pi5_ms_mobile/src/shared/models/evento_model.dart';
import 'package:pi5_ms_mobile/src/shared/services/materia_service.dart';
import 'package:pi5_ms_mobile/src/shared/services/sessao_service.dart';
import 'package:pi5_ms_mobile/src/presentation/estudos/estudo_cronometro_page.dart';

class EstudosProvaPage extends StatefulWidget {
  final Prova prova;

  const EstudosProvaPage({super.key, required this.prova});

  @override
  State<EstudosProvaPage> createState() => _EstudosProvaPageState();
}

class _EstudosProvaPageState extends State<EstudosProvaPage> {
  // API Integration
  List<Materia> _materiasDaProva = [];
  bool _isLoading = true;
  String? _error;
  // Selection
  String? _selectedMateriaId;
  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _carregarDados({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Carregamos as matérias da prova
      _materiasDaProva = widget.prova.materias;

      // Se não temos matérias carregadas, vamos buscar do serviço
      if (_materiasDaProva.isEmpty && widget.prova.materiasIds.isNotEmpty) {
        final todasMaterias = await MateriaService.listarMaterias(
          forceRefresh: forceRefresh,
        );
        _materiasDaProva =
            todasMaterias
                .where(
                  (materia) => widget.prova.materiasIds.contains(materia.id),
                )
                .toList();
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
          // Se há apenas uma matéria, selecionamos automaticamente
          if (_materiasDaProva.length == 1) {
            _selectedMateriaId = _materiasDaProva.first.id;
          }
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Estudar: ${widget.prova.titulo}'),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: () => _carregarDados(forceRefresh: true),
              color: colorScheme.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(
                  left: 20,
                  top: 10,
                  right: 20,
                  bottom: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Informações da prova
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.assignment,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    widget.prova.titulo,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            if (widget.prova.descricao?.isNotEmpty == true) ...[
                              const SizedBox(height: 8),
                              Text(
                                widget.prova.descricao!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),
                            Text(
                              'Matérias desta prova:',
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children:
                                  widget.prova.materias.map((materia) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colorScheme.primaryContainer,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        materia.nome,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: colorScheme.onPrimaryContainer,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Loading state
                    if (_isLoading)
                      const LoadingWidget(
                        message: 'Carregando dados...',
                        size: 48,
                      )
                    else if (_error != null)
                      Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48,
                              color: colorScheme.error,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Erro ao carregar dados',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: colorScheme.error,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _error!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _carregarDados,
                              child: const Text('Tentar novamente'),
                            ),
                          ],
                        ),
                      )
                    else ...[
                      // Seleção de matéria (apenas se houver mais de uma)
                      if (_materiasDaProva.length > 1) ...[
                        DropdownButtonFormField<String>(
                          value: _selectedMateriaId,
                          isExpanded: true,
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 14,
                            color: colorScheme.onSurface,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Matéria para estudar',
                            labelStyle: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: BorderSide(
                                color: colorScheme.outline,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: BorderSide(
                                color: colorScheme.outline,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: BorderSide(
                                color: colorScheme.primary,
                              ),
                            ),
                            prefixIcon: Icon(
                              Icons.menu_book,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          dropdownColor: colorScheme.surface,
                          items:
                              _materiasDaProva.map((materia) {
                                return DropdownMenuItem<String>(
                                  value: materia.id,
                                  child: Text(
                                    materia.nome,
                                    style: TextStyle(
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                );
                              }).toList(),
                          onChanged:
                              (value) =>
                                  setState(() => _selectedMateriaId = value),
                        ),
                        const SizedBox(height: 32),
                      ] else if (_materiasDaProva.length == 1) ...[
                        // Mostrar a matéria única selecionada
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer.withOpacity(
                              0.5,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: colorScheme.primary.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.menu_book, color: colorScheme.primary),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Estudando: ${_materiasDaProva.first.nome}',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],

                      // Botão para iniciar estudo
                      const SizedBox(height: 32),
                      Center(
                        child: ElevatedButton(
                          onPressed: () async {
                            // Verificar se uma matéria foi selecionada
                            String? materiaIdSelecionada = _selectedMateriaId;

                            if (materiaIdSelecionada == null) {
                              if (_materiasDaProva.length == 1) {
                                materiaIdSelecionada =
                                    _materiasDaProva.first.id;
                              } else if (_materiasDaProva.isNotEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      'Selecione uma matéria para estudar',
                                    ),
                                    backgroundColor: colorScheme.error,
                                  ),
                                );
                                return;
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      'Não há matérias disponíveis para esta prova',
                                    ),
                                    backgroundColor: colorScheme.error,
                                  ),
                                );
                                return;
                              }
                            } // Navegar para a página unificada
                            final agora =
                                DateTime.now(); // Criar a sessão no backend primeiro
                            final sessaoTemporaria = SessaoEstudo(
                              id: '', // Será definido pelo backend
                              materiaId: materiaIdSelecionada,
                              provaId: widget.prova.id,
                              conteudo: 'Estudo de ${widget.prova.titulo}',
                              topicos: [
                                'Revisão geral',
                              ], // Adicionar um tópico padrão
                              tempoInicio: null,
                              tempoFim: null,
                              createdAt: agora,
                              updatedAt: agora,
                            );

                            try {
                              // Criar a sessão no backend
                              final sessaoCriada =
                                  await SessaoService.criarSessao(
                                    sessaoTemporaria,
                                  );

                              print(
                                '>> Sessão criada com ID: ${sessaoCriada.id}',
                              );
                              final resultado = await Navigator.push<bool>(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => EstudoCronometroPage(
                                        sessao: sessaoCriada,
                                      ),
                                ),
                              );

                              if (resultado == true) {
                                Navigator.of(context).pop(true);
                              }
                            } catch (e) {
                              print('>> Erro ao criar sessão: $e');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Erro ao criar sessão: $e'),
                                  backgroundColor:
                                      Theme.of(context).colorScheme.error,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            minimumSize: const Size.fromHeight(56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                            shadowColor: Colors.black26,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.timer, size: 24),
                              const SizedBox(width: 12),
                              Text(
                                'Iniciar Estudo',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: colorScheme.onPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ], // Fecha else if
                  ], // Fecha else principal
                ), // Fecha Column
              ), // Fecha SingleChildScrollView child
            ), // Fecha RefreshIndicator
          ], // Fecha Stack children
        ), // Fecha Stack
      ), // Fecha SafeArea body
    );
  }
}
