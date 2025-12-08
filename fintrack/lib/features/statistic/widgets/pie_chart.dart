import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CategoryStatData {
  final String name;
  final double amount;
  final Color color;
  final double percentage;

  CategoryStatData({
    required this.name,
    required this.amount,
    required this.color,
    required this.percentage,
  });
}

class MyPieChart extends StatefulWidget {
  final List<CategoryStatData> data;

  const MyPieChart({super.key, required this.data});

  @override
  State<StatefulWidget> createState() => MyPieChartState();
}

class MyPieChartState extends State<MyPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text(
            "Tidak ada pengeluaran",
            style: TextStyle(color: Colors.white54),
          ),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 1.3,
      child: Row(
        children: <Widget>[
          const SizedBox(height: 18),
          Expanded(
            flex: 3,
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
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.data.map((e) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: ChartLegendIndicator(
                    color: e.color,
                    text: '${e.name} (${e.percentage.toStringAsFixed(0)}%)',
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(widget.data.length, (i) {
      final isTouched = i == touchedIndex;
      final radius = isTouched ? 65.0 : 55.0;
      final item = widget.data[i];

      return PieChartSectionData(
        color: item.color,
        value: item.percentage,
        title: '${item.percentage.toStringAsFixed(0)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: isTouched ? 16.0 : 12.0,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      );
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
        Expanded(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: textColor ?? Colors.white70,
            ),
          ),
        ),
      ],
    );
  }
}
