import 'package:fintrack/core/constants/constants.dart';
import 'package:fintrack/features/budget/controllers/budget_provider.dart';
import 'package:fintrack/features/transaction/controllers/transaction_provider.dart';
import 'package:fintrack/features/budget/model/budget_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AddBudgetPage extends StatefulWidget {
  final BudgetModel? existingBudget;
  const AddBudgetPage({super.key, this.existingBudget});

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

  bool get _isEditMode => widget.existingBudget != null;

  final currency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  
  @override
  void initState() {
    super.initState();
    
    // Pastikan kategori dimuat saat halaman dibuat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().loadCategories(); 
      
      if (_isEditMode) {
        final budget = widget.existingBudget!;
        _nameCtrl.text = budget.nama;
        _selectedCategory = budget.kategori;
        _startDate = budget.tanggalMulai;
        _selectedRepeat = _getRepeatFromDates(
            budget.tanggalMulai, budget.tanggalAkhir);

        final formattedAmount =
            NumberFormat.decimalPattern('id_ID').format(budget.jumlahAnggaran.toInt());
        _amountCtrl.text = formattedAmount;
      }
      setState(() {});
    });
  }

  String _getRepeatFromDates(DateTime start, DateTime end) {
    final diff = end.difference(start).inDays;
    if (diff == 0) return 'Harian';
    if (diff == 6) return 'Mingguan';
    // Gunakan logika perhitungan yang sama untuk memastikan konsistensi
    final expectedMonthlyEnd = DateTime(start.year, start.month + 1, start.day).subtract(const Duration(days: 1));
    if (end.year == expectedMonthlyEnd.year && end.month == expectedMonthlyEnd.month && end.day == expectedMonthlyEnd.day) return 'Bulanan';
    return 'Bulanan'; // Default
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  // <--- PERBAIKAN LOGIKA TANGGAL AKHIR DI SINI --->
  DateTime _computeEndDate(DateTime start, String repeat) {
    if (repeat == 'Harian') {
      return start;
    }
    if (repeat == 'Mingguan') {
      // Berakhir 6 hari setelah hari mulai (total 7 hari)
      return start.add(const Duration(days: 6)); 
    }
    
    // Bulanan: Berakhir satu hari sebelum tanggal yang sama di bulan berikutnya.
    // Ini menangani kasus akhir bulan secara otomatis (misal 31 Jan berakhir 28/29 Feb).
    final nextCycleStart = DateTime(start.year, start.month + 1, start.day);
    return nextCycleStart.subtract(const Duration(days: 1));
  }
  // <--- END PERBAIKAN LOGIKA TANGGAL AKHIR --->

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
    
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
    final expenseCategoryNames = transactionProvider.expenseCategories.map((c) => c.name).toList();

    final name = _nameCtrl.text.trim();
    final amount =
        double.tryParse(
          _amountCtrl.text.replaceAll('.', '').replaceAll(',', ''),
        ) ??
        0;
        
    final category = _selectedCategory ?? (expenseCategoryNames.isNotEmpty ? expenseCategoryNames.first : '');
    
    if (category.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tidak ada kategori Pengeluaran yang tersedia')),
        );
        return;
    }

    final start = _startDate!;
    final end = _computeEndDate(start, _selectedRepeat);

    final model = BudgetModel(
      id: _isEditMode ? widget.existingBudget!.id : null, 
      nama: name,
      jumlahAnggaran: amount,
      kategori: category,
      tanggalMulai: start,
      tanggalAkhir: end,
      totalDipakai: widget.existingBudget?.totalDipakai ?? 0, 
    );

    final provider = Provider.of<BudgetProvider>(context, listen: false);

    if (_isEditMode) {
      provider.updateBudget(model); 
    } else {
      provider.addBudget(model);
    }

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
    final transactionProvider = context.watch<TransactionProvider>(); 
    final expenseCategoryNames = transactionProvider.expenseCategories.map((c) => c.name).toList();
    
    if (_selectedCategory == null && expenseCategoryNames.isNotEmpty) {
      _selectedCategory = expenseCategoryNames.first;
    }

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text(
            _isEditMode ? 'Edit Anggaran' : 'Tambah Anggaran',
            style: const TextStyle(
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
        body: SingleChildScrollView(
          child: Padding(
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
                      items: expenseCategoryNames
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
                      child: Text(
                        _isEditMode ? 'Simpan Perubahan' : 'Simpan Anggaran',
                        style: const TextStyle(
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