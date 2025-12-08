import 'package:fintrack/core/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:fintrack/features/transaction/controllers/transaction_provider.dart';
import 'package:fintrack/features/transaction/models/transaction_model.dart';
import 'package:fintrack/features/transaction/models/category_model.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class AddTransactionScreen extends StatefulWidget {
  final bool isEdit;
  final TransactionModel? existing;

  const AddTransactionScreen({super.key, this.isEdit = false, this.existing});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  String selectedType = "expense";
  DateTime selectedDate = DateTime.now();
  final amountController = TextEditingController();
  final descController = TextEditingController();
  CategoryModel? selectedCategory;

  @override
  void initState() {
    super.initState();

    // Load categories first
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Provider.of<TransactionProvider>(
        context,
        listen: false,
      ).loadCategories();
      _initializeFields();
    });
  }

  void _initializeFields() {
    if (widget.isEdit && widget.existing != null) {
      final existing = widget.existing!;
      final provider = Provider.of<TransactionProvider>(context, listen: false);

      // Determine type based on category type if possible, or fallback
      // Note: Logic assumes category object exists on existing model
      if (existing.category != null) {
        selectedType = existing.category!.type;
        // Find matching category object reference from provider list to ensure equality works
        try {
          selectedCategory = provider.categories.firstWhere(
            (c) => c.id == existing.categoryId,
          );
        } catch (_) {
          // If not found (shouldn't happen if logical integrity exists), keep null
        }
      }

      selectedDate = existing.date;
      amountController.text = NumberFormat.decimalPattern(
        'id_ID',
      ).format(existing.amount.toInt());
      descController.text = existing.description;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    // Filter categories based on selected type
    final List<CategoryModel> visibleCategories = selectedType == 'income'
        ? provider.incomeCategories
        : provider.expenseCategories;

    // Reset selectedCategory if it doesn't match the new type (unless it's null)
    if (selectedCategory != null && selectedCategory!.type != selectedType) {
      selectedCategory = null;
    }

    return Scaffold(
      backgroundColor: ColorPallete.black,
      appBar: AppBar(
        backgroundColor: ColorPallete.black,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: ColorPallete.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isEdit ? "Edit Transaksi" : "Tambah Transaksi",
          style: const TextStyle(
            color: ColorPallete.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: ColorPallete.blackLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(child: _typeButton("income", "Pemasukan")),
                  Expanded(child: _typeButton("expense", "Pengeluaran")),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              "Tanggal",
              style: TextStyle(
                color: ColorPallete.grey,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                  builder: (context, child) {
                    return Theme(
                      data: ThemeData.dark().copyWith(
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
                  setState(() => selectedDate = picked);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ColorPallete.blackLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: ColorPallete.green,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat(
                        'EEEE, d MMMM yyyy',
                        'id_ID',
                      ).format(selectedDate),
                      style: const TextStyle(
                        color: ColorPallete.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Jumlah",
              style: TextStyle(
                color: ColorPallete.grey,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            _customTextField(
              controller: amountController,
              hint: "0",
              keyboardType: TextInputType.number,
              prefix: const Text(
                "Rp ",
                style: TextStyle(
                  color: ColorPallete.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onChanged: (v) {
                // Remove all non-digit characters
                String digits = v.replaceAll(RegExp(r'[^0-9]'), '');

                if (digits.isEmpty) {
                  amountController.value = TextEditingValue.empty;
                  return;
                }

                // Parse and format
                final number = int.tryParse(digits) ?? 0;
                final formatted = NumberFormat.decimalPattern(
                  'id_ID',
                ).format(number);

                if (v != formatted) {
                  amountController.value = TextEditingValue(
                    text: formatted,
                    selection: TextSelection.collapsed(
                      offset: formatted.length,
                    ),
                  );
                }
              },
            ),

            const SizedBox(height: 20),

            const Text(
              "Kategori",
              style: TextStyle(
                color: ColorPallete.grey,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: ColorPallete.blackLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<CategoryModel>(
                  value: selectedCategory,
                  dropdownColor: ColorPallete.blackLight,
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: ColorPallete.grey,
                  ),
                  hint: Text(
                    "Pilih Kategori",
                    style: TextStyle(color: ColorPallete.grey),
                  ),
                  isExpanded: true,
                  style: const TextStyle(
                    color: ColorPallete.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  items: visibleCategories
                      .map(
                        (e) => DropdownMenuItem(value: e, child: Text(e.name)),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => selectedCategory = v),
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Keterangan",
              style: TextStyle(
                color: ColorPallete.grey,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            _customTextField(
              controller: descController,
              hint: "Tulis keterangan...",
              maxLines: 3,
            ),

            const SizedBox(height: 36),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorPallete.green,
                  foregroundColor: ColorPallete.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                onPressed: () => _save(context),
                child: Text(
                  widget.isEdit ? "Simpan Perubahan" : "Simpan Transaksi",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeButton(String value, String label) {
    bool isSelected = selectedType == value;

    final Color activeColor = value == "expense"
        ? Colors.red
        : ColorPallete.green;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedType = value;
          selectedCategory = null; // Reset category when type changes
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? (value == "expense" ? Colors.white : ColorPallete.black)
                : ColorPallete.grey,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _customTextField({
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
    Widget? prefix,
    int maxLines = 1,
    void Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
      style: const TextStyle(color: ColorPallete.white, fontSize: 16),
      decoration: InputDecoration(
        filled: true,
        fillColor: ColorPallete.blackLight,
        hintText: hint,
        hintStyle: const TextStyle(color: ColorPallete.grey),
        prefixIcon: prefix != null
            ? Padding(
                padding: const EdgeInsets.only(left: 16, right: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [prefix],
                ),
              )
            : null,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: ColorPallete.green, width: 1),
        ),
      ),
    );
  }

  void _save(BuildContext context) async {
    if (amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Jumlah tidak boleh kosong",
            style: TextStyle(color: ColorPallete.white),
          ),
          backgroundColor: const Color(0xFFFF5145),
        ),
      );
      return;
    }

    if (selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Pilih kategori terlebih dahulu",
            style: TextStyle(color: ColorPallete.white),
          ),
          backgroundColor: const Color(0xFFFF5145),
        ),
      );
      return;
    }

    final provider = Provider.of<TransactionProvider>(context, listen: false);

    // Create a temporary model object.
    // Note: userId and createdAt are placeholders as they will be handled/ignored by the service/provider for creation.
    final trx = TransactionModel(
      id: widget.isEdit ? widget.existing!.id : const Uuid().v4(),
      userId: '', // Placeholder
      categoryId: selectedCategory!.id,
      amount:
          double.tryParse(
            amountController.text.replaceAll('.', '').replaceAll(',', ''),
          ) ??
          0,
      description: descController.text,
      date: selectedDate,
      createdAt: DateTime.now(), // Placeholder
    );

    if (widget.isEdit) {
      await provider.updateTransaction(trx);
    } else {
      await provider.add(trx);
      // await provider.updateBudgetFromTransaction(trx); // Removed as it wasn't implemented yet
    }

    if (!context.mounted) return;
    Navigator.pop(context);
  }
}
