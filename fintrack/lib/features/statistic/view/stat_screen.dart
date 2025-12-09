import 'package:fintrack/core/constants/constants.dart';
import 'package:fintrack/features/transaction/models/transaction_model.dart';
import 'package:fintrack/features/transaction/services/transaction_service.dart';

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
  bool _isLoading = false;
  List<double> _incomeData = [];
  List<double> _expenseData = [];
  List<CategoryStatData> _pieData = [];

  final TransactionService _service = TransactionService();

  @override
  void initState() {
    super.initState();
    _controller = DateFilterController();
    _controller.addListener(_fetchData);
    _fetchData();
  }

  @override
  void dispose() {
    _controller.removeListener(_fetchData);

    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final range = _controller.currentRange;
      final transactions = await _service.getTransactionsInRange(
        range.start,
        range.end,
      );
      _processData(transactions);
    } catch (e) {
      debugPrint('Error fetching statistics: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _processData(List<TransactionModel> transactions) {
    List<double> incomeBuckets;
    List<double> expenseBuckets;

    // Initialize buckets based on period
    if (_controller.period == StatPeriod.weekly) {
      incomeBuckets = List.filled(7, 0.0);
      expenseBuckets = List.filled(7, 0.0);
    } else if (_controller.period == StatPeriod.monthly) {
      incomeBuckets = List.filled(5, 0.0);
      expenseBuckets = List.filled(5, 0.0);
    } else {
      // Yearly
      incomeBuckets = List.filled(12, 0.0);
      expenseBuckets = List.filled(12, 0.0);
    }

    // Pie Chart Data
    final Map<String, double> categoryDistribution = {};

    for (var t in transactions) {
      final type = t.category?.type;
      final amount = t.amount;
      final date = t.date;

      // Pie Chart Data
      if (type == 'expense') {
        final catName = t.category?.name ?? 'Lainnya';
        categoryDistribution[catName] =
            (categoryDistribution[catName] ?? 0) + amount;
      }

      // Bar Chart Data
      int index = -1;
      if (_controller.period == StatPeriod.weekly) {
        index = date.weekday - 1;
      } else if (_controller.period == StatPeriod.monthly) {
        index = (date.day - 1) ~/ 7;
        if (index > 4) index = 4;
      } else {
        index = date.month - 1;
      }

      if (index >= 0 && index < incomeBuckets.length) {
        if (type == 'income') {
          incomeBuckets[index] += amount;
        } else if (type == 'expense') {
          expenseBuckets[index] += amount;
        }
      }
    }

    // Process Pie Data into View Objects
    final totalAmount = categoryDistribution.values.fold(0.0, (a, b) => a + b);
    final List<CategoryStatData> finalPieData = [];
    final colors = [
      const Color.fromARGB(255, 54, 219, 183),
      ColorPallete.red,
      ColorPallete.blue,
      ColorPallete.yellow,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.cyan,
    ];
    int colorIdx = 0;

    categoryDistribution.forEach((name, amount) {
      if (totalAmount > 0) {
        final percentage = (amount / totalAmount) * 100;
        finalPieData.add(
          CategoryStatData(
            name: name,
            amount: amount,
            color: colors[colorIdx % colors.length],
            percentage: percentage,
          ),
        );
        colorIdx++;
      }
    });

    // Sort Pie Data by percentage descending
    finalPieData.sort((a, b) => b.percentage.compareTo(a.percentage));

    if (mounted) {
      setState(() {
        _incomeData = incomeBuckets;
        _expenseData = expenseBuckets;
        _pieData = finalPieData;
      });
    }
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

            // Header Date Filter
            SliverToBoxAdapter(
              child: Container(
                color: ColorPallete.black,

                padding: const EdgeInsets.only(bottom: 16),
                child: ListenableBuilder(
                  listenable: _controller,
                  builder: (context, _) =>
                      StatFilterSection(controller: _controller),
                ),
              ),
            ),

            if (_isLoading)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: ColorPallete.green),
                ),
              )
            else
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    // Overview Chart
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
                          AspectRatio(
                            aspectRatio: 1.6,
                            child: MyChart(
                              period: _controller.period,
                              incomeData: _incomeData,
                              expenseData: _expenseData,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20.0),

                    // Pie Chart Section
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
                            "Alokasi dana",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          MyPieChart(data: _pieData),
                        ],
                      ),
                    ),
                    // Bottom padding for scrolling
                    const SizedBox(height: 80),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
