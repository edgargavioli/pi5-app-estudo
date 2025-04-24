import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pi5_ms_mobile/src/components/scaffold_widget.dart';
import 'package:pi5_ms_mobile/src/components/button_widget.dart';
import 'package:intl/intl.dart';

class DesempenhoPage extends StatefulWidget {
  const DesempenhoPage({super.key});

  @override
  State<DesempenhoPage> createState() => _DesempenhoPageState();
}

class _DesempenhoPageState extends State<DesempenhoPage> {
  // sample labels and values for subjects and progression
  final List<String> _subjectLabels = [
    'Mat',
    'His',
    'Geo',
    'Por',
    'Eng S',
    'Sis',
    'Fis',
  ];
  final List<double> _subjectValues = [8, 12, 14, 16, 14, 17, 16];
  // sample progression per prova (number of correct exercises)
  final List<double> _progressValues = [5, 8, 10, 12, 15, 12, 10];
  // filters
  DateTimeRange? _rangeDia;
  DateTimeRange? _rangeMateria;
  String? _selectedExam;

  Future<void> _pickRangeDia() async {
    final picked = await showDateRangePicker(
      context: context,
      locale: const Locale('pt', 'BR'),
      helpText: 'Selecione o período',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        // Constrain size of the date picker dialog
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 350, maxHeight: 500),
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.all(Radius.circular(8)),
              child: child,
            ),
          ),
        );
      },
    );
    if (picked != null) setState(() => _rangeDia = picked);
  }

  Future<void> _pickRangeMateria() async {
    final picked = await showDateRangePicker(
      context: context,
      locale: const Locale('pt', 'BR'),
      helpText: 'Selecione o período',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _rangeMateria = picked);
  }

  // sample data for weekly and monthly
  final List<BarChartGroupData> _weeklyData = List.generate(7, (i) {
    return BarChartGroupData(
      x: i,
      barRods: [
        BarChartRodData(
          toY: (i + 1) * 2,
          color: const Color(0xFF3A608F),
          width: 12,
        ),
      ],
    );
  });

  final List<BarChartGroupData> _monthlyData = List.generate(30, (i) {
    return BarChartGroupData(
      x: i + 1,
      barRods: [
        BarChartRodData(
          toY: (i % 7 + 1) * 1.2,
          color: const Color(0xFF3A608F),
          width: 12,
        ),
      ],
    );
  });

  @override
  Widget build(BuildContext context) {
    return ScaffoldWidget(
      currentPage: 3, // index for Desempenho
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
          child: Column(
            children: [
              // Header with title
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Desempenho',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
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
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Section: Geral
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
                            onPressed: _pickRangeDia,
                            icon: const Icon(Icons.calendar_today, size: 18),
                            label: Text(
                              _rangeDia == null
                                  ? 'Selecionar período'
                                  : '${_rangeDia!.start.day}/${_rangeDia!.start.month}/${_rangeDia!.start.year}'
                                      ' - ${_rangeDia!.end.day}/${_rangeDia!.end.month}/${_rangeDia!.end.year}',
                              style: const TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Single chart for 'Horas por Dia'
                      SizedBox(
                        height: 200,
                        child: _buildBarChart(_weeklyData, isWeekly: true),
                      ),

                      const SizedBox(height: 4),
                      Divider(
                        thickness: 1,
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                      const SizedBox(height: 8),
                      // Section: Por matéria
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Horas por Matéria',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _pickRangeMateria,
                            icon: const Icon(Icons.calendar_today, size: 18),
                            label: Text(
                              _rangeMateria == null
                                  ? 'Selecionar período'
                                  : '${_rangeMateria!.start.day}/${_rangeMateria!.start.month}/${_rangeMateria!.start.year}'
                                      ' - ${_rangeMateria!.end.day}/${_rangeMateria!.end.month}/${_rangeMateria!.end.year}',
                              style: const TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Horizontal scrollable subject chart
                      SizedBox(
                        height: 200,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: _subjectLabels.length * 60.0,
                            child: _buildBarChart(
                              List.generate(
                                _subjectLabels.length,
                                (i) => BarChartGroupData(
                                  x: i,
                                  barRods: [
                                    BarChartRodData(
                                      toY: _subjectValues[i],
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      width: 12,
                                    ),
                                  ],
                                ),
                              ),
                              isWeekly: false,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 4),
                      Divider(
                        thickness: 1,
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                      const SizedBox(height: 8),
                      // Section: Progressão por Prova
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Acertos por Prova',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          // exam selection styled like date pickers
                          TextButton.icon(
                            onPressed: () async {
                              // simple selection dialog
                              final exam = await showDialog<String>(
                                context: context,
                                builder:
                                    (ctx) => SimpleDialog(
                                      title: const Text('Selecione prova'),
                                      children:
                                          ['Prova 1', 'Prova 2', 'Prova 3']
                                              .map(
                                                (e) => SimpleDialogOption(
                                                  child: Text(e),
                                                  onPressed:
                                                      () =>
                                                          Navigator.pop(ctx, e),
                                                ),
                                              )
                                              .toList(),
                                    ),
                              );
                              if (exam != null)
                                setState(() => _selectedExam = exam);
                            },
                            icon: const Icon(Icons.filter_list, size: 18),
                            label: Text(
                              _selectedExam ?? 'Selecione prova',
                              style: const TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Horizontal scrollable progression chart
                      // Horizontal scrollable progression chart
                      SizedBox(
                        height: 200,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: _subjectLabels.length * 60.0,
                            child: _buildBarChart(
                              List.generate(
                                _subjectLabels.length,
                                (i) => BarChartGroupData(
                                  x: i,
                                  barRods: [
                                    BarChartRodData(
                                      toY: _progressValues[i],
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      width: 12,
                                    ),
                                  ],
                                ),
                              ),
                              isWeekly: false,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                      // Export PDF button
                      SizedBox(
                        width: double.infinity,
                        child: ButtonWidget(
                          text: 'Exportar PDF',
                          onPressed: () {
                            // TODO: implement PDF export
                          },
                          color: Theme.of(context).colorScheme.primary,
                          textStyle: Theme.of(
                            context,
                          ).textTheme.labelLarge?.copyWith(color: Colors.white),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart(
    List<BarChartGroupData> data, {
    required bool isWeekly,
  }) {
    // style configurations
    final barColor = Theme.of(context).colorScheme.primary;
    final barBgColor = barColor.withOpacity(0.3);
    const animDuration = Duration(milliseconds: 250);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: BarChart(
        // add animation
        swapAnimationDuration: animDuration,
        swapAnimationCurve: Curves.easeInOut,
        BarChartData(
          // show tooltip on touch
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              // tooltipBgColor not supported in this version of fl_chart; using default background
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${rod.toY}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 5,
                reservedSize: 30,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 30),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawHorizontalLine: true,
            horizontalInterval: isWeekly ? 5 : 5,
          ),
          borderData: FlBorderData(show: false),
          alignment: BarChartAlignment.spaceAround,
          maxY: isWeekly ? 20 : 30,
          minY: 0,
          barGroups:
              data.map((group) {
                return BarChartGroupData(
                  x: group.x,
                  barRods:
                      group.barRods.map((rod) {
                        return BarChartRodData(
                          toY: rod.toY,
                          width: rod.width,
                          color: barColor,
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: isWeekly ? 20 : 30,
                            color: barBgColor,
                          ),
                        );
                      }).toList(),
                  // showingTooltipIndicators removed to display tooltips only on touch
                );
              }).toList(),
        ),
      ),
    );
  }
}
