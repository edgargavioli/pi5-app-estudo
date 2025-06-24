import 'package:flutter/material.dart';
import '../../shared/models/evento_model.dart';
import '../../shared/models/prova_model.dart';
import '../../shared/models/materia_model.dart';
import '../../shared/services/sessao_service.dart';
import '../../shared/services/prova_service.dart';
import '../../shared/services/materia_service.dart';
import '../../shared/widgets/custom_snackbar.dart';

class AgendarSessaoPage extends StatefulWidget {
  final DateTime? dataInicial;

  const AgendarSessaoPage({super.key, this.dataInicial});

  @override
  State<AgendarSessaoPage> createState() => _AgendarSessaoPageState();
}

class _AgendarSessaoPageState extends State<AgendarSessaoPage> {
  final _formKey = GlobalKey<FormState>();
  final _conteudoController = TextEditingController();
  final _novoTopicoController = TextEditingController();
  List<Prova> _provas = [];
  List<Materia> _materias = [];
  List<Materia> _materiasDisponiveis =
      []; // Matérias filtradas pela prova selecionada
  final List<String> _topicos = [];

  Prova? _provaSelecionada;
  Materia? _materiaSelecionada;
  DateTime? _dataSelecionada;
  TimeOfDay? _horarioInicio;
  int _metaTempoMinutos = 60;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _showValidationErrors = false;

  @override
  void initState() {
    super.initState();
    _dataSelecionada = widget.dataInicial ?? DateTime.now();
    _carregarDados();
  }

  @override
  void dispose() {
    _conteudoController.dispose();
    _novoTopicoController.dispose();
    super.dispose();
  }

