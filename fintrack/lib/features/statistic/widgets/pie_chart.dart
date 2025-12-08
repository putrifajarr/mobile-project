import 'package:fintrack/core/constants/constants.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MyPieChart extends StatefulWidget {
  const MyPieChart({super.key});

  @override
  State<StatefulWidget> createState() => MyPieChartState();
}

class MyPieChartState extends State<MyPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.3,
      child: Row(
        children: <Widget>[
          const SizedBox(height: 18),
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          touchedIndex = -1;
                          return;
                        }
                        touchedIndex = pieTouchResponse
                            .touchedSection!
                            .touchedSectionIndex;
                      });
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 0,
                  centerSpaceRadius: 40,
                  sections: showingSections(),
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ChartLegendIndicator(color: ColorPallete.green, text: 'Matcha'),
              SizedBox(height: 8),
              ChartLegendIndicator(color: ColorPallete.red, text: 'Jajan'),
              SizedBox(height: 8),
              ChartLegendIndicator(color: ColorPallete.blue, text: 'Tabungan'),
              SizedBox(height: 8),
              ChartLegendIndicator(color: ColorPallete.yellow, text: 'Daily'),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(4, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 20.0 : 14.0;
      final radius = isTouched ? 65.0 : 55.0;

      return switch (i) {
        0 => PieChartSectionData(
          color: ColorPallete.green,
          value: 40,
          title: '40%',
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: ColorPallete.black,
          ),
        ),
        1 => PieChartSectionData(
          color: ColorPallete.red,
          value: 30,
          title: '30%',
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: ColorPallete.black,
          ),
        ),
        2 => PieChartSectionData(
          color: ColorPallete.blue,
          value: 15,
          title: '15%',
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: ColorPallete.black,
          ),
        ),
        3 => PieChartSectionData(
          color: ColorPallete.yellow,
          value: 15,
          title: '15%',
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: ColorPallete.black,
          ),
        ),
        _ => throw StateError('Invalid'),
      };
    });
  }
}

class ChartLegendIndicator extends StatelessWidget {
  const ChartLegendIndicator({
    super.key,
    required this.color,
    required this.text,
    this.size = 12,
    this.textColor,
  });

  final Color color;
  final String text;
  final double size;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textColor ?? Colors.white70,
          ),
        ),
      ],
    );
  }
}
