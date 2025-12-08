import 'package:fintrack/constants/constants.dart';
import 'package:fintrack/features/transaction/controllers/transaction_provider.dart';
import 'package:fintrack/models/budget_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'add_budget.dart';

class AnggaranScreen extends StatefulWidget {
  const AnggaranScreen({super.key});

  @override
  State<AnggaranScreen> createState() => _AnggaranScreenState();
}

class _AnggaranScreenState extends State<AnggaranScreen> {
  final currency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  Color _progressColor(double percent) {
    if (percent <= 30) return Colors.green;
    if (percent <= 55) return Colors.yellow;
    if (percent <= 75) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Anggaran",
                  style: TextStyle(
                    color: ColorPallete.white,
                    fontSize: 26.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: ColorPallete.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AddBudgetPage()),
                      );
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: ColorPallete.blackLight,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.add,
                        color: ColorPallete.green,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Consumer<TransactionProvider>(
                builder: (context, provider, child) {
                  if (provider.budgets.isEmpty) {
                    return _emptyView();
                  }
                  return _listView(provider.budgets);
                },
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _emptyView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 64,
            color: ColorPallete.grey,
          ),
          const SizedBox(height: 12),
          const Text(
            'Belum ada anggaran',
            style: TextStyle(color: ColorPallete.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _listView(List<BudgetModel> budgets) {
    return ListView.separated(
      itemCount: budgets.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final b = budgets[index];
        final used = b.totalDipakai;
        final total = b.jumlahAnggaran;
        final percent = total <= 0 ? 0.0 : ((used / total) * 100);
        final progress = (percent / 100).clamp(0.0, 1.0);
        final progressColor = _progressColor(percent);

        return Container(
          decoration: BoxDecoration(
            color: ColorPallete.blackLight,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    b.nama,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    currency.format((total - used).clamp(0, double.infinity)),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Subtitle row (category & total)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    b.kategori,
                    style: const TextStyle(
                      color: ColorPallete.grey,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Total: ${currency.format(total)}',
                    style: const TextStyle(
                      color: ColorPallete.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Progress bar with percentage label inside
              Stack(
                children: [
                  Container(
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F1F1F),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth * progress;
                      return Container(
                        width: width,
                        height: 24,
                        decoration: BoxDecoration(
                          color: progressColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      );
                    },
                  ),
                  Positioned.fill(
                    child: Center(
                      child: Text(
                        '${percent.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Dates
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mulai: ${DateFormat('dd MMM yyyy', 'id_ID').format(b.tanggalMulai)}',
                    style: const TextStyle(
                      color: ColorPallete.grey,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    'Akhir: ${DateFormat('dd MMM yyyy', 'id_ID').format(b.tanggalAkhir)}',
                    style: const TextStyle(
                      color: ColorPallete.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
