import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../shared/models/evento_model.dart';
import '../../shared/models/prova_model.dart';
import '../../shared/services/evento_service.dart';
import '../../shared/services/materia_service.dart';
import '../../components/button_widget.dart';

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
  final _urlInscricaoController = TextEditingController();
  final _taxaInscricaoController = TextEditingController();

  DateTime _dataSelecionada = DateTime.now();
  TimeOfDay _horarioSelecionado = TimeOfDay.now();
  DateTime? _dataLimiteInscricao;
  TipoEvento _tipoSelecionado = TipoEvento.PROVA_SIMULADA;
  String? _materiaSelecionada;
  List<Materia> _materias = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.dataInicial != null) {
      _dataSelecionada = widget.dataInicial!;
    }
    _carregarMaterias();
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _localController.dispose();
    _urlInscricaoController.dispose();
    _taxaInscricaoController.dispose();
    super.dispose();
  }

  Future<void> _carregarMaterias() async {
    setState(() => _isLoading = true);
    try {
      final materias = await MateriaService.listarMaterias();
      setState(() {
        _materias = materias;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar matérias: $e')),
        );
      }
    }
  }

  Future<void> _selecionarData() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada,
      firstDate: DateTime.now(),
      lastDate: DateTime(2025),
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

  Future<void> _selecionarDataLimite() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _dataLimiteInscricao ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: _dataSelecionada,
    );

    if (data != null) {
      setState(() {
        _dataLimiteInscricao = data;
      });
    }
  }

  Future<void> _criarEvento() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final dataHorario = DateTime(
        _dataSelecionada.year,
        _dataSelecionada.month,
        _dataSelecionada.day,
        _horarioSelecionado.hour,
        _horarioSelecionado.minute,
      );

      final eventoData = {
        'titulo': _tituloController.text.trim(),
        'descricao': _descricaoController.text.trim().isEmpty 
            ? null 
            : _descricaoController.text.trim(),
        'tipo': _tipoSelecionado.name,
        'data': _dataSelecionada.toIso8601String(),
        'horario': dataHorario.toIso8601String(),
        'local': _localController.text.trim(),
        'materiaId': _materiaSelecionada,
        'urlInscricao': _urlInscricaoController.text.trim().isEmpty 
            ? null 
            : _urlInscricaoController.text.trim(),
        'taxaInscricao': _taxaInscricaoController.text.trim().isEmpty 
            ? null 
            : double.tryParse(_taxaInscricaoController.text.trim()),
        'dataLimiteInscricao': _dataLimiteInscricao?.toIso8601String(),
      };

      await EventoService.criarEvento(eventoData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Evento criado com sucesso!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao criar evento: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
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
        title: const Text('Criar Evento'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Título
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título *',
                  hintText: 'Ex: ENEM 2025',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Título é obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Descrição
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  hintText: 'Descrição do evento',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Tipo
              DropdownButtonFormField<TipoEvento>(
                value: _tipoSelecionado,
                decoration: const InputDecoration(
                  labelText: 'Tipo *',
                  border: OutlineInputBorder(),
                ),
                items: TipoEvento.values.map((tipo) {
                  return DropdownMenuItem(
                    value: tipo,
                    child: Text(tipo.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _tipoSelecionado = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Data
              InkWell(
                onTap: _selecionarData,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Data *',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(DateFormat('dd/MM/yyyy').format(_dataSelecionada)),
                ),
              ),
              const SizedBox(height: 16),

              // Horário
              InkWell(
                onTap: _selecionarHorario,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Horário *',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.access_time),
                  ),
                  child: Text(_horarioSelecionado.format(context)),
                ),
              ),
              const SizedBox(height: 16),

              // Local
              TextFormField(
                controller: _localController,
                decoration: const InputDecoration(
                  labelText: 'Local *',
                  hintText: 'Ex: Campus Universitário',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Local é obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Matéria
              DropdownButtonFormField<String>(
                value: _materiaSelecionada,
                decoration: const InputDecoration(
                  labelText: 'Matéria (opcional)',
                  border: OutlineInputBorder(),
                ),
                items: _materias.map((materia) {
                  return DropdownMenuItem<String>(
                    value: materia.id,
                    child: Text(materia.nome),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _materiaSelecionada = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // URL de Inscrição
              TextFormField(
                controller: _urlInscricaoController,
                decoration: const InputDecoration(
                  labelText: 'URL de Inscrição',
                  hintText: 'https://exemplo.com/inscricao',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),

              // Taxa de Inscrição
              TextFormField(
                controller: _taxaInscricaoController,
                decoration: const InputDecoration(
                  labelText: 'Taxa de Inscrição (R\$)',
                  hintText: '0.00',
                  border: OutlineInputBorder(),
                  prefixText: 'R\$ ',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),

              // Data Limite de Inscrição
              InkWell(
                onTap: _selecionarDataLimite,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Data Limite de Inscrição',
                    border: const OutlineInputBorder(),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_dataLimiteInscricao != null)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _dataLimiteInscricao = null;
                              });
                            },
                          ),
                        const Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                  child: Text(
                    _dataLimiteInscricao != null
                        ? DateFormat('dd/MM/yyyy').format(_dataLimiteInscricao!)
                        : 'Selecionar data limite',
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Botão Criar
              SizedBox(
                height: 48,
                child: ButtonWidget(
                  text: _isLoading ? 'Criando...' : 'Criar Evento',
                  onPressed: _isLoading ? null : _criarEvento,
                  color: colorScheme.primary,
                  textStyle: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 