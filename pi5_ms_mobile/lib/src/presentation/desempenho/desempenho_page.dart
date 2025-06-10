// ignore: file_names
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pi5_ms_mobile/src/components/button_widget.dart';
import 'package:pi5_ms_mobile/src/shared/services/auth_service.dart';
import 'package:pi5_ms_mobile/src/shared/services/gamificacao_service.dart';
import 'package:pi5_ms_mobile/src/shared/services/sessao_service.dart';
import 'package:url_launcher/url_launcher.dart';

class DesempenhoPage extends StatefulWidget {
  const DesempenhoPage({super.key});

  @override
  State<DesempenhoPage> createState() => _DesempenhoPageState();
}

class _DesempenhoPageState extends State<DesempenhoPage> {
  Map<String, dynamic> _estatisticas = {};
  bool _carregando = true;
  DateTimeRange? _rangeDia;
  DateTimeRange? _rangeMateria;
  String? _selectedExam;
  List<BarChartGroupData> _weeklyData = [];
  final List<BarChartGroupData> _monthlyData = [];

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() => _carregando = true);
    try {
      // Carregar estatísticas
      final stats = await GamificacaoService.obterEstatisticasCompletas();

      // Carregar sessões para gráficos
      final sessoes = await SessaoService.listarSessoes();

      // Processar dados para gráficos semanais
      final Map<int, double> horasPorDia = {};
      final agora = DateTime.now();

      for (var sessao in sessoes) {
        if (sessao.tempoInicio != null && sessao.tempoFim != null) {
          final dia = sessao.tempoInicio!.weekday;
          final horas =
              sessao.tempoFim!
                  .difference(sessao.tempoInicio!)
                  .inHours
                  .toDouble();
          horasPorDia[dia] = (horasPorDia[dia] ?? 0) + horas;
        }
      }

      // Criar dados do gráfico semanal
      _weeklyData = List.generate(7, (i) {
        return BarChartGroupData(
          x: i + 1,
          barRods: [
            BarChartRodData(
              toY: horasPorDia[i + 1] ?? 0,
              color: Theme.of(context).colorScheme.primary,
              width: 12,
            ),
          ],
        );
      });

      if (mounted) {
        setState(() {
          _estatisticas = stats;
          _carregando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _carregando = false;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Erro ao carregar dados: $e')));
        });
      }
    }
  }

  Widget _buildBarChart(List<BarChartGroupData> data, {bool isWeekly = true}) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY:
            data.fold(
              0.0,
              (max, group) =>
                  group.barRods.first.toY > max ? group.barRods.first.toY : max,
            ) +
            1,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final labels =
                    isWeekly
                        ? ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom']
                        : List.generate(30, (i) => (i + 1).toString());
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    labels[value.toInt() - 1],
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: false),
        barGroups: data,
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
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

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Desempenho',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Divider(
                thickness: 1,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              const SizedBox(height: 4),
              if (_carregando)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _carregarDados,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Horas por Dia',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () async {
                                  final picked = await showDateRangePicker(
                                    context: context,
                                    locale: const Locale('pt', 'BR'),
                                    helpText: 'Selecione o período',
                                    cancelText: 'Cancelar',
                                    confirmText: 'Confirmar',
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime.now(),
                                  );
                                  if (picked != null) {
                                    setState(() => _rangeDia = picked);
                                    _carregarDados();
                                  }
                                },
                                icon: const Icon(
                                  Icons.calendar_today,
                                  size: 18,
                                ),
                                label: Text(
                                  _rangeDia == null
                                      ? 'Selecionar período'
                                      : '${_rangeDia!.start.day}/${_rangeDia!.start.month} - ${_rangeDia!.end.day}/${_rangeDia!.end.month}',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 200,
                            child: _buildBarChart(_weeklyData),
                          ),
                          const SizedBox(height: 24),
                          _buildStatCard(
                            'Total de Sessões',
                            '${_estatisticas['totalSessoes'] ?? 0}',
                            Icons.school,
                          ),
                          _buildStatCard(
                            'Sessões Finalizadas',
                            '${_estatisticas['sessoesFinalizadas'] ?? 0}',
                            Icons.check_circle,
                          ),
                          _buildStatCard(
                            'Tempo Total de Estudo',
                            _estatisticas['tempoTotalFormatado'] ?? '0min',
                            Icons.timer,
                          ),
                          _buildStatCard(
                            'Provas Realizadas',
                            '${_estatisticas['provasRealizadas'] ?? 0}',
                            Icons.quiz,
                          ),
                          _buildStatCard(
                            'Desempenho Médio',
                            '${(_estatisticas['desempenhoMedio'] ?? 0.0).toStringAsFixed(1)}%',
                            Icons.trending_up,
                          ),
                          _buildStatCard(
                            'XP Total',
                            '${_estatisticas['xpTotal'] ?? 0}',
                            Icons.star,
                          ),
                          _buildStatCard(
                            'Nível Atual',
                            '${_estatisticas['nivel'] ?? 1}',
                            Icons.flash_on,
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ButtonWidget(
                              text: 'Exportar PDF',
                              onPressed: () {
                                // TODO: implementar exportação PDF
                              },
                              color: Theme.of(context).colorScheme.primary,
                              textStyle: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(color: Colors.white),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ButtonWidget(
                              text: '🎉 Gerar Wrapped ${DateTime.now().year}',
                              onPressed: () async {
                                try {
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder:
                                        (context) => const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                  );

                                  final authService = AuthService();
                                  final currentUser = authService.currentUser;

                                  if (currentUser == null) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Erro: Usuário não autenticado',
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  final wrappedUrl =
                                      'http://10.0.2.2:3000/api/wrapped/${currentUser.id}/html';

                                  Navigator.pop(context);

                                  final uri = Uri.parse(wrappedUrl);
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(
                                      uri,
                                      mode: LaunchMode.externalApplication,
                                    );
                                  } else {
                                    throw 'Não foi possível abrir o wrapped';
                                  }
                                } catch (e) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Erro ao gerar wrapped: $e',
                                      ),
                                    ),
                                  );
                                }
                              },
                              color: const Color(0xFF667eea),
                              textStyle: Theme.of(
                                context,
                              ).textTheme.labelLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
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
}
