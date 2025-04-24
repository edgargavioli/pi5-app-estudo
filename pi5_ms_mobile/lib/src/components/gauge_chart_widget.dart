import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class DashboardGaugesSyncfusion extends StatelessWidget {
  const DashboardGaugesSyncfusion({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: const [
        GaugeCard(
          label: 'Tempo',
          valueText: '00h00m',
          value: 0,
          color: Colors.indigo,
        ),
        GaugeCard(
          label: 'Nível',
          valueText: '150xp',
          value: 30,
          color: Colors.amber,
        ),
        GaugeCard(
          label: 'Desempenho',
          valueText: '0%',
          value: 0,
          color: Colors.blueAccent,
        ),
      ],
    );
  }
}

class GaugeCard extends StatelessWidget {
  final String label;
  final String valueText;
  final double value;
  final Color color;

  const GaugeCard({
    super.key,
    required this.label,
    required this.valueText,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 100,
          height: 80,
          child: SfRadialGauge(
            axes: <RadialAxis>[
              RadialAxis(
                startAngle: 180,
                endAngle: 0,
                showTicks: false,
                showLabels: false,
                axisLineStyle: AxisLineStyle(
                  thickness: 0.1,
                  cornerStyle: CornerStyle.bothFlat,
                  color: Colors.grey.shade300,
                  thicknessUnit: GaugeSizeUnit.factor,
                ),
                pointers: <GaugePointer>[
                  RangePointer(
                    value: value,
                    width: 0.1,
                    sizeUnit: GaugeSizeUnit.factor,
                    color: color,
                    cornerStyle: CornerStyle.bothCurve,
                  ),
                ],
                annotations: <GaugeAnnotation>[
                  GaugeAnnotation(
                    widget: Text(
                      valueText,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    angle: 90,
                    positionFactor: 0.1,
                  ),
                ],
              ),
            ],
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
