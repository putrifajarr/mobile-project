import 'package:fintrack/core/constants/constants.dart';
import 'package:fintrack/features/transaction/controllers/transaction_provider.dart';
import 'package:fintrack/features/transaction/view/add_transaction_screen.dart';
import 'package:fintrack/features/transaction/view/history/widgets/history_item.dart';
import 'package:fintrack/core/widgets/empty_state.dart';
import 'package:fintrack/core/utils/snackbar_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

enum SortOption { newest, oldest }

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  static const double _filterHeight = 44.0;
  DateTimeRange? _selectedDateRange;
  SortOption _sortOption = SortOption.newest;

  @override
  Widget build(BuildContext context) {
    final textStyle = const TextStyle(color: Colors.white);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Riwayat Transaksi',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: ColorPallete.black,
        elevation: 0,
      ),
      backgroundColor: ColorPallete.black,
      body: Column(
        children: [
          _buildFilterSection(textStyle),
          const SizedBox(height: 12),
          Expanded(
            child: Consumer<TransactionProvider>(
              builder: (context, provider, child) {
                var transactions = List.of(provider.transactions);

                if (_selectedDateRange != null) {
                  transactions = transactions.where((t) {
                    final date = DateTime(
                      t.date.year,
                      t.date.month,
                      t.date.day,
                    );
                    final start = DateTime(
                      _selectedDateRange!.start.year,
                      _selectedDateRange!.start.month,
                      _selectedDateRange!.start.day,
                    );
                    final end = DateTime(
                      _selectedDateRange!.end.year,
                      _selectedDateRange!.end.month,
                      _selectedDateRange!.end.day,
                    );

                    return (date.isAtSameMomentAs(start) ||
                            date.isAfter(start)) &&
                        (date.isAtSameMomentAs(end) || date.isBefore(end));
                  }).toList();
                }

                // Sort
                transactions.sort((a, b) {
                  if (_sortOption == SortOption.newest) {
                    return b.date.compareTo(a.date);
                  } else {
                    return a.date.compareTo(b.date);
                  }
                });

                if (transactions.isEmpty) {
                  return EmptyState(
                    message: _selectedDateRange == null
                        ? 'Belum ada transaksi untuk ditampilkan.'
                        : 'Tidak ada transaksi untuk rentang tanggal yang dipilih.',
                    onAction: () => setState(() => _selectedDateRange = null),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  itemCount: transactions.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final t = transactions[index];
                    return HistoryItem(
                      transaction: t,
                      onEdit: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AddTransactionScreen(isEdit: true, existing: t),
                          ),
                        );
                      },
                      onDelete: () async {
                        final deletedTransaction = t;
                        await provider.deleteTransaction(t.id);
                        if (context.mounted) {
                          showUndoSnackBar(
                            context,
                            message: 'Transaksi berhasil dihapus',
                            onUndo: () {
                              provider.add(deletedTransaction);
                            },
                          );
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(TextStyle textStyle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: ColorPallete.black,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _pickDateRange,
              child: Container(
                height: _filterHeight,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: ColorPallete.blackLight,
                  border: Border.all(color: const Color(0x39D9D9D9)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 18,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _selectedDateRange == null
                            ? 'Pilih Rentang Tanggal'
                            : _formatRange(_selectedDateRange!),
                        style: textStyle.copyWith(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (_selectedDateRange != null)
                      GestureDetector(
                        onTap: () => setState(() => _selectedDateRange = null),
                        child: const Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Icon(
                            Icons.close,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          Container(
            height: _filterHeight,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: ColorPallete.blackLight,
              border: Border.all(color: const Color(0x39D9D9D9)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: PopupMenuButton<SortOption>(
                onSelected: (SortOption value) {
                  setState(() {
                    _sortOption = value;
                  });
                },
                color: ColorPallete.blackLight,
                borderRadius: BorderRadius.circular(10),
                elevation: 8,
                position: PopupMenuPosition.under,
                tooltip: 'Urutkan',
                offset: const Offset(0, 20),
                itemBuilder: (context) => <PopupMenuEntry<SortOption>>[
                  PopupMenuItem<SortOption>(
                    value: SortOption.newest,
                    child: _menuItemContent(
                      icon: Icons.arrow_downward,
                      text: 'Terbaru',
                      active: _sortOption == SortOption.newest,
                    ),
                  ),
                  PopupMenuItem<SortOption>(
                    value: SortOption.oldest,
                    child: _menuItemContent(
                      icon: Icons.arrow_upward,
                      text: 'Terlama',
                      active: _sortOption == SortOption.oldest,
                    ),
                  ),
                ],
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.sort, size: 18, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      _sortOption == SortOption.newest ? 'Terbaru' : 'Terlama',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuItemContent({
    required IconData icon,
    required String text,
    required bool active,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: active ? ColorPallete.green : Colors.white),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: active ? ColorPallete.green : Colors.white),
          ),
        ),
        if (active) Icon(Icons.check, size: 16, color: ColorPallete.green),
      ],
    );
  }

  Future<void> _pickDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
      locale: const Locale('id', 'ID'),
      saveText: "Simpan",
      cancelText: "Batal",
      helpText: "Pilih Periode Transaksi",
      fieldStartHintText: "Tanggal Mulai",
      fieldEndHintText: "Tanggal Akhir",
      fieldStartLabelText: "Mulai",
      fieldEndLabelText: "Selesai",
      errorFormatText: "Format tanggal salah",
      errorInvalidText: "Tanggal tidak valid",
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            scaffoldBackgroundColor: ColorPallete.black,
            colorScheme: ColorScheme.dark(
              primary: ColorPallete.green,
              onPrimary: ColorPallete.black,
              surface: ColorPallete.blackLight,
              onSurface: Colors.white,
              error: ColorPallete.red,
              secondary: ColorPallete.green,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: ColorPallete.black,
              iconTheme: IconThemeData(color: Colors.white),
              elevation: 0,
              centerTitle: false,
            ),
            textTheme: TextTheme(
              headlineMedium: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              labelSmall: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: ColorPallete.green,
              ),
              bodyMedium: const TextStyle(color: Colors.white),
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: ColorPallete.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: ColorPallete.grey.withOpacity(0.6),
                  width: 1,
                ),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: ColorPallete.black,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: ColorPallete.green),
              ),
              labelStyle: const TextStyle(
                color: ColorPallete.white,
                fontSize: 14,
              ),
              hintStyle: TextStyle(color: ColorPallete.grey.withOpacity(0.5)),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: ColorPallete.green,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  String _formatRange(DateTimeRange range) {
    final start = DateFormat('d MMM', 'id_ID').format(range.start);
    final end = DateFormat('d MMM yyyy', 'id_ID').format(range.end);

    if (range.start.year == range.end.year) {
      final endNoYear = DateFormat('d MMM', 'id_ID').format(range.end);
      return '$start – $endNoYear ${range.end.year}';
    }

    return '$start – $end';
  }
}
