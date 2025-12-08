import 'package:fintrack/core/constants/constants.dart';
import 'package:fintrack/features/budget/controllers/budget_provider.dart';

import 'package:fintrack/features/budget/model/budget_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AddBudgetPage extends StatefulWidget {
  const AddBudgetPage({super.key});

  @override
  State<AddBudgetPage> createState() => _AddBudgetPageState();
}

class _AddBudgetPageState extends State<AddBudgetPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  String? _selectedCategory;
  String _selectedRepeat = 'Bulanan';
  DateTime? _startDate;

  final currency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  final List<String> _categories = [
    "Belanja",
    "Makanan",
    "Gaji",
    "Hiburan",
    "Lainnya",
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  DateTime _computeEndDate(DateTime start, String repeat) {
    if (repeat == 'Harian') return start;
    if (repeat == 'Mingguan') return start.add(const Duration(days: 6));
    final nextMonth = DateTime(start.year, start.month + 1, start.day);
    return nextMonth;
  }

  void _pickStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: ColorPallete.green,
              onPrimary: ColorPallete.black,
              surface: ColorPallete.blackLight,
              onSurface: ColorPallete.white,
            ),
            dialogBackgroundColor: ColorPallete.blackLight,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate() || _startDate == null) {
      if (_startDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tanggal mulai wajib diisi')),
        );
      }
      return;
    }

    final name = _nameCtrl.text.trim();
    final amount =
        double.tryParse(
          _amountCtrl.text.replaceAll('.', '').replaceAll(',', ''),
        ) ??
        0;
    final category = _selectedCategory ?? _categories.first;
    final start = _startDate!;
    final end = _computeEndDate(start, _selectedRepeat);

    final model = BudgetModel(
      nama: name,
      jumlahAnggaran: amount,
      kategori: category,
      tanggalMulai: start,
      tanggalAkhir: end,
      totalDipakai: 0,
    );

    Provider.of<BudgetProvider>(context, listen: false).addBudget(model);

    Navigator.of(context).pop();
  }

  String? _validateAmount(String? v) {
    if (v == null || v.trim().isEmpty) return 'Jumlah anggaran wajib diisi';
    final digits = v.replaceAll('.', '').replaceAll(',', '');
    if (int.tryParse(digits) == null) return 'Masukkan angka valid';
    if ((int.tryParse(digits) ?? 0) <= 0) return 'Jumlah harus lebih dari 0';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Tambah Anggaran',
            style: TextStyle(
              color: ColorPallete.white,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          backgroundColor: ColorPallete.black,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: ColorPallete.white,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        backgroundColor: ColorPallete.black,
        body: Padding(
          padding: const EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: 36,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Name
                _buildRow(
                  icon: Icons.label_outline,
                  child: TextFormField(
                    controller: _nameCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Nama Anggaran'),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Nama wajib diisi'
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                // Amount
                _buildRow(
                  icon: Icons.attach_money_outlined,
                  child: TextFormField(
                    controller: _amountCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Jumlah Anggaran (Rp)'),
                    validator: _validateAmount,
                    onChanged: (v) {
                      String digits = v.replaceAll(RegExp(r'[^0-9]'), '');

                      if (digits.isEmpty) {
                        _amountCtrl.value = TextEditingValue.empty;
                        return;
                      }

                      final number = int.tryParse(digits) ?? 0;
                      final formatted = NumberFormat.decimalPattern(
                        'id_ID',
                      ).format(number);

                      if (v != formatted) {
                        _amountCtrl.value = TextEditingValue(
                          text: formatted,
                          selection: TextSelection.collapsed(
                            offset: formatted.length,
                          ),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // Category
                _buildRow(
                  icon: Icons.category_outlined,
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    items: _categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedCategory = v),
                    decoration: _inputDecoration('Kategori'),
                    dropdownColor: ColorPallete.blackLight,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Pilih kategori' : null,
                  ),
                ),
                const SizedBox(height: 16),
                // Repeat
                _buildRow(
                  icon: Icons.repeat,
                  child: DropdownButtonFormField<String>(
                    value: _selectedRepeat,
                    items: ['Harian', 'Mingguan', 'Bulanan']
                        .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _selectedRepeat = v ?? 'Bulanan'),
                    decoration: _inputDecoration('Perulangan'),
                    dropdownColor: ColorPallete.blackLight,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _pickStartDate,
                  child: _buildRow(
                    icon: Icons.calendar_today_outlined,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _startDate == null
                              ? 'Pilih Tanggal Mulai'
                              : DateFormat(
                                  'dd MMM yyyy',
                                  'id_ID',
                                ).format(_startDate!),
                          style: TextStyle(
                            color: _startDate == null
                                ? ColorPallete.grey
                                : Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: ColorPallete.grey,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 36),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _save(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorPallete.green,
                      foregroundColor: ColorPallete.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Simpan Anggaran',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow({required IconData icon, required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: ColorPallete.blackLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: ColorPallete.green),
          const SizedBox(width: 16),
          Expanded(child: child),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: ColorPallete.grey),
      border: InputBorder.none,
      isDense: true,
      contentPadding: EdgeInsets.zero,
    );
  }
}
