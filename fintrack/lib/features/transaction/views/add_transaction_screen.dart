import 'package:flutter/material.dart';
import 'package:fintrack/features/transaction/controllers/transaction_provider.dart';
import 'package:fintrack/features/transaction/models/transaction_model.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

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
  String selectedCategory = "Belanja";

  @override
  void initState() {
    super.initState();

    // Jika mode EDIT → preload data
    if (widget.isEdit && widget.existing != null) {
      selectedType = widget.existing!.type;
      selectedDate = widget.existing!.date;
      amountController.text = widget.existing!.amount.toString();
      descController.text = widget.existing!.description;
      selectedCategory = widget.existing!.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? "Edit Transaksi" : "Tambah Transaksi"),
        backgroundColor: Colors.green[700],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [

            Row(
              children: [
                _typeChip("income", "Pemasukan"),
                const SizedBox(width: 8),
                _typeChip("expense", "Pengeluaran"),
              ],
            ),

            const SizedBox(height: 20),

            ListTile(
              title: const Text("Tanggal"),
              subtitle: Text("${selectedDate.toLocal()}".split(" ")[0]),
              trailing: const Icon(Icons.calendar_month),
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (picked != null) {
                  setState(() => selectedDate = picked);
                }
              },
            ),

            const SizedBox(height: 16),

            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Jumlah",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: "Keterangan",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField(
              value: selectedCategory,
              items: ["Belanja", "Makanan", "Gaji", "Hiburan", "Lainnya"]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              decoration: const InputDecoration(
                labelText: "Kategori",
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => selectedCategory = v!),
            ),

            const SizedBox(height: 28),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () => _save(context),
              child: Text(widget.isEdit ? "Simpan Perubahan" : "Tambah"),
            )
          ],
        ),
      ),
    );
  }

  Widget _typeChip(String value, String label) {
    return ChoiceChip(
      label: Text(label),
      selected: selectedType == value,
      selectedColor: Colors.green,
      onSelected: (_) => setState(() => selectedType = value),
    );
  }

  /// SIMPAN KE SUPABASE
  void _save(BuildContext context) async {
  final provider = Provider.of<TransactionProvider>(context, listen: false);

  final trx = TransactionModel(
    id: widget.isEdit ? widget.existing!.id : const Uuid().v4(),
    type: selectedType,
    date: selectedDate,
    amount: double.tryParse(amountController.text) ?? 0,
    description: descController.text,
    category: selectedCategory,
  );

  // =================== MODE EDIT (belum dibuat) ===================
  if (widget.isEdit) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Fitur EDIT belum diimplementasi")),
    );
    return;
  }

  // =================== MODE TAMBAH ===================
  await provider.add(trx);

  // Context digunakan setelah await → harus `if (mounted)` DULU
  if (!mounted) return;
  provider.loadLatest();
  Navigator.of(context).pop();
  }



}
