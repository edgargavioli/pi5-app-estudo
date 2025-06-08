import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../shared/models/evento_model.dart';
import '../../shared/models/prova_model.dart';
import '../../shared/services/sessao_service.dart';
import '../../shared/services/prova_service.dart';
import '../../shared/services/materia_service.dart';
import '../../shared/services/estatisticas_service.dart';

class CriarSessaoPage extends StatefulWidget {
  final SessaoEstudo? sessao; // Para edição
  final DateTime? dataInicial; // Para pré-selecionar data
  final String? materiaId; // Para pré-selecionar matéria
  final String? provaId; // Para pré-selecionar prova

  const CriarSessaoPage({
    super.key,
    this.sessao,
    this.dataInicial,
    this.materiaId,
    this.provaId,
  });

  @override
  State<CriarSessaoPage> createState() => _CriarSessaoPageState();
}

class _CriarSessaoPageState extends State<CriarSessaoPage> {
  final _formKey = GlobalKey<FormState>();
  final _conteudoController = TextEditingController();
  final _topicosController = TextEditingController();
  
  List<Materia> _materias = [];
  List<Prova> _provas = [];
  
  String? _materiaSelecionada;
  String? _provaSelecionada;
  DateTime? _dataInicio;
  TimeOfDay? _horarioInicio;
  DateTime? _dataFim;
  TimeOfDay? _horarioFim;
  
  bool _isLoading = false;
  bool _isLoadingData = true;
  bool _sessaoFinalizada = false;

  @override
  void initState() {
    super.initState();
    _carregarDados();
    _preencherFormulario();
  }

