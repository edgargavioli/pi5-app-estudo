import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pi5_ms_mobile/src/shared/services/gamificacao_backend_service.dart';
import 'package:pi5_ms_mobile/src/shared/services/sessao_service.dart';
import 'package:pi5_ms_mobile/src/shared/services/prova_service.dart';
import 'package:pi5_ms_mobile/src/shared/models/evento_model.dart';
import 'package:pi5_ms_mobile/src/shared/models/prova_model.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:math';

class WrappedPage extends StatefulWidget {
  const WrappedPage({super.key});

  @override
  State<WrappedPage> createState() => _WrappedPageState();
}

class _WrappedPageState extends State<WrappedPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  PageController _pageController = PageController();
  int _currentPage = 0;
  bool _carregando = true;
  bool _compartilhando = false;

  // Dados do wrapped
  Map<String, dynamic> _dadosWrapped = {};

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _carregarDadosWrapped();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _animationController.forward();
  }

  Future<void> _carregarDadosWrapped() async {
    try {
      // Carregar dados básicos
      final estatisticas =
          await GamificacaoBackendService.obterEstatisticasCompletas();
      final sessoes = await SessaoService.listarSessoes();
      final provas = await ProvaService.listarProvas();

      // Processar dados para o wrapped
      final dadosProcessados = _processarDadosWrapped(
        estatisticas,
        sessoes,
        provas,
      );
      if (mounted) {
        setState(() {
          _dadosWrapped = dadosProcessados;
          _carregando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _carregando = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao carregar dados: $e')));
      }
    }
  }

  Map<String, dynamic> _processarDadosWrapped(
    Map<String, dynamic>? estatisticas,
    List<SessaoEstudo> sessoes,
    List<Prova> provas,
  ) {
    final agora = DateTime.now();
    final inicioAno = DateTime(agora.year, 1, 1);

    // Filtrar sessões do ano
    final sessoesAno =
        sessoes
            .where(
              (s) =>
                  s.createdAt.isAfter(inicioAno) && s.createdAt.isBefore(agora),
            )
            .toList();

    // Sessões finalizadas
    final sessoesFinalizadas = sessoesAno.where((s) => s.finalizada).toList();

    // Calcular tempo total (em minutos)
    int tempoTotalMinutos = 0;
    for (final sessao in sessoesFinalizadas) {
      if (sessao.tempoInicio != null && sessao.tempoFim != null) {
        tempoTotalMinutos +=
            sessao.tempoFim!.difference(sessao.tempoInicio!).inMinutes;
      }
    }

    // Mês com mais sessões
    final sessoesPorMes = <int, int>{};
    for (final sessao in sessoesFinalizadas) {
      final mes = sessao.createdAt.month;
      sessoesPorMes[mes] = (sessoesPorMes[mes] ?? 0) + 1;
    }
    final mesComMaisSessoes =
        sessoesPorMes.isNotEmpty
            ? sessoesPorMes.entries
                .reduce((a, b) => a.value > b.value ? a : b)
                .key
            : 1;

    // Matéria mais estudada
    final sessoesPorMateria = <String, int>{};
    final temposPorMateria = <String, int>{};
    for (final sessao in sessoesFinalizadas) {
      sessoesPorMateria[sessao.materiaId] =
          (sessoesPorMateria[sessao.materiaId] ?? 0) + 1;
      if (sessao.tempoInicio != null && sessao.tempoFim != null) {
        final tempo =
            sessao.tempoFim!.difference(sessao.tempoInicio!).inMinutes;
        temposPorMateria[sessao.materiaId] =
            (temposPorMateria[sessao.materiaId] ?? 0) + tempo;
      }
    }

    String? materiaMaisEstudada;
    if (temposPorMateria.isNotEmpty) {
      materiaMaisEstudada =
          temposPorMateria.entries
              .reduce((a, b) => a.value > b.value ? a : b)
              .key;
    }

    // Sequência mais longa
    int sequenciaMaisLonga = 0;
    int sequenciaAtual = 0;
    DateTime? ultimaData;

    final datasEstudo =
        sessoesFinalizadas
            .map(
              (s) => DateTime(
                s.createdAt.year,
                s.createdAt.month,
                s.createdAt.day,
              ),
            )
            .toSet()
            .toList()
          ..sort();

    for (int i = 0; i < datasEstudo.length; i++) {
      if (ultimaData == null ||
          datasEstudo[i].difference(ultimaData).inDays == 1) {
        sequenciaAtual++;
        sequenciaMaisLonga = max(sequenciaMaisLonga, sequenciaAtual);
      } else if (datasEstudo[i].difference(ultimaData).inDays > 1) {
        sequenciaAtual = 1;
      }
      ultimaData = datasEstudo[i];
    }

    // Desempenho médio
    final sessoesComQuestoes =
        sessoesFinalizadas.where((s) => s.totalQuestoes > 0).toList();
    double desempenhoMedio = 0;
    if (sessoesComQuestoes.isNotEmpty) {
      final somaDesempenho = sessoesComQuestoes
          .map((s) => s.percentualAcerto)
          .reduce((a, b) => a + b);
      desempenhoMedio = somaDesempenho / sessoesComQuestoes.length;
    }

    return {
      'ano': agora.year,
      'totalSessoes': sessoesFinalizadas.length,
      'tempoTotalMinutos': tempoTotalMinutos,
      'tempoTotalFormatado': _formatarTempo(tempoTotalMinutos),
      'xpTotal': estatisticas?['xpTotal'] ?? 0,
      'nivel': estatisticas?['nivel'] ?? 1,
      'mesComMaisSessoes': mesComMaisSessoes,
      'mesComMaisSesoesNome': _nomeDoMes(mesComMaisSessoes),
      'materiaMaisEstudada': materiaMaisEstudada ?? 'Não identificada',
      'sequenciaMaisLonga': sequenciaMaisLonga,
      'desempenhoMedio': desempenhoMedio,
      'totalQuestoes': sessoesComQuestoes.fold<int>(
        0,
        (sum, s) => sum + s.totalQuestoes,
      ),
      'questoesAcertadas': sessoesComQuestoes.fold<int>(
        0,
        (sum, s) => sum + s.questoesAcertadas,
      ),
      'diasComEstudo': datasEstudo.length,
      'sessoesPorMes': sessoesPorMes,
    };
  }

  String _formatarTempo(int minutos) {
    if (minutos < 60) {
      return '${minutos}min';
    } else if (minutos < 1440) {
      // menos de 24h
      final horas = minutos ~/ 60;
      final mins = minutos % 60;
      return '${horas}h ${mins}min';
    } else {
      final dias = minutos ~/ 1440;
      final horas = (minutos % 1440) ~/ 60;
      return '${dias}d ${horas}h';
    }
  }

  String _nomeDoMes(int mes) {
    const meses = [
      '',
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];
    if (mes >= 1 && mes <= 12) {
      return meses[mes];
    }
    return 'Desconhecido';
  }

  /// Compartilhar o wrapped atual
  Future<void> _compartilharWrapped() async {
    if (_compartilhando) return;

    setState(() => _compartilhando = true);

    try {
      // Gerar um resumo textual do wrapped
      final textoWrapped = _gerarTextoWrapped();

      // Compartilhar usando o Share Plus
      await Share.share(
        textoWrapped,
        subject: 'Meu Wrapped ${DateTime.now().year} - App de Estudos',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao compartilhar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _compartilhando = false);
      }
    }
  }

  /// Gerar texto formatado do wrapped para compartilhamento
  String _gerarTextoWrapped() {
    final ano = DateTime.now().year;
    final tempoTotal = _formatarTempo(_dadosWrapped['tempoTotalMinutos'] ?? 0);
    final totalSessoes = _dadosWrapped['totalSessoes'] ?? 0;
    final nivel = _dadosWrapped['nivel'] ?? 1;
    final xpTotal = _dadosWrapped['xpTotal'] ?? 0;
    final desempenhoMedio = (_dadosWrapped['desempenhoMedio'] ?? 0.0)
        .toStringAsFixed(1);
    final sequenciaMaisLonga = _dadosWrapped['sequenciaMaisLonga'] ?? 0;
    final mesComMaisSessoes = _dadosWrapped['mesComMaisSessoes'] ?? 1;
    final nomeMes = _nomeDoMes(mesComMaisSessoes);

    return '''
🎉 MEU WRAPPED $ano - APP DE ESTUDOS 🎉

📚 ESTATÍSTICAS DO ANO:
• ⏱️ Tempo total estudado: $tempoTotal
• 📖 Sessões de estudo: $totalSessoes sessões
• 🎯 Desempenho médio: $desempenhoMedio%
• 🔥 Maior sequência: $sequenciaMaisLonga dias seguidos

🏆 CONQUISTAS:
• 🌟 Nível atual: $nivel
• ✨ XP total: $xpTotal pontos
• 📅 Mês mais produtivo: $nomeMes

Continue assim e alcance ainda mais em ${ano + 1}! 💪

#Estudos #Wrapped$ano #Dedicação #Crescimento
    '''.trim();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return Scaffold(
        backgroundColor: const Color(0xFF667eea),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 24),
              Text(
                'Preparando seu Wrapped ${DateTime.now().year}...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF667eea),
      body: SafeArea(
        child: Stack(
          children: [
            // Background decorativo
            _buildBackground(),

            // Conteúdo principal
            PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
                _animationController.reset();
                _animationController.forward();
              },
              children: [
                _buildPaginaIntro(),
                _buildPaginaEstatisticas(),
                _buildPaginaTempo(),
                _buildPaginaDesempenho(),
                _buildPaginaConquistas(),
                _buildPaginaFinal(),
              ],
            ),

            // Indicadores de página
            _buildPageIndicators(),

            // Botão de fechar
            _buildCloseButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF667eea),
            const Color(0xFF764ba2),
            const Color(0xFF8B5CF6),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Círculos decorativos
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginaIntro() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_awesome, size: 80, color: Colors.white),
                  const SizedBox(height: 32),
                  Text(
                    'Seu Wrapped',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  Text(
                    '${_dadosWrapped['ano']}',
                    style: TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Vamos relembrar sua jornada\nde estudos este ano!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withOpacity(0.9),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 48),
                  Text(
                    'Deslize para continuar →',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.7),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaginaEstatisticas() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Você foi incansável!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 48),

                  _buildStatCard(
                    '${_dadosWrapped['totalSessoes']}',
                    'Sessões de Estudo\nFinalizadas',
                    Icons.school,
                  ),
                  const SizedBox(height: 24),

                  _buildStatCard(
                    '${_dadosWrapped['diasComEstudo']}',
                    'Dias com\nEstudo',
                    Icons.calendar_today,
                  ),
                  const SizedBox(height: 24),

                  _buildStatCard(
                    'Nível ${_dadosWrapped['nivel']}',
                    '${_dadosWrapped['xpTotal']} XP Total',
                    Icons.star,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaginaTempo() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Tempo Investido',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 48),

                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.timer, size: 60, color: Colors.white),
                        const SizedBox(height: 16),
                        Text(
                          '${_dadosWrapped['tempoTotalFormatado']}',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        Text(
                          'de estudo dedicado',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  Text(
                    'Seu mês mais produtivo foi\n${_dadosWrapped['mesComMaisSesoesNome']}!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaginaDesempenho() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Sua Performance',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 48),

                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildPerformanceItem(
                              '${_dadosWrapped['totalQuestoes']}',
                              'Questões\nResolvidas',
                              Icons.quiz,
                            ),
                            _buildPerformanceItem(
                              '${_dadosWrapped['questoesAcertadas']}',
                              'Questões\nAcertadas',
                              Icons.check_circle,
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Text(
                          '${_dadosWrapped['desempenhoMedio'].toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Taxa de Acerto Média',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaginaConquistas() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Conquistas',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 48),

                  _buildConquistaCard(
                    Icons.local_fire_department,
                    'Sequência de ${_dadosWrapped['sequenciaMaisLonga']} dias',
                    'Maior sequência de estudo',
                  ),

                  const SizedBox(height: 24),

                  _buildConquistaCard(
                    Icons.favorite,
                    'Matéria Favorita',
                    _getNomeMateria(_dadosWrapped['materiaMaisEstudada']),
                  ),

                  const SizedBox(height: 24),

                  _buildConquistaCard(
                    Icons.trending_up,
                    'Em Crescimento',
                    'Evoluindo constantemente',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaginaFinal() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.emoji_events, size: 80, color: Colors.white),
                  const SizedBox(height: 32),
                  Text(
                    'Parabéns!',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Você teve um ano incrível\nde dedicação aos estudos!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 48),
                  Text(
                    'Continue assim em ${DateTime.now().year + 1}!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Botão de compartilhar
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: ElevatedButton.icon(
                      onPressed: _compartilhando ? null : _compartilharWrapped,
                      icon:
                          _compartilhando
                              ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: const Color(0xFF667eea),
                                ),
                              )
                              : Icon(
                                Icons.share,
                                color: const Color(0xFF667eea),
                              ),
                      label: Text(
                        _compartilhando
                            ? 'Compartilhando...'
                            : 'Compartilhar Wrapped',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF667eea),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF667eea),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 4,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Botão de fechar
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white, width: 2),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Text(
                        'Fechar',
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
      },
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 40, color: Colors.white),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.white),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.9)),
        ),
      ],
    );
  }

  Widget _buildConquistaCard(IconData icon, String title, String subtitle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 32, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicators() {
    return Positioned(
      bottom: 100,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(6, (index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: _currentPage == index ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color:
                  _currentPage == index
                      ? Colors.white
                      : Colors.white.withOpacity(0.4),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCloseButton() {
    return Positioned(
      top: 16,
      right: 16,
      child: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(Icons.close, color: Colors.white, size: 28),
        style: IconButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.2),
          padding: const EdgeInsets.all(8),
        ),
      ),
    );
  }

  String _getNomeMateria(String materiaId) {
    // Aqui você pode implementar um mapeamento de IDs para nomes
    // Por enquanto, retorna o ID formatado
    if (materiaId == 'Não identificada') return materiaId;
    return 'Matéria $materiaId';
  }
}
