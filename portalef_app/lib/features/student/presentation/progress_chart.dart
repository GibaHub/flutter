import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class ProgressChart extends StatelessWidget {
  const ProgressChart({
    super.key,
    required this.points,
    this.height = 180,
  });

  final List<double> points;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(child: Text('Sem dados')),
      );
    }

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (var i = 0; i < points.length; i++)
                  FlSpot(i.toDouble(), points[i]),
              ],
              isCurved: true,
              color: AppColors.royalBlue,
              barWidth: 3,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.royalBlue.withValues(alpha: 0.12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

