// ignore: file_names
import 'package:flutter/material.dart';
import '../shared/services/gamificacao_service.dart';
import '../shared/services/sessao_service.dart';
import '../shared/services/prova_service.dart';
import '../shared/services/evento_service.dart';
import '../shared/models/prova_model.dart';
import '../shared/models/evento_model.dart';
import 'package:intl/intl.dart';

class InicioPage extends StatefulWidget {
  const InicioPage({super.key});

  @override
  State<InicioPage> createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  Map<String, dynamic> _estatisticasGamificacao = {};
  bool _carregandoGamificacao = true;
  
  List<SessaoEstudo> _sessoes = [];
  List<Prova> _provas = [];
  List<Evento> _eventos = [];
  bool _carregandoDados = true;
  
  SessaoEstudo? _ultimaSessao;
  dynamic _proximoEvento; // Pode ser Prova ou Evento

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _rotateAnimation = Tween<double>(
      begin: 0,
      end: 0.05,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _carregarTodosDados();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _carregarTodosDados() async {
    setState(() {
      _carregandoGamificacao = true;
      _carregandoDados = true;
    });

    try {
      // Carregar dados em paralelo
      final results = await Future.wait([
        GamificacaoService.obterEstatisticasCompletas(),
        SessaoService.listarSessoes(),
        ProvaService.listarProvas(),
        EventoService.listarEventos(),
      ]);

      if (mounted) {
        setState(() {
          _estatisticasGamificacao = results[0] as Map<String, dynamic>;
          _sessoes = results[1] as List<SessaoEstudo>;
          _provas = results[2] as List<Prova>;
          _eventos = results[3] as List<Evento>;
          
          _ultimaSessao = _obterUltimaSessao();
          _proximoEvento = _obterProximoEvento();
          
          _carregandoGamificacao = false;
          _carregandoDados = false;
        });
      }
    } catch (e) {
      print('Erro ao carregar dados: $e');
      if (mounted) {
        setState(() {
          _estatisticasGamificacao = {};
          _carregandoGamificacao = false;
          _carregandoDados = false;
        });
      }
    }
  }

  Future<void> _carregarEstatisticasGamificacao() async {
    setState(() {
      _carregandoGamificacao = true;
    });

    try {
      final stats = await GamificacaoService.obterEstatisticasCompletas();
      if (mounted) {
        setState(() {
          _estatisticasGamificacao = stats;
          _carregandoGamificacao = false;
        });
      }
    } catch (e) {
      print('Erro ao carregar estatísticas de gamificação: $e');
      if (mounted) {
        setState(() {
          _estatisticasGamificacao = {};
          _carregandoGamificacao = false;
        });
      }
    }
  }

  SessaoEstudo? _obterUltimaSessao() {
    if (_sessoes.isEmpty) return null;
    
    // Ordenar por data de criação (mais recente primeiro)
    final sessoesOrdenadas = List<SessaoEstudo>.from(_sessoes);
    sessoesOrdenadas.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return sessoesOrdenadas.first;
  }

  dynamic _obterProximoEvento() {
    final agora = DateTime.now();
    final proximasProvas = _provas.where((p) => p.data.isAfter(agora)).toList();
    final proximosEventos = _eventos.where((e) => e.data.isAfter(agora)).toList();
    
    // Combinar provas e eventos e ordenar por data
    final todosFuturos = <dynamic>[];
    todosFuturos.addAll(proximasProvas);
    todosFuturos.addAll(proximosEventos);
    
    if (todosFuturos.isEmpty) return null;
    
    todosFuturos.sort((a, b) => a.data.compareTo(b.data));
    return todosFuturos.first;
  }

  Widget _buildAnimatedIcon(IconData icon, Color color) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotateAnimation.value,
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _carregarTodosDados,
        child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(
                'Bem-vindo de volta!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Continue sua jornada de estudos',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context).colorScheme.surface,
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          const Text(
                            'Mantenha o Ritmo',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                color: Theme.of(context).colorScheme.surface,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildAnimatedIcon(
                                    Icons.local_fire_department,
                                    Colors.orange,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _carregandoGamificacao 
                                        ? '...' 
                                        : '${_estatisticasGamificacao['sessoesFinalizadas'] ?? 0} sessões',
                                    style: const TextStyle(
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sessões Finalizadas',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 80,
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          const Text(
                            'Continue Evoluindo',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                color: Theme.of(context).colorScheme.surface,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildAnimatedIcon(
                                    Icons.flash_on,
                                    Colors.amber,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _carregandoGamificacao 
                                        ? '...' 
                                        : '${_estatisticasGamificacao['nivel'] ?? 1}',
                                    style: const TextStyle(
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Nível Atual',
                            style: TextStyle(fontSize: 10, fontFamily: 'Poppins'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Card de resumo estatísticas
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context).colorScheme.surface,
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Seu progresso',
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Divider(
                      color: Theme.of(context).colorScheme.outline,
                      thickness: 0.8,
                    ),
                    const SizedBox(height: 8),
                    _carregandoGamificacao
                        ? const Center(child: CircularProgressIndicator())
                        : Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildStatCard(
                                      'Tempo de Estudo',
                                      _estatisticasGamificacao['tempoTotalFormatado'] ?? '0min',
                                      Icons.timer,
                                      Colors.green[600]!,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildStatCard(
                                      'Provas Realizadas',
                                      '${_estatisticasGamificacao['provasRealizadas'] ?? 0}',
                                      Icons.quiz,
                                      Colors.blue[600]!,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildStatCard(
                                      'Desempenho Médio',
                                      '${(_estatisticasGamificacao['desempenhoMedio'] ?? 0.0).toStringAsFixed(0)}%',
                                      Icons.trending_up,
                                      Colors.purple[600]!,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildStatCard(
                                      'XP Total',
                                      '${_estatisticasGamificacao['xpTotal'] ?? 0}',
                                      Icons.star,
                                      Colors.orange[600]!,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context).colorScheme.surface,
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Continue de onde parou',
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Divider(
                      color: Theme.of(context).colorScheme.outline,
                      thickness: 0.8,
                    ),
                    const SizedBox(height: 8),
                    _carregandoDados 
                        ? const Row(
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              SizedBox(width: 12),
                              Text('Carregando...'),
                            ],
                          )
                        : _ultimaSessao != null
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.menu_book,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          _ultimaSessao!.conteudo,
                                          style: const TextStyle(
                                            fontFamily: 'Roboto',
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 28),
                                    child: Text(
                                      'Matéria ID: ${_ultimaSessao!.materiaId}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                        fontFamily: 'Roboto',
                                      ),
                                    ),
                                  ),
                                  if (_ultimaSessao!.tempoFim != null)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 28, top: 2),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.green[100],
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          'Finalizada',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.green[700],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              )
                            : Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Nenhuma sessão de estudo ainda',
                                    style: TextStyle(
                                      fontFamily: 'Roboto',
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context).colorScheme.surface,
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fique atento',
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Divider(
                      color: Theme.of(context).colorScheme.outline,
                      thickness: 0.8,
                    ),
                    Text(
                      'Próximo evento',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.outline,
                        fontSize: 12,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _carregandoDados 
                        ? const Row(
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              SizedBox(width: 12),
                              Text('Carregando...'),
                            ],
                          )
                        : _proximoEvento != null
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        _proximoEvento is Prova ? Icons.quiz : Icons.event,
                                        color: _proximoEvento is Prova 
                                            ? Colors.blue[600]
                                            : Colors.orange[600],
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          _proximoEvento.titulo,
                                          style: const TextStyle(
                                            fontFamily: 'Roboto',
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 28),
                                    child: Text(
                                      '${DateFormat('dd/MM/yyyy').format(_proximoEvento.data)} às ${DateFormat('HH:mm').format(_proximoEvento.horario)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                        fontFamily: 'Roboto',
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 28, top: 2),
                                    child: Text(
                                      'Local: ${_proximoEvento.local}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                        fontFamily: 'Roboto',
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 28, top: 4),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: _proximoEvento is Prova 
                                            ? Colors.blue[100]
                                            : Colors.orange[100],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        _proximoEvento is Prova ? 'Prova' : 'Evento',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: _proximoEvento is Prova 
                                              ? Colors.blue[700]
                                              : Colors.orange[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  Icon(
                                    Icons.check_circle_outline,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Nenhum evento próximo',
                                    style: TextStyle(
                                      fontFamily: 'Roboto',
                                      fontSize: 14,
                                      color: Colors.grey[600],
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
        ),
      ),
    );
  }
}
