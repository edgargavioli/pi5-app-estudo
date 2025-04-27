import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class DashboardGaugesSyncfusion extends StatelessWidget {
  final List<GaugeData> gauges;

  const DashboardGaugesSyncfusion({super.key, required this.gauges});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children:
          gauges.map((gauge) {
            return GaugeCard(
              label: gauge.label,
              valueText: gauge.valueText,
              value: gauge.value,
              color: gauge.color,
            );
          }).toList(),
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

class GaugeData {
  final String label;
  final String valueText;
  final double value;
  final Color color;

  GaugeData({
    required this.label,
    required this.valueText,
    required this.value,
    required this.color,
  });
}
