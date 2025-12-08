import 'package:fintrack/core/constants/constants.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MyChart extends StatelessWidget {
  final bool isWeekly; // To decide labels

  const MyChart({super.key, this.isWeekly = true});

  @override
  Widget build(BuildContext context) {
    // Mock data generation based on view
    final List<double> incomeData = [5, 12, 18, 10, 15, 9, 2];
    final List<double> expenseData = [3, 10, 5, 16, 6, 1.5, 9];

    return BarChart(
      BarChartData(
        maxY: 20,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => ColorPallete.blackLight,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                rod.toY.toString(),
                const TextStyle(
                  color: ColorPallete.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: bottomTitles,
              reservedSize: 42,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: leftTitles,
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 5,
          getDrawingHorizontalLine: (value) {
            return const FlLine(color: Colors.white10, strokeWidth: 1);
          },
        ),
        barGroups: List.generate(7, (index) {
          return makeGroupData(index, incomeData[index], expenseData[index]);
        }),
      ),
    );
  }

  Widget leftTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: ColorPallete.grey,
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );
    String text;
    if (value == 0) {
      text = '0';
    } else if (value == 10) {
      text = '10K';
    } else if (value == 20) {
      text = '20K';
    } else {
      return Container();
    }
    return SideTitleWidget(
      meta: meta,
      space: 0,
      child: Text(text, style: style),
    );
  }

  Widget bottomTitles(double value, TitleMeta meta) {
    final titles = <String>['Sn', 'Sl', 'Rb', 'Km', 'Jm', 'Sb', 'Mg'];

    final Widget text = Text(
      value.toInt() < titles.length ? titles[value.toInt()] : '',
      style: const TextStyle(
        color: ColorPallete.grey,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    );

    return SideTitleWidget(meta: meta, space: 10, child: text);
  }

  BarChartGroupData makeGroupData(int x, double y1, double y2) {
    return BarChartGroupData(
      barsSpace: 4,
      x: x,
      barRods: [
        BarChartRodData(
          toY: y1,
          gradient: const LinearGradient(
            colors: [ColorPallete.green, ColorPallete.greenLight],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          width: 8,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        ),
        BarChartRodData(
          toY: y2,
          gradient: const LinearGradient(
            colors: [Color(0xFFE57373), Color(0xFFFFCDD2)],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          width: 8,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        ),
      ],
    );
  }
}
