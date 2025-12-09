import 'package:fintrack/core/constants/constants.dart';
import 'package:fintrack/features/statistic/controllers/date_filter_controller.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MyChart extends StatelessWidget {
  final StatPeriod period;
  final List<double> incomeData;
  final List<double> expenseData;

  const MyChart({
    super.key,
    required this.period,
    required this.incomeData,
    required this.expenseData,
  });

  @override
  Widget build(BuildContext context) {
    double maxIncome = 0;
    for (var val in incomeData) {
      if (val > maxIncome) maxIncome = val;
    }
    double maxExpense = 0;
    for (var val in expenseData) {
      if (val > maxExpense) maxExpense = val;
    }
    double maxVal = maxIncome > maxExpense ? maxIncome : maxExpense;
    if (maxVal == 0) maxVal = 100;

    final double maxY = maxVal * 1.2;
    final double interval = maxY / 5;

    return BarChart(
      BarChartData(
        maxY: maxY,
        minY: 0,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => ColorPallete.blackLight,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                formatCompactNumber(rod.toY),
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
              reservedSize: 32,
              getTitlesWidget: leftTitles,
              interval: interval,
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: interval,
          getDrawingHorizontalLine: (value) {
            return const FlLine(color: Colors.white10, strokeWidth: 1);
          },
        ),
        barGroups: List.generate(incomeData.length, (index) {
          return makeGroupData(index, incomeData[index], expenseData[index]);
        }),
      ),
    );
  }

  Widget leftTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: ColorPallete.grey,
      fontWeight: FontWeight.bold,
      fontSize: 10,
    );

    if (value == 0) return Container();

    return SideTitleWidget(
      meta: meta,
      space: 0,
      child: Text(formatCompactNumber(value), style: style),
    );
  }

  String formatCompactNumber(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    }
    return value.toStringAsFixed(0);
  }

  Widget bottomTitles(double value, TitleMeta meta) {
    final titlesWeekly = <String>['Sn', 'Sl', 'Rb', 'Km', 'Jm', 'Sb', 'Mg'];
    final titlesMonthly = <String>['W1', 'W2', 'W3', 'W4', 'W5'];
    final titlesYearly = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    List<String> titles;
    switch (period) {
      case StatPeriod.weekly:
        titles = titlesWeekly;
        break;
      case StatPeriod.monthly:
        titles = titlesMonthly;
        break;
      case StatPeriod.yearly:
        titles = titlesYearly;
        break;
    }

    final Widget text = Text(
      value.toInt() < titles.length ? titles[value.toInt()] : '',
      style: const TextStyle(
        color: ColorPallete.grey,
        fontWeight: FontWeight.bold,
        fontSize: 10,
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
