import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../shared/models/evento_model.dart';
import '../../shared/models/prova_model.dart';
import '../../shared/services/evento_service.dart';
import '../../shared/services/prova_service.dart';

class CriarEventoPage extends StatefulWidget {
  final DateTime? dataInicial;

  const CriarEventoPage({super.key, this.dataInicial});

  @override
  State<CriarEventoPage> createState() => _CriarEventoPageState();
}

class _CriarEventoPageState extends State<CriarEventoPage> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _localController = TextEditingController();
  DateTime _dataSelecionada = DateTime.now();
  TimeOfDay _horarioSelecionado = TimeOfDay.now();
  TipoEvento _tipoSelecionado = TipoEvento.PROVA_SIMULADA;
  String? _provaSelecionada;
  List<Prova> _provas = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.dataInicial != null) {
      _dataSelecionada = widget.dataInicial!;
    }
    _carregarProvas();
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _localController.dispose();
    super.dispose();
  }

  Future<void> _carregarProvas() async {
    setState(() => _isLoading = true);
    try {
      final provas = await ProvaService.listarProvas();
      setState(() {
        _provas = provas;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao carregar provas: $e')));
      }
    }
  }

  Future<void> _selecionarData() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      locale: const Locale('pt', 'BR'),
    );
    if (picked != null) {
      setState(() => _dataSelecionada = picked);
    }
  }

  Future<void> _selecionarHorario() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _horarioSelecionado,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _horarioSelecionado = picked);
    }
  }

  Future<void> _criarEvento() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isLoading = true);

    try {
      // Mostrar diálogo de loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => const AlertDialog(
              content: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 16),
                  Text('Criando evento...'),
                ],
              ),
            ),
      );

      final dataHorario = DateTime(
        _dataSelecionada.year,
        _dataSelecionada.month,
        _dataSelecionada.day,
        _horarioSelecionado.hour,
        _horarioSelecionado.minute,
      );

      final eventoData = <String, dynamic>{
        'titulo': _tituloController.text.trim(),
        'descricao':
            _descricaoController.text.trim().isEmpty
                ? null
                : _descricaoController.text.trim(),
        'tipo': _tipoSelecionado.name,
        'data': _dataSelecionada.toIso8601String(),
        'horario': dataHorario.toIso8601String(),
        'local': _localController.text.trim(),
        'provaId': _provaSelecionada,
      };

      // Validar dados antes de enviar
      if (_tituloController.text.trim().isEmpty) {
        throw Exception('Título é obrigatório');
      }
      if (_localController.text.trim().isEmpty) {
        throw Exception('Local é obrigatório');
      }

      await EventoService.criarEvento(eventoData);

      // Fechar diálogo de loading
      if (mounted && Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Evento criado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      // Fechar diálogo de loading se existir
      if (mounted && Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar evento: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Evento'),
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

                // Tipo e Local
                _buildTypeLocationCard(theme),
                const SizedBox(height: 16),

                // Data e Horário
                _buildDateTimeCard(theme),
                const SizedBox(height: 16),

                // Prova (se aplicável)
                if (_tipoSelecionado == TipoEvento.PROVA_SIMULADA)
                  _buildProvaCard(theme),
                if (_tipoSelecionado == TipoEvento.PROVA_SIMULADA)
                  const SizedBox(height: 16),

                const SizedBox(height: 16),

                // Botão de Criar
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
                Icons.event_rounded,
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
                    'Criar Evento',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Organize eventos importantes do seu cronograma de estudos',
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
                  'Informações do Evento',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            _buildInputField(
              label: 'Título do evento',
              controller: _tituloController,
              icon: Icons.title_rounded,
              hint: 'Ex: Prova de Matemática, Simulado ENEM...',
              isRequired: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Título é obrigatório';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            _buildInputField(
              label: 'Descrição (opcional)',
              controller: _descricaoController,
              icon: Icons.description_rounded,
              hint: 'Adicione detalhes sobre o evento...',
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeLocationCard(ThemeData theme) {
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
                  Icons.category_rounded,
                  color: theme.colorScheme.secondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Tipo e Local',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            _buildDropdownField<TipoEvento>(
              label: 'Tipo de Evento',
              icon: Icons.label_rounded,
              value: _tipoSelecionado,
              items: TipoEvento.values,
              itemBuilder: (tipo) => tipo.displayName,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _tipoSelecionado = value);
                }
              },
              isRequired: true,
            ),

            const SizedBox(height: 16),

            _buildInputField(
              label: 'Local',
              controller: _localController,
              icon: Icons.location_on_rounded,
              hint: 'Ex: Sala 101, Campus Central...',
              isRequired: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Local é obrigatório';
                }
                return null;
              },
            ),
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
                  Icons.access_time_rounded,
                  color: theme.colorScheme.tertiary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Data e Horário',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.tertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(child: _buildDateSelector(theme)),
                const SizedBox(width: 12),
                Expanded(child: _buildTimeSelector(theme)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProvaCard(ThemeData theme) {
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
                  Icons.quiz_rounded,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Prova Relacionada',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildDropdownField<String?>(
              label: 'Prova (opcional)',
              icon: Icons.assignment_rounded,
              value: _provaSelecionada,
              items: <String?>[null, ..._provas.map((p) => p.id)],
              itemBuilder:
                  (id) =>
                      id == null
                          ? 'Nenhuma prova'
                          : _provas.firstWhere((p) => p.id == id).titulo,
              onChanged: (value) {
                setState(() => _provaSelecionada = value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? hint,
    int maxLines = 1,
    bool isRequired = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required IconData icon,
    required T? value,
    required List<T> items,
    required String Function(T) itemBuilder,
    required void Function(T?) onChanged,
    bool isRequired = false,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
      ),
      items:
          items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(itemBuilder(item)),
            );
          }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildDateSelector(ThemeData theme) {
    return InkWell(
      onTap: _selecionarData,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(12),
          color: theme.colorScheme.surface,
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Data',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('dd/MM/yyyy').format(_dataSelecionada),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
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

  Widget _buildTimeSelector(ThemeData theme) {
    return InkWell(
      onTap: _selecionarHorario,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(12),
          color: theme.colorScheme.surface,
        ),
        child: Row(
          children: [
            Icon(
              Icons.access_time_rounded,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Horário',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _horarioSelecionado.format(context),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
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

  Widget _buildCreateButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _criarEvento,
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
            _isLoading
                ? SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: theme.colorScheme.onPrimary,
                  ),
                )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_rounded, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Criar Evento',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