  Future<void> _carregarDados() async {
    try {
      final provas = await ProvaService.listarProvas();
      final materias = await MateriaService.listarMaterias();
      if (mounted) {
        setState(() {
          _provas = provas;
          _materias = materias;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.showError(context, 'Erro ao carregar dados: $e');
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selecionarData() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('pt', 'BR'),
    );

    if (data != null) {
      setState(() {
        _dataSelecionada = data;
      });
    }
  }

  Future<void> _selecionarHorario() async {
    final horario = await showTimePicker(
      context: context,
      initialTime: _horarioInicio ?? TimeOfDay.now(),
    );

    if (horario != null) {
      setState(() {
        _horarioInicio = horario;
      });
    }
  }

  void _adicionarTopico() {
    final novoTopico = _novoTopicoController.text.trim();
    if (novoTopico.isNotEmpty && !_topicos.contains(novoTopico)) {
      setState(() {
        _topicos.add(novoTopico);
        _novoTopicoController.clear();
      });
    }
  }

  void _removerTopico(int index) {
    setState(() {
      _topicos.removeAt(index);
    });
  }

  void _filtrarMateriasPorProva(Prova? prova) {
    setState(() {
      _provaSelecionada = prova;
      _materiaSelecionada = null; // Reset matéria quando prova muda

      if (prova != null) {
        // Filtrar matérias que pertencem à prova selecionada
        _materiasDisponiveis =
            _materias.where((materia) {
              return prova.materiasIds.contains(materia.id);
            }).toList();
      } else {
        _materiasDisponiveis = [];
      }
    });
  }

  Future<void> _agendarSessao() async {
    setState(() => _showValidationErrors = true);

    if (!_formKey.currentState!.validate()) return;
    if (_materiaSelecionada == null) {
      CustomSnackBar.showError(context, 'Selecione uma matéria');
      return;
    }
    if (_provaSelecionada == null) {
      CustomSnackBar.showError(context, 'Selecione uma prova');
      return;
    }
    if (_dataSelecionada == null) {
      CustomSnackBar.showError(context, 'Selecione uma data');
      return;
    }
    if (_horarioInicio == null) {
      CustomSnackBar.showError(context, 'Selecione um horário');
      return;
    }

    if (_topicos.isEmpty) {
      CustomSnackBar.showError(context, 'Adicione pelo menos um tópico');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final horarioAgendado = DateTime(
        _dataSelecionada!.year,
        _dataSelecionada!.month,
        _dataSelecionada!.day,
        _horarioInicio!.hour,
        _horarioInicio!.minute,
      );

      final sessao = SessaoEstudo(
        id: '',
        materiaId: _materiaSelecionada!.id,
        provaId: _provaSelecionada?.id,
        eventoId: null,
        conteudo: _conteudoController.text,
        topicos: _topicos,
        tempoInicio: null,
        tempoFim: null,
        isAgendada: true,
        cumpriuPrazo: null,
        horarioAgendado: horarioAgendado,
        metaTempo: _metaTempoMinutos,
        questoesAcertadas: 0,
        totalQuestoes: 0,
        finalizada: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await SessaoService.criarSessao(sessao);

      if (mounted) {
        CustomSnackBar.showSuccess(context, 'Sessão agendada com sucesso!');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.showError(context, 'Erro ao agendar sessão: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendar Sessão de Estudo'),
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading ? _buildLoadingState(theme) : _buildContent(theme),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            'Carregando dados...',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          _buildHeaderCard(theme),
          const SizedBox(height: 24),

          // Form
          Form(
            key: _formKey,
            child: Column(
              children: [
                // Informações Básicas
                _buildBasicInfoCard(theme),
                const SizedBox(height: 16),

                // Seleção de Matéria e Prova
                _buildSubjectCard(theme),
                const SizedBox(height: 16),

                // Tópicos de Estudo
                _buildTopicsCard(theme),
                const SizedBox(height: 16),

                // Data e Horário
                _buildDateTimeCard(theme),
                const SizedBox(height: 16),

                // Meta de Tempo
                _buildGoalCard(theme),
                const SizedBox(height: 32),

                // Botão de Agendar
                _buildCreateButton(theme),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(ThemeData theme) {
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.schedule_rounded,
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
                    'Agendar Sessão',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Organize seus estudos com horário e metas definidas',
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

  Widget _buildBasicInfoCard(ThemeData theme) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.edit_note_rounded,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Informações da Sessão',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            _buildInputField(
              label: 'Conteúdo da sessão',
              controller: _conteudoController,
              icon: Icons.description_rounded,
              hint: 'Descreva o que será estudado nesta sessão...',
              maxLines: 3,
              isRequired: true,
              validator:
                  (value) =>
                      value?.isEmpty == true ? 'Informe o conteúdo' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectCard(ThemeData theme) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.school_rounded,
                  color: theme.colorScheme.secondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Prova e Matéria',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Texto explicativo
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Primeiro selecione a prova, depois escolha uma matéria relacionada',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Dropdown de Prova (primeiro)
            _buildDropdownField<Prova>(
              label: 'Prova',
              icon: Icons.quiz_rounded,
              value: _provaSelecionada,
              items: _provas,
              itemBuilder: (prova) => prova.titulo,
              onChanged: _filtrarMateriasPorProva,
              isRequired: true,
              hasError: _showValidationErrors,
            ),

            const SizedBox(height: 16),

            // Dropdown de Matéria (segundo, dependente da prova)
            _buildDropdownField<Materia>(
              label: 'Matéria',
              icon: Icons.book_rounded,
              value: _materiaSelecionada,
              items: _materiasDisponiveis,
              itemBuilder: (materia) => materia.nome,
              onChanged: (materia) {
                setState(() => _materiaSelecionada = materia);
              },
              isRequired: true,
              hasError: _showValidationErrors,
              isDisabled: _provaSelecionada == null,
              disabledHint: 'Selecione uma prova primeiro',
            ),

            if (_showValidationErrors &&
                (_provaSelecionada == null || _materiaSelecionada == null)) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.error.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: theme.colorScheme.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _provaSelecionada == null
                            ? 'Selecione uma prova primeiro, depois escolha a matéria'
                            : 'Selecione uma matéria da prova escolhida',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (_provaSelecionada != null && _materiasDisponiveis.isEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.secondary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: theme.colorScheme.secondary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Esta prova não tem matérias associadas. Verifique o cadastro da prova.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.w500,
                        ),
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

  Widget _buildTopicsCard(ThemeData theme) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.topic_rounded,
                  color: theme.colorScheme.tertiary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Tópicos de Estudo',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.tertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Campo para adicionar novo tópico
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    label: 'Adicionar tópico',
                    controller: _novoTopicoController,
                    icon: Icons.add_rounded,
                    hint: 'Ex: Funções, Derivadas, Integrais...',
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: _adicionarTopico,
                    icon: const Icon(Icons.add_rounded),
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ],
            ),

            if (_topicos.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Tópicos adicionados:',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    _topicos.asMap().entries.map((entry) {
                      final index = entry.key;
                      final topico = entry.value;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: theme.colorScheme.outline.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              topico,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () => _removerTopico(index),
                              child: Icon(
                                Icons.close_rounded,
                                size: 14,
                                color: theme.colorScheme.error,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
            ],

            if (_topicos.isEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.error.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: theme.colorScheme.error,
                      size: 20,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Adicione pelo menos um tópico',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
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

  Widget _buildDateTimeCard(ThemeData theme) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  color: theme.colorScheme.secondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Data e Horário',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: _buildDateSelector(
                    label: 'Data',
                    icon: Icons.calendar_today_rounded,
                    value:
                        _dataSelecionada != null
                            ? '${_dataSelecionada!.day.toString().padLeft(2, '0')}/${_dataSelecionada!.month.toString().padLeft(2, '0')}/${_dataSelecionada!.year}'
                            : 'Selecionar data',
                    onTap: _selecionarData,
                    theme: theme,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDateSelector(
                    label: 'Horário',
                    icon: Icons.access_time_rounded,
                    value:
                        _horarioInicio != null
                            ? _horarioInicio!.format(context)
                            : 'Selecionar horário',
                    onTap: _selecionarHorario,
                    theme: theme,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard(ThemeData theme) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.timer_rounded,
                  color: theme.colorScheme.tertiary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Meta de Tempo',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.tertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(
                  0.3,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Duração da sessão:',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_metaTempoMinutos}min',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: theme.colorScheme.primary,
                      inactiveTrackColor: theme.colorScheme.outline.withOpacity(
                        0.2,
                      ),
                      thumbColor: theme.colorScheme.primary,
                      overlayColor: theme.colorScheme.primary.withOpacity(0.2),
                      valueIndicatorColor: theme.colorScheme.primary,
                      valueIndicatorTextStyle: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: Slider(
                      value: _metaTempoMinutos.toDouble(),
                      min: 15,
                      max: 240,
                      divisions: 15,
                      label: '${_metaTempoMinutos}min',
                      onChanged: (value) {
                        setState(() => _metaTempoMinutos = value.round());
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '15min',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '240min',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _agendarSessao,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          elevation: 2,
          shadowColor: theme.colorScheme.primary.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child:
            _isSaving
                ? SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.onPrimary,
                    ),
                  ),
                )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.schedule_rounded, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Agendar Sessão',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  // Widgets auxiliares
  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? hint,
    int maxLines = 1,
    bool isRequired = false,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
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
          keyboardType: keyboardType,
          validator: validator,
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

  Widget _buildDropdownField<T>({
    required String label,
    required IconData icon,
    T? value,
    required List<T> items,
    required String Function(T) itemBuilder,
    required void Function(T?) onChanged,
    bool isRequired = false,
    bool hasError = false,
    bool isDisabled = false,
    String? disabledHint,
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
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  hasError && value == null
                      ? theme.colorScheme.error
                      : theme.colorScheme.outline.withOpacity(0.2),
              width: hasError && value == null ? 2 : 1,
            ),
          ),
          child: DropdownButtonFormField<T>(
            value: value,
            decoration: InputDecoration(
              filled: true,
              fillColor:
                  isDisabled
                      ? theme.colorScheme.surfaceContainerHighest.withOpacity(
                        0.1,
                      )
                      : hasError && value == null
                      ? theme.colorScheme.errorContainer.withOpacity(0.1)
                      : theme.colorScheme.surfaceContainerHighest.withOpacity(
                        0.3,
                      ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              hintText:
                  isDisabled
                      ? disabledHint ?? 'Não disponível'
                      : isRequired
                      ? 'Selecione uma opção *'
                      : 'Selecione uma opção',
              hintStyle: TextStyle(
                color:
                    isDisabled
                        ? theme.colorScheme.onSurfaceVariant.withOpacity(0.5)
                        : hasError && value == null
                        ? theme.colorScheme.error
                        : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color:
                  isDisabled
                      ? theme.colorScheme.onSurfaceVariant.withOpacity(0.5)
                      : hasError && value == null
                      ? theme.colorScheme.error
                      : theme.colorScheme.primary,
            ),
            items:
                isDisabled
                    ? []
                    : items
                        .map(
                          (item) => DropdownMenuItem<T>(
                            value: item,
                            child: Text(itemBuilder(item)),
                          ),
                        )
                        .toList(),
            onChanged: isDisabled ? null : onChanged,
            validator:
                isRequired
                    ? (value) => value == null ? 'Campo obrigatório' : null
                    : null,
          ),
        ),
        if (hasError && value == null && isRequired && !isDisabled) ...[
          const SizedBox(height: 4),
          Text(
            'Campo obrigatório',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDateSelector({
    required String label,
    required IconData icon,
    required String value,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: theme.colorScheme.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color:
                    value.contains('Selecionar')
                        ? theme.colorScheme.onSurfaceVariant
                        : theme.colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
