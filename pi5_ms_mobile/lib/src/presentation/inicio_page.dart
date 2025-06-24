// ignore: file_names
import 'package:flutter/material.dart';
import '../shared/services/gamificacao_backend_service.dart';
import '../shared/services/sessao_service.dart';
import '../shared/services/prova_service.dart';
import '../shared/services/evento_service.dart';
import '../shared/services/streak_service.dart';
import '../shared/models/prova_model.dart';
import '../shared/models/evento_model.dart';
import 'package:intl/intl.dart';

class InicioPage extends StatefulWidget {
  const InicioPage({super.key});

  @override
  State<InicioPage> createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  Map<String, dynamic> _estatisticasGamificacao = {};
  bool _carregandoGamificacao = true;

  Map<String, dynamic> _streakData = {};
  bool _carregandoStreak = true;

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
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _rotateAnimation = Tween<double>(
      begin: 0,
      end: 0.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    WidgetsBinding.instance.addObserver(this);
    _carregarTodosDados();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Recarregar dados quando o app volta ao foco
      _carregarTodosDados();
    }
  }

  Future<void> _carregarTodosDados() async {
    setState(() {
      _carregandoGamificacao = true;
      _carregandoDados = true;
      _carregandoStreak = true;
    });

    try {
      // Carregar dados em paralelo
      final results = await Future.wait([
        GamificacaoBackendService.obterEstatisticasCompletas(),
        SessaoService.listarSessoes(),
        ProvaService.listarProvas(),
        EventoService.listarEventos(),
        StreakService.obterStreak(),
      ]);
      if (mounted) {
        // Se não conseguir dados do backend, usar dados padrão
        final estatisticasBackend = results[0] as Map<String, dynamic>?;
        final estatisticasFinal =
            estatisticasBackend ?? {'xpTotal': 0, 'nivel': 1, 'pontosTotal': 0};

        print('📊 Estatísticas finais carregadas: $estatisticasFinal');
        setState(() {
          _estatisticasGamificacao = estatisticasFinal;
          _sessoes = results[1] as List<SessaoEstudo>;
          _provas = results[2] as List<Prova>;
          _eventos = results[3] as List<Evento>;
          _streakData = results[4] as Map<String, dynamic>;

          // Calcular provas realizadas baseado no status
          final provasRealizadas =
              _provas
                  .where((prova) => prova.status == StatusProva.CONCLUIDA)
                  .length;
          _estatisticasGamificacao['provasRealizadas'] = provasRealizadas;

          _ultimaSessao = _obterUltimaSessao();
          _proximoEvento = _obterProximoEvento();
          _carregandoGamificacao = false;
          _carregandoDados = false;
          _carregandoStreak = false;
        });
      }
    } catch (e) {
      print('Erro ao carregar dados: $e');
      if (mounted) {
        setState(() {
          _estatisticasGamificacao = {};
          _carregandoGamificacao = false;
          _carregandoDados = false;
          _carregandoStreak = false;
        });
      }
    }
  }

  void _mostrarDetalhesStreak() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 8,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.orange.shade50,
                    Colors.orange.shade100.withOpacity(0.3),
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header com ícone animado
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        color: Colors.orange.shade300,
                        width: 2,
                      ),
                    ),
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Icon(
                            Icons.local_fire_department,
                            color: Colors.orange.shade600,
                            size: 32,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Sequência de Estudos',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade700,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Cards de estatísticas
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.orange.shade200,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.shade100,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildStreakStatRow(
                          'Sequência Atual',
                          '${_streakData['currentStreak'] ?? 0} dias',
                          Icons.whatshot,
                          Colors.orange.shade600,
                        ),
                        const SizedBox(height: 12),
                        Divider(color: Colors.orange.shade100),
                        const SizedBox(height: 12),
                        _buildStreakStatRow(
                          'Maior Sequência',
                          '${_streakData['longestStreak'] ?? 0} dias',
                          Icons.emoji_events,
                          Colors.amber.shade600,
                        ),
                        const SizedBox(height: 12),
                        Divider(color: Colors.orange.shade100),
                        const SizedBox(height: 12),
                        _buildStreakStatusRow(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Dica motivacional
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200, width: 1),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: Colors.blue.shade600,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Estude pelo menos 10 segundos para manter sua sequência ativa!',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Botão de fechar estilizado
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Entendi!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildStreakStatRow(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildStreakStatusRow() {
    final isActivated = _streakData['isActivatedToday'] ?? false;
    final statusColor =
        isActivated ? Colors.green.shade600 : Colors.orange.shade600;
    final statusIcon = isActivated ? Icons.check_circle : Icons.pending;
    final statusText = isActivated ? 'Ativada hoje!' : 'Pendente';

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(statusIcon, color: statusColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Status Hoje',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
          ),
          child: Text(
            statusText,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
        ),
      ],
    );
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
    final proximosEventos =
        _eventos.where((e) => e.data.isAfter(agora)).toList();

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
            child: Icon(icon, color: color, size: 24),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
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
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 24), // Card principal com streak e nível
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
                      // Streak Section
                      Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _mostrarDetalhesStreak,
                            borderRadius: BorderRadius.circular(8),
                            splashColor: Colors.orange.withOpacity(0.1),
                            highlightColor: Colors.orange.withOpacity(0.05),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'Sequência',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: 'Roboto',
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.touch_app,
                                        size: 14,
                                        color: Colors.grey[500],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.outline,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      color:
                                          Theme.of(context).colorScheme.surface,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 16,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        _buildAnimatedIcon(
                                          Icons.local_fire_department,
                                          _streakData['isActivatedToday'] ??
                                                  false
                                              ? Colors.orange
                                              : Colors.grey,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _carregandoStreak
                                              ? '...'
                                              : '${_streakData['currentStreak'] ?? 0} dias',
                                          style: const TextStyle(
                                            fontFamily: 'Roboto',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _streakData['isActivatedToday'] ?? false
                                        ? 'Ativada hoje! 🔥'
                                        : 'Toque para detalhes',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color:
                                          _streakData['isActivatedToday'] ??
                                                  false
                                              ? Colors.green[600]
                                              : Colors.blue[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 100,
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                      // Nível Section
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
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                color: Theme.of(context).colorScheme.surface,
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
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
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Nível Atual',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
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
                                      _estatisticasGamificacao['tempoTotalFormatado'] ??
                                          '0min',
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
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
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
                                    color:
                                        Theme.of(context).colorScheme.primary,
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
                                  padding: const EdgeInsets.only(
                                    left: 28,
                                    top: 2,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
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
                              Icon(Icons.info_outline, color: Colors.grey[400]),
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
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
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
                                    _proximoEvento is Prova
                                        ? Icons.quiz
                                        : Icons.event,
                                    color:
                                        _proximoEvento is Prova
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
                                padding: const EdgeInsets.only(
                                  left: 28,
                                  top: 2,
                                ),
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
                                padding: const EdgeInsets.only(
                                  left: 28,
                                  top: 4,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        _proximoEvento is Prova
                                            ? Colors.blue[100]
                                            : Colors.orange[100],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    _proximoEvento is Prova
                                        ? 'Prova'
                                        : 'Evento',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color:
                                          _proximoEvento is Prova
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
