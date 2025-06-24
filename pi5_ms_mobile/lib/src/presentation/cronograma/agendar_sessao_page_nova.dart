import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../shared/models/evento_model.dart';
import '../../shared/models/prova_model.dart';
import '../../shared/models/materia_model.dart';
import '../../shared/services/sessao_service.dart';
import '../../shared/services/prova_service.dart';
import '../../shared/services/materia_service.dart';
import '../../shared/widgets/custom_snackbar.dart';
import '../../components/button_widget.dart';

class AgendarSessaoPage extends StatefulWidget {
  final DateTime? dataInicial;

  const AgendarSessaoPage({super.key, this.dataInicial});

  @override
  State<AgendarSessaoPage> createState() => _AgendarSessaoPageState();
}

class _AgendarSessaoPageState extends State<AgendarSessaoPage> {
  final _formKey = GlobalKey<FormState>();
  final _conteudoController = TextEditingController();
  final _topicosController = TextEditingController();

  List<Prova> _provas = [];
  List<Materia> _materias = [];

  Prova? _provaSelecionada;
  Materia? _materiaSelecionada;
  DateTime? _dataSelecionada;
  TimeOfDay? _horarioInicio;
  int _metaTempoMinutos = 60;

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _dataSelecionada = widget.dataInicial ?? DateTime.now();
    _carregarDados();
  }

  @override
  void dispose() {
    _conteudoController.dispose();
    _topicosController.dispose();
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

  Future<void> _agendarSessao() async {
    if (!_formKey.currentState!.validate()) return;
    if (_materiaSelecionada == null) {
      CustomSnackBar.showError(context, 'Selecione uma matéria');
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

    setState(() => _isSaving = true);

    try {
      final horarioAgendado = DateTime(
        _dataSelecionada!.year,
        _dataSelecionada!.month,
        _dataSelecionada!.day,
        _horarioInicio!.hour,
        _horarioInicio!.minute,
      );

      final topicos =
          _topicosController.text
              .split(',')
              .map((t) => t.trim())
              .where((t) => t.isNotEmpty)
              .toList();

      if (topicos.isEmpty) {
        CustomSnackBar.showError(context, 'Adicione pelo menos um tópico');
        setState(() => _isSaving = false);
        return;
      }

      final sessao = SessaoEstudo(
        id: '',
        materiaId: _materiaSelecionada!.id,
        provaId: _provaSelecionada?.id,
        eventoId: null,
        conteudo: _conteudoController.text,
        topicos: topicos,
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
    return Scaffold(
      appBar: AppBar(title: const Text('Agendar Sessão de Estudo')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Campo de conteúdo
                      TextFormField(
                        controller: _conteudoController,
                        decoration: const InputDecoration(
                          labelText: 'Conteúdo da sessão',
                          border: OutlineInputBorder(),
                        ),
                        validator:
                            (value) =>
                                value?.isEmpty == true
                                    ? 'Informe o conteúdo'
                                    : null,
                      ),
                      const SizedBox(height: 16),

                      // Dropdown de matérias
                      DropdownButtonFormField<Materia>(
                        value: _materiaSelecionada,
                        decoration: const InputDecoration(
                          labelText: 'Matéria',
                          border: OutlineInputBorder(),
                        ),
                        items:
                            _materias.map((materia) {
                              return DropdownMenuItem(
                                value: materia,
                                child: Text(materia.nome),
                              );
                            }).toList(),
                        onChanged: (materia) {
                          setState(() => _materiaSelecionada = materia);
                        },
                        validator:
                            (value) =>
                                value == null ? 'Selecione uma matéria' : null,
                      ),
                      const SizedBox(height: 16),

                      // Dropdown de provas (opcional)
                      DropdownButtonFormField<Prova>(
                        value: _provaSelecionada,
                        decoration: const InputDecoration(
                          labelText: 'Prova (opcional)',
                          border: OutlineInputBorder(),
                        ),
                        items:
                            _provas.map((prova) {
                              return DropdownMenuItem(
                                value: prova,
                                child: Text(prova.titulo),
                              );
                            }).toList(),
                        onChanged: (prova) {
                          setState(() => _provaSelecionada = prova);
                        },
                      ),
                      const SizedBox(height: 16),

                      // Campo de tópicos
                      TextFormField(
                        controller: _topicosController,
                        decoration: const InputDecoration(
                          labelText: 'Tópicos (separados por vírgula)',
                          hintText: 'Ex: Função, Derivadas, Integrais',
                          border: OutlineInputBorder(),
                        ),
                        validator:
                            (value) =>
                                value?.isEmpty == true
                                    ? 'Informe pelo menos um tópico'
                                    : null,
                      ),
                      const SizedBox(height: 16),

                      // Seleção de data
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.calendar_today),
                          title: Text(
                            _dataSelecionada != null
                                ? DateFormat(
                                  'dd/MM/yyyy',
                                ).format(_dataSelecionada!)
                                : 'Selecionar data',
                          ),
                          onTap: _selecionarData,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Seleção de horário
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.access_time),
                          title: Text(
                            _horarioInicio != null
                                ? _horarioInicio!.format(context)
                                : 'Selecionar horário',
                          ),
                          onTap: _selecionarHorario,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Meta de tempo
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Meta de tempo'),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.timer),
                                  Expanded(
                                    child: Slider(
                                      value: _metaTempoMinutos.toDouble(),
                                      min: 15,
                                      max: 240,
                                      divisions: 15,
                                      label: '${_metaTempoMinutos}min',
                                      onChanged: (value) {
                                        setState(
                                          () =>
                                              _metaTempoMinutos = value.round(),
                                        );
                                      },
                                    ),
                                  ),
                                  Text('${_metaTempoMinutos}min'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Botão agendar
                      ButtonWidget(
                        text: 'Agendar Sessão',
                        onPressed: _isSaving ? null : _agendarSessao,
                        isLoading: _isSaving,
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
