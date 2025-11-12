import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DoubleLineChart extends StatelessWidget {
  const DoubleLineChart({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(show: true),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            // Garis 1
            LineChartBarData(
              spots: [
                FlSpot(0, 2),
                FlSpot(1, 3.5),
                FlSpot(2, 4),
                FlSpot(3, 3.2),
                FlSpot(4, 5),
              ],
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
              dotData: FlDotData(show: false),
            ),
            // Garis 2
            LineChartBarData(
              spots: [
                FlSpot(0, 1),
                FlSpot(1, 2),
                FlSpot(2, 2.8),
                FlSpot(3, 2),
                FlSpot(4, 3.5),
              ],
              isCurved: true,
              color: Colors.orange,
              barWidth: 3,
              dotData: FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}
