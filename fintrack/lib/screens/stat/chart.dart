import 'package:fintrack/constants/constants.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MyChart extends StatefulWidget {
  const MyChart({super.key});

  @override
  State<StatefulWidget> createState() => _MyChartState();
}

class _MyChartState extends State<MyChart> {
  final double width = 8;

  late List<BarChartGroupData> rawBarGroups;
  late List<BarChartGroupData> showingBarGroups;

  int touchedGroupIndex = -1;

  @override
  void initState() {
    super.initState();
    final barGroup1 = makeGroupData(0, 5, 12);
    final barGroup2 = makeGroupData(1, 16, 12);
    final barGroup3 = makeGroupData(2, 18, 5);
    final barGroup4 = makeGroupData(3, 20, 16);
    final barGroup5 = makeGroupData(4, 17, 6);
    final barGroup6 = makeGroupData(5, 19, 1.5);
    final barGroup7 = makeGroupData(6, 10, 1.5);

    final items = [
      barGroup1,
      barGroup2,
      barGroup3,
      barGroup4,
      barGroup5,
      barGroup6,
      barGroup7,
    ];

    rawBarGroups = items;

    showingBarGroups = rawBarGroups;
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: BarChart(mainBarChart()),
    );
  }

  BarChartData mainBarChart() {
    return BarChartData(
      maxY: 20,
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: ((group) {
            return ColorPallete.blackLight;
          }),
          getTooltipItem: (a, b, c, d) => null,
        ),
        touchCallback: (FlTouchEvent event, response) {
          if (response == null || response.spot == null) {
            setState(() {
              touchedGroupIndex = -1;
              showingBarGroups = List.of(rawBarGroups);
            });
            return;
          }

          touchedGroupIndex = response.spot!.touchedBarGroupIndex;

          setState(() {
            if (!event.isInterestedForInteractions) {
              touchedGroupIndex = -1;
              showingBarGroups = List.of(rawBarGroups);
              return;
            }
            showingBarGroups = List.of(rawBarGroups);
            if (touchedGroupIndex != -1) {
              var sum = 0.0;
              for (final rod in showingBarGroups[touchedGroupIndex].barRods) {
                sum += rod.toY;
              }
              final avg =
                  sum / showingBarGroups[touchedGroupIndex].barRods.length;

              showingBarGroups[touchedGroupIndex] =
                  showingBarGroups[touchedGroupIndex].copyWith(
                    barRods: showingBarGroups[touchedGroupIndex].barRods.map((
                      rod,
                    ) {
                      return rod.copyWith(
                        toY: avg,
                        gradient: LinearGradient(
                          colors: [ColorPallete.greenLight, ColorPallete.white],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      );
                    }).toList(),
                  );
            }
          });
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
            interval: 1,
            getTitlesWidget: leftTitles,
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      barGroups: showingBarGroups,
      gridData: const FlGridData(show: false),
    );
  }

  Widget leftTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: ColorPallete.grey,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    String text;
    if (value == 0) {
      text = '1K';
    } else if (value == 10) {
      text = '5K';
    } else if (value == 19) {
      text = '10K';
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
      titles[value.toInt()],
      style: const TextStyle(
        color: ColorPallete.grey,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );

    return SideTitleWidget(
      meta: meta,
      space: 16, //margin top
      child: text,
    );
  }

  BarChartGroupData makeGroupData(int x, double y1, double y2) {
    return BarChartGroupData(
      barsSpace: 4,
      x: x,
      barRods: [
        BarChartRodData(
          toY: y1,
          gradient: LinearGradient(
            colors: [ColorPallete.green, ColorPallete.greenLight],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          width: width,
          borderRadius: BorderRadius.circular(6),
        ),
        BarChartRodData(
          toY: y2,
          gradient: LinearGradient(
            colors: [const Color.fromARGB(255, 255, 93, 93), Color.fromARGB(255, 255, 153, 153)],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          width: width,
          borderRadius: BorderRadius.circular(6),
        ),
      ],
    );
  }

  Widget makeTransactionsIcon() {
    const width = 4.5;
    const space = 3.5;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: width,
          height: 10,
          color: ColorPallete.white.withOpacity(0.4),
        ),
        const SizedBox(width: space),
        Container(
          width: width,
          height: 28,
          color: ColorPallete.white.withOpacity(0.8),
        ),
        const SizedBox(width: space),
        Container(
          width: width,
          height: 42,
          color: ColorPallete.white.withOpacity(1),
        ),
        const SizedBox(width: space),
        Container(
          width: width,
          height: 28,
          color: ColorPallete.white.withOpacity(0.8),
        ),
        const SizedBox(width: space),
        Container(
          width: width,
          height: 10,
          color: ColorPallete.white.withOpacity(0.4),
        ),
      ],
    );
  }
}
