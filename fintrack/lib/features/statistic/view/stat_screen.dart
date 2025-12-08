import 'package:fintrack/core/constants/constants.dart';
import 'package:fintrack/features/transaction/view/history/history_screen.dart';
import 'package:fintrack/features/statistic/widgets/bar_chart.dart';
import 'package:fintrack/features/statistic/controllers/date_filter_controller.dart';
import 'package:fintrack/features/statistic/widgets/pie_chart.dart';
import 'package:fintrack/features/statistic/widgets/stat_filter_section.dart';
import 'package:flutter/material.dart';

class StatScreen extends StatefulWidget {
  const StatScreen({super.key});

  @override
  State<StatScreen> createState() => _StatScreenState();
}

class _StatScreenState extends State<StatScreen> {
  late final DateFilterController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DateFilterController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Statistik",
                      style: TextStyle(
                        fontSize: 26.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HistoryScreen(),
                          ),
                        );
                      },
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: ColorPallete.blackLight,
                          borderRadius: BorderRadius.circular(160.0),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: const Icon(
                          Icons.history,
                          color: Colors.white,
                          size: 24.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Sticky Filter Header
            // Filter Section (Non-sticky)
            SliverToBoxAdapter(
              child: Container(
                color: ColorPallete.black, // Match background
                padding: const EdgeInsets.only(bottom: 16),
                child: ListenableBuilder(
                  listenable: _controller,
                  builder: (context, _) =>
                      StatFilterSection(controller: _controller),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: ColorPallete.blackLight,
                      borderRadius: BorderRadius.circular(24.0),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Overview",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Pass controller state if needed for reactivity
                        ListenableBuilder(
                          listenable: _controller,
                          builder: (context, _) {
                            // Here passing isWeekly just to show reactivity logic possibility
                            return AspectRatio(
                              aspectRatio: 1.6,
                              child: MyChart(
                                isWeekly:
                                    _controller.period == StatPeriod.weekly,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: ColorPallete.blackLight,
                      borderRadius: BorderRadius.circular(24.0),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Per kategori",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        MyPieChart(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 80), // Bottom padding
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
