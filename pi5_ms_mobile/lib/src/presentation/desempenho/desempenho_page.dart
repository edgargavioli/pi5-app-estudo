import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pi5_ms_mobile/src/components/button_widget.dart';
import 'package:pi5_ms_mobile/src/shared/services/gamificacao_backend_service.dart';
import 'package:pi5_ms_mobile/src/shared/services/sessao_service.dart';
import 'package:pi5_ms_mobile/src/shared/services/prova_service.dart';
import 'package:pi5_ms_mobile/src/shared/models/prova_model.dart';
import 'package:pi5_ms_mobile/src/presentation/wrapped/wrapped_page.dart';
import 'dart:math';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class DesempenhoPage extends StatefulWidget {
  const DesempenhoPage({super.key});

  @override
  State<DesempenhoPage> createState() => _DesempenhoPageState();
}

class _DesempenhoPageState extends State<DesempenhoPage>
    with WidgetsBindingObserver {
  Map<String, dynamic> _estatisticas = {};
  Map<String, dynamic> _progressao = {};
  bool _carregando = true;
  // Dados para o gráfico de provas
  List<Prova> _provas = [];
  Prova? _provaSelecionada;
  List<BarChartGroupData> _provaData = [];
  bool _carregandoGraficoProvas = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _carregarDados();
    _carregarProvas();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Recarregar dados quando o app volta ao foco
      _carregarDados();
      _carregarProvas();
    }
  }

  /// Calcular XP necessário para o próximo nível (baseado na lógica do backend)
  int _calcularXPParaProximoLevel(int nivelAtual) {
    if (nivelAtual >= 100) return 0;

    const baseXP = 100;
    const multiplier = 1.5;
    return (baseXP * pow(multiplier, nivelAtual)).floor();
  }

  /// Calcular XP atual no nível (quanto XP já foi ganho no nível atual)
  int _calcularXPAtualNoNivel(int pontosTotal, int nivelAtual) {
    if (pontosTotal <= 0 || nivelAtual <= 1) return pontosTotal;

    // Calcular quanto XP foi gasto para chegar ao nível atual
    int xpGasto = 0;
    const baseXP = 100;
    const multiplier = 1.5;

    for (int i = 1; i < nivelAtual; i++) {
      xpGasto += (baseXP * pow(multiplier, i - 1)).floor();
    }

    return pontosTotal - xpGasto;
  }

  /// Carregar lista de provas disponíveis
  Future<void> _carregarProvas() async {
    try {
      final provas = await ProvaService.listarProvas();
      if (mounted) {
        setState(() {
          _provas = provas;
        });
        // Recarregar estatísticas após carregar provas para atualizar contador de provas realizadas
        _carregarDados();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao carregar provas: $e')));
      }
    }
  }

  /// Carregar dados do gráfico de barras para a prova selecionada
  Future<void> _carregarDadosGraficoProvas() async {
    if (_provaSelecionada == null) return;

    setState(() => _carregandoGraficoProvas = true);

    try {
      // Buscar sessões da prova selecionada
      final sessoes = await SessaoService.listarSessoesPorProva(
        _provaSelecionada!.id,
      );

      // Filtrar apenas sessões finalizadas com questões
      final sessoesFinalizadas =
          sessoes
              .where((sessao) => sessao.totalQuestoes > 0 && sessao.finalizada)
              .toList();

      // Criar dados do gráfico: cada barra representa uma sessão
      final barData = <BarChartGroupData>[];

      for (int i = 0; i < sessoesFinalizadas.length; i++) {
        final sessao = sessoesFinalizadas[i];
        barData.add(
          BarChartGroupData(
            x: i, // Índice da sessão (eixo X)
            barRods: [
              BarChartRodData(
                toY: sessao.percentualAcerto, // Taxa de acerto (eixo Y)
                color: _getCorPorDesempenho(sessao.percentualAcerto),
                width: 16,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        );
      }

      if (mounted) {
        setState(() {
          _provaData = barData;
          _carregandoGraficoProvas = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _carregandoGraficoProvas = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar dados da prova: $e')),
        );
      }
    }
  }

  /// Retorna uma cor baseada no desempenho
  Color _getCorPorDesempenho(double percentualAcerto) {
    final colorScheme = Theme.of(context).colorScheme;

    if (percentualAcerto >= 80) {
      return colorScheme.tertiary; // Verde para excelente
    } else if (percentualAcerto >= 60) {
      return colorScheme.primary; // Azul para bom
    } else if (percentualAcerto >= 40) {
      return Colors.orange; // Laranja para médio
    } else {
      return colorScheme.error; // Vermelho para baixo
    }
  }

  Future<void> _carregarDados() async {
    setState(() => _carregando = true);
    try {
      // Carregar estatísticas do backend (completas)
      final stats =
          await GamificacaoBackendService.obterEstatisticasCompletas(); // Carregar progressão do backend (completa)
      final progressao =
          await GamificacaoBackendService.obterEstatisticasCompletas();

      // Calcular provas realizadas baseado no status
      final provasRealizadas =
          _provas
              .where((prova) => prova.status == StatusProva.CONCLUIDA)
              .length;

      if (mounted) {
        setState(() {
          _estatisticas = stats ?? {};
          // Adicionar provas realizadas às estatísticas
          _estatisticas['provasRealizadas'] = provasRealizadas;
          _progressao = progressao ?? {};
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

  /// Constrói o gráfico de barras para análise de desempenho por prova
  Widget _buildProvaChart() {
    if (_provaData.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.outline),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 48,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                _provaSelecionada == null
                    ? 'Selecione uma prova para visualizar\no gráfico de desempenho'
                    : 'Nenhuma sessão encontrada\npara esta prova',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100, // Máximo de 100% de acerto
        minY: 0, // Mínimo de 0% de acerto
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            axisNameWidget: Text(
              'Taxa de Acerto (%)',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: 20, // Intervalos de 20%
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}%',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            axisNameWidget: Text(
              'Sessões de Estudo',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final sessaoNum = value.toInt() + 1;
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    '$sessaoNum',
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          drawVerticalLine: false,
          horizontalInterval: 20, // Linhas horizontais a cada 20%
          getDrawingHorizontalLine:
              (value) => FlLine(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                strokeWidth: 1,
              ),
        ),
        barGroups: _provaData,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor:
                (group) => Theme.of(context).colorScheme.surfaceVariant,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final sessaoNum = group.x + 1;
              final acerto = rod.toY;
              return BarTooltipItem(
                'Sessão $sessaoNum\n${acerto.toStringAsFixed(1)}% de acerto',
                TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
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

  Widget _buildProgressaoCard() {
    final nivel = _progressao['nivel'] ?? 1;
    final xpTotal = _progressao['xpTotal'] ?? 0;
    final xpParaProximoNivel = _calcularXPParaProximoLevel(nivel);
    final xpAtualNoNivel = _calcularXPAtualNoNivel(xpTotal, nivel);
    final progressoNivel =
        xpParaProximoNivel > 0 ? xpAtualNoNivel / xpParaProximoNivel : 1.0;
    final xpRestante = xpParaProximoNivel - xpAtualNoNivel;
    final conquista = _progressao['conquista'];
    final meta = _progressao['meta'];

    print('🎮 Progressão Card - Nível: $nivel, XP Total: $xpTotal');
    print(
      '🎮 XP para próximo nível: $xpParaProximoNivel, XP atual no nível: $xpAtualNoNivel',
    );
    print(
      '🎮 XP restante: $xpRestante, Progresso: ${(progressoNivel * 100).toInt()}%',
    );

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.8),
              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.4),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header com nível e XP
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'LV',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '$nivel',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nível $nivel',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          '$xpTotal XP Total',
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.auto_awesome,
                    color: Theme.of(context).colorScheme.primary,
                    size: 28,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Barra de progresso
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progresso do Nível',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'Faltam $xpRestante XP',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progressoNivel.clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context).colorScheme.secondary,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(progressoNivel * 100).toInt()}% concluído',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),

              // Conquista (se houver)
              if (conquista != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.tertiary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.tertiary.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.emoji_events,
                        color: Theme.of(context).colorScheme.tertiary,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        conquista,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.tertiary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Meta (se houver)
              if (meta != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.flag,
                      color: Theme.of(context).colorScheme.secondary,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Meta: $meta',
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Gerar e exportar PDF com relatório de desempenho
  Future<void> _gerarECompartilharPDF() async {
    try {
      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      ); // Criar o PDF
      final pdf = pw.Document();

      // Dados para o PDF
      final nivel = _progressao['nivel'] ?? 1;
      final xpTotal = _progressao['xpTotal'] ?? 0;
      final totalSessoes = _estatisticas['totalSessoes'] ?? 0;
      final sessoesFinalizadas = _estatisticas['sessoesFinalizadas'] ?? 0;
      final tempoTotal = _estatisticas['tempoTotalFormatado'] ?? '0min';
      final desempenhoMedio = (_estatisticas['desempenhoMedio'] ?? 0.0)
          .toStringAsFixed(1);

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              // Cabeçalho
              pw.Container(
                alignment: pw.Alignment.center,
                child: pw.Column(
                  children: [
                    pw.Text(
                      'Relatório de Desempenho',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue900,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Gerado em ${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}',
                      style: pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.Divider(color: PdfColors.blue900, thickness: 2),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Seção de Progressão
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: PdfColors.blue200),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      children: [
                        pw.Icon(
                          pw.IconData(0xe5ca), // star icon
                          color: PdfColors.blue800,
                          size: 20,
                        ),
                        pw.SizedBox(width: 8),
                        pw.Text(
                          'Progressão Atual',
                          style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue800,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 12),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Nível: $nivel',
                          style: pw.TextStyle(fontSize: 14),
                        ),
                        pw.Text(
                          'XP Total: $xpTotal',
                          style: pw.TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Estatísticas Gerais
              pw.Text(
                'Estatísticas Gerais',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey800,
                ),
              ),
              pw.SizedBox(height: 12),

              // Grid de estatísticas
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey100,
                    ),
                    children: [
                      _buildTableCell('Métrica', isHeader: true),
                      _buildTableCell('Valor', isHeader: true),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _buildTableCell('Total de Sessões'),
                      _buildTableCell('$totalSessoes'),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _buildTableCell('Sessões Finalizadas'),
                      _buildTableCell('$sessoesFinalizadas'),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _buildTableCell('Tempo Total de Estudo'),
                      _buildTableCell(tempoTotal),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _buildTableCell('Desempenho Médio'),
                      _buildTableCell('$desempenhoMedio%'),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 20),

              // Gráfico de desempenho por prova (se houver)
              if (_provaSelecionada != null && _provaData.isNotEmpty) ...[
                pw.Text(
                  'Análise de Desempenho - ${_provaSelecionada!.titulo}',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey800,
                  ),
                ),
                pw.SizedBox(height: 12),

                // Criar gráfico simples para PDF
                pw.Container(height: 200, child: _buildPDFChart()),

                pw.SizedBox(height: 12),
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey50,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Text(
                    'Este gráfico mostra a evolução do desempenho ao longo das sessões de estudo para a prova "${_provaSelecionada!.titulo}". '
                    'Cada barra representa uma sessão e sua altura indica a taxa de acerto obtida.',
                    style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                  ),
                ),
              ],

              pw.SizedBox(height: 30),

              // Rodapé
              pw.Container(
                alignment: pw.Alignment.center,
                child: pw.Text(
                  'Relatório gerado automaticamente pelo App de Estudos',
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey600,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
              ),
            ];
          },
        ),
      );

      // Salvar e compartilhar o PDF
      final output = await getTemporaryDirectory();
      final file = File(
        '${output.path}/relatorio_desempenho_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      await file.writeAsBytes(await pdf.save());

      // Fechar loading
      Navigator.pop(context); // Compartilhar o arquivo
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Relatório de Desempenho - App de Estudos',
        subject: 'Meu Relatório de Desempenho',
      );
    } catch (e) {
      // Fechar loading se estiver aberto
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao gerar PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Helper para criar células da tabela no PDF
  pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 12 : 11,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? PdfColors.grey800 : PdfColors.grey700,
        ),
      ),
    );
  }

  /// Criar gráfico simples para o PDF
  pw.Widget _buildPDFChart() {
    if (_provaData.isEmpty) return pw.Container();

    final maxValue = _provaData
        .map((data) => data.barRods.first.toY)
        .reduce((a, b) => a > b ? a : b);

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          // Título dos eixos
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Sessões de Estudo (X)',
                style: pw.TextStyle(fontSize: 10),
              ),
              pw.Text(
                'Taxa de Acerto % (Y)',
                style: pw.TextStyle(fontSize: 10),
              ),
            ],
          ),
          pw.SizedBox(height: 8),

          // Gráfico de barras simples
          pw.Expanded(
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
              children:
                  _provaData.asMap().entries.map((entry) {
                    final index = entry.key;
                    final data = entry.value;
                    final height =
                        (data.barRods.first.toY / maxValue) *
                        120; // Altura máxima 120

                    return pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      children: [
                        pw.Text(
                          '${data.barRods.first.toY.toInt()}%',
                          style: pw.TextStyle(fontSize: 8),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Container(
                          width: 20,
                          height: height,
                          color: _getPDFBarColor(data.barRods.first.toY),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          '${index + 1}',
                          style: pw.TextStyle(fontSize: 8),
                        ),
                      ],
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// Retorna cor para o PDF baseada no desempenho
  PdfColor _getPDFBarColor(double percentualAcerto) {
    if (percentualAcerto >= 80) {
      return PdfColors.green;
    } else if (percentualAcerto >= 60) {
      return PdfColors.blue;
    } else if (percentualAcerto >= 40) {
      return PdfColors.orange;
    } else {
      return PdfColors.red;
    }
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
                          // Seção do Gráfico de Provas
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Análise de Desempenho por Prova',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Dropdown para seleção de prova
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<Prova>(
                                isExpanded: true,
                                hint: const Text('Selecione uma prova'),
                                value: _provaSelecionada,
                                items:
                                    _provas.map((prova) {
                                      return DropdownMenuItem<Prova>(
                                        value: prova,
                                        child: Text(
                                          prova.titulo,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    }).toList(),
                                onChanged: (Prova? novaProva) {
                                  setState(() {
                                    _provaSelecionada = novaProva;
                                    _provaData.clear();
                                  });
                                  if (novaProva != null) {
                                    _carregarDadosGraficoProvas();
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Gráfico de barras
                          SizedBox(
                            height: 300,
                            child:
                                _carregandoGraficoProvas
                                    ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                    : _buildProvaChart(),
                          ),

                          if (_provaSelecionada != null &&
                              _provaData.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primaryContainer.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.3),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.insights,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Insights da Prova',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Este gráfico mostra a evolução do desempenho ao longo das sessões de estudo para a prova "${_provaSelecionada!.titulo}". '
                                    'Cada barra representa uma sessão (eixo X) e sua altura indica a taxa de acerto (eixo Y). '
                                    'As cores indicam o nível de desempenho: verde (≥80%), azul (60-79%), laranja (40-59%) e vermelho (<40%).',
                                    style: TextStyle(
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 24),

                          // Card de Progressão de Nível
                          _buildProgressaoCard(),
                          const SizedBox(height: 16),

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
                              onPressed: _gerarECompartilharPDF,
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
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const WrappedPage(),
                                  ),
                                );
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