  Future<void> _carregarDados() async {
    try {
      final resultados = await Future.wait([
        MateriaService.listarMaterias(),
        ProvaService.listarProvas(),
      ]);
      
      if (mounted) {
        setState(() {
          _materias = resultados[0] as List<Materia>;
          _provas = resultados[1] as List<Prova>;
          _isLoadingData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingData = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar dados: $e')),
        );
      }
    }
  }

  void _preencherFormulario() {
    if (widget.sessao != null) {
      // Modo edição
      final sessao = widget.sessao!;
      _conteudoController.text = sessao.conteudo;
      _topicosController.text = sessao.topicos.join(', ');
      _materiaSelecionada = sessao.materiaId;
      _provaSelecionada = sessao.provaId;
      _dataInicio = sessao.tempoInicio;
      if (sessao.tempoInicio != null) {
        _horarioInicio = TimeOfDay.fromDateTime(sessao.tempoInicio!);
      }
      
      if (sessao.tempoFim != null) {
        _dataFim = sessao.tempoFim;
        _horarioFim = TimeOfDay.fromDateTime(sessao.tempoFim!);
        _sessaoFinalizada = true;
      }
    } else {
      // Modo criação
      print('=== INICIALIZANDO NOVA SESSÃO ===');
      print('widget.provaId: ${widget.provaId}');
      print('widget.materiaId: ${widget.materiaId}');
      print('================================');
      
      _materiaSelecionada = widget.materiaId;
      _provaSelecionada = widget.provaId;
      _dataInicio = widget.dataInicial ?? DateTime.now();
      _horarioInicio = TimeOfDay.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: BackButton(color: colorScheme.onSurface),
        title: Text(
          widget.sessao == null ? 'Nova Sessão de Estudo' : 'Editar Sessão',
          style: TextStyle(color: colorScheme.onSurface),
        ),
        centerTitle: true,
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Card de informações básicas
                    _buildCardInformacoes(),
                    const SizedBox(height: 16),
                    
                    // Card de conteúdo
                    _buildCardConteudo(),
                    const SizedBox(height: 16),
                    
                    // Card de horários
                    _buildCardHorarios(),
                    const SizedBox(height: 24),
                    
                    // Botões de ação
                    _buildBotoesAcao(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCardInformacoes() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Informações Básicas',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Matéria
            DropdownButtonFormField<String>(
              value: _materiaSelecionada,
              decoration: const InputDecoration(
                labelText: 'Matéria *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.book),
              ),
              items: _materias.map((materia) {
                return DropdownMenuItem(
                  value: materia.id,
                  child: Text('${materia.nome} (${materia.categoria})'),
                );
              }).toList(),
              onChanged: (value) => setState(() => _materiaSelecionada = value),
              validator: (value) => value == null ? 'Selecione uma matéria' : null,
            ),
            
            const SizedBox(height: 16),
            
            // Prova (opcional)
            DropdownButtonFormField<String>(
              value: _provaSelecionada,
              decoration: const InputDecoration(
                labelText: 'Prova (opcional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.assignment),
                hintText: 'Selecione uma prova',
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('Nenhuma prova específica'),
                ),
                ..._provas.map((prova) {
                  return DropdownMenuItem(
                    value: prova.id,
                    child: Text(
                      prova.titulo,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }),
              ],
              onChanged: (value) => setState(() => _provaSelecionada = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardConteudo() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.edit_note, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Conteúdo da Sessão',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Conteúdo
            TextFormField(
              controller: _conteudoController,
              decoration: const InputDecoration(
                labelText: 'Descrição do conteúdo estudado *',
                border: OutlineInputBorder(),
                hintText: 'Ex: Derivadas e suas aplicações práticas',
              ),
              maxLines: 3,
              validator: (value) => value?.isEmpty == true ? 'Descreva o conteúdo estudado' : null,
            ),
            
            const SizedBox(height: 16),
            
            // Tópicos
            TextFormField(
              controller: _topicosController,
              decoration: const InputDecoration(
                labelText: 'Tópicos estudados (separados por vírgula) *',
                border: OutlineInputBorder(),
                hintText: 'Ex: Derivadas, Regra da cadeia, Aplicações',
              ),
              validator: (value) => value?.isEmpty == true ? 'Informe pelo menos um tópico' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardHorarios() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.schedule, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Horários',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Data e horário de início
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Data de início *',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    controller: TextEditingController(
                      text: _dataInicio != null 
                          ? DateFormat('dd/MM/yyyy').format(_dataInicio!)
                          : '',
                    ),
                    onTap: _selecionarDataInicio,
                    validator: (value) => _dataInicio == null ? 'Selecione a data' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Horário início *',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.access_time),
                    ),
                    controller: TextEditingController(
                      text: _horarioInicio?.format(context) ?? '',
                    ),
                    onTap: _selecionarHorarioInicio,
                    validator: (value) => _horarioInicio == null ? 'Selecione o horário' : null,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Checkbox para sessão finalizada
            CheckboxListTile(
              title: const Text('Sessão já finalizada'),
              subtitle: const Text('Marque se a sessão já foi concluída'),
              value: _sessaoFinalizada,
              onChanged: (value) {
                setState(() {
                  _sessaoFinalizada = value ?? false;
                  if (!_sessaoFinalizada) {
                    _dataFim = null;
                    _horarioFim = null;
                  }
                });
              },
            ),
            
            // Data e horário de fim (se finalizada)
            if (_sessaoFinalizada) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Data de fim',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      controller: TextEditingController(
                        text: _dataFim != null 
                            ? DateFormat('dd/MM/yyyy').format(_dataFim!)
                            : '',
                      ),
                      onTap: _selecionarDataFim,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Horário fim',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.access_time),
                      ),
                      controller: TextEditingController(
                        text: _horarioFim?.format(context) ?? '',
                      ),
                      onTap: _selecionarHorarioFim,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBotoesAcao() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _salvarSessao,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
            child: _isLoading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(widget.sessao == null ? 'Criar Sessão' : 'Salvar Alterações'),
          ),
        ),
      ],
    );
  }

  Future<void> _selecionarDataInicio() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _dataInicio ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (data != null) {
      setState(() => _dataInicio = data);
    }
  }

  Future<void> _selecionarHorarioInicio() async {
    final horario = await showTimePicker(
      context: context,
      initialTime: _horarioInicio ?? TimeOfDay.now(),
    );
    if (horario != null) {
      setState(() => _horarioInicio = horario);
    }
  }

  Future<void> _selecionarDataFim() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _dataFim ?? _dataInicio ?? DateTime.now(),
      firstDate: _dataInicio ?? DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (data != null) {
      setState(() => _dataFim = data);
    }
  }

  Future<void> _selecionarHorarioFim() async {
    final horario = await showTimePicker(
      context: context,
      initialTime: _horarioFim ?? TimeOfDay.now(),
    );
    if (horario != null) {
      setState(() => _horarioFim = horario);
    }
  }

  Future<void> _salvarSessao() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Para sessões não finalizadas, usar null como tempo de início
      // O tempo só será definido quando o cronômetro for iniciado
      DateTime? inicioDateTime;
      if (_sessaoFinalizada) {
        inicioDateTime = DateTime.utc(
          _dataInicio!.year,
          _dataInicio!.month,
          _dataInicio!.day,
          _horarioInicio!.hour,
          _horarioInicio!.minute,
        );
      }

      // Combinar data e horário de fim (se informados)
      DateTime? fimDateTime;
      if (_sessaoFinalizada && _dataFim != null && _horarioFim != null) {
        fimDateTime = DateTime.utc(
          _dataFim!.year,
          _dataFim!.month,
          _dataFim!.day,
          _horarioFim!.hour,
          _horarioFim!.minute,
        );
      }

      // Processar tópicos
      final topicos = _topicosController.text
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      // Determinar o provaId correto
      String? provaIdFinal;
      if (widget.provaId != null) {
        // Se foi passado um provaId específico (vindo da página de detalhes), usar ele
        provaIdFinal = widget.provaId;
      } else if (_provaSelecionada != null && _provaSelecionada!.isNotEmpty) {
        // Senão, usar o selecionado no dropdown
        provaIdFinal = _provaSelecionada;
      }
      
      // Debug
      print('=== SALVANDO SESSÃO ===');
      print('Widget.provaId: ${widget.provaId}');
      print('_provaSelecionada: $_provaSelecionada');
      print('provaIdFinal: $provaIdFinal');
      print('_materiaSelecionada: $_materiaSelecionada');
      print('=======================');

      final sessao = SessaoEstudo(
        id: widget.sessao?.id ?? '',
        materiaId: _materiaSelecionada!,
        provaId: provaIdFinal,
        conteudo: _conteudoController.text,
        topicos: topicos,
        tempoInicio: inicioDateTime,
        tempoFim: fimDateTime,
        createdAt: widget.sessao?.createdAt ?? DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
      );

      if (widget.sessao == null) {
        await SessaoService.criarSessao(sessao);
        
        // Atualizar estatísticas se a sessão foi finalizada
        if (_sessaoFinalizada && fimDateTime != null && inicioDateTime != null) {
          final duracao = fimDateTime.difference(inicioDateTime);
          await EstatisticasService.atualizarEstatisticas(duracao);
        }
      } else {
        await SessaoService.atualizarSessao(widget.sessao!.id, sessao);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.sessao == null 
                  ? 'Sessão criada com sucesso!'
                  : 'Sessão atualizada com sucesso!',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar sessão: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _conteudoController.dispose();
    _topicosController.dispose();
    super.dispose();
  }
} 