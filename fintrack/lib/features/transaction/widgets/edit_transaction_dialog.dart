import 'package:fintrack/features/transaction/controllers/transaction_provider.dart';
import 'package:fintrack/features/transaction/models/transaction_model.dart';
import 'package:flutter/material.dart';

class EditTransactionDialog extends StatelessWidget {
  final TransactionModel transaction;
  final TransactionProvider provider;

  const EditTransactionDialog({
    super.key,
    required this.transaction,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final amountController = TextEditingController(
      text: transaction.amount.toString(),
    );
    final descriptionController = TextEditingController(
      text: transaction.description,
    );
    final categoryController = TextEditingController(
      text: transaction.category,
    );
    String type = transaction.type;

    return _EditTransactionDialogContent(
      transaction: transaction,
      provider: provider,
      amountController: amountController,
      descriptionController: descriptionController,
      categoryController: categoryController,
      initialType: type,
    );
  }
}

class _EditTransactionDialogContent extends StatefulWidget {
  final TransactionModel transaction;
  final TransactionProvider provider;
  final TextEditingController amountController;
  final TextEditingController descriptionController;
  final TextEditingController categoryController;
  final String initialType;

  const _EditTransactionDialogContent({
    required this.transaction,
    required this.provider,
    required this.amountController,
    required this.descriptionController,
    required this.categoryController,
    required this.initialType,
  });

  @override
  State<_EditTransactionDialogContent> createState() =>
      _EditTransactionDialogContentState();
}

class _EditTransactionDialogContentState
    extends State<_EditTransactionDialogContent> {
  late String type;

  @override
  void initState() {
    super.initState();
    type = widget.initialType;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit Transaksi"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: widget.amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Jumlah"),
            ),
            TextField(
              controller: widget.descriptionController,
              decoration: const InputDecoration(labelText: "Deskripsi"),
            ),
            DropdownButtonFormField<String>(
              value: widget.categoryController.text.isNotEmpty
                  ? widget.categoryController.text
                  : null,
              decoration: const InputDecoration(labelText: "Kategori"),
              items: ["Belanja", "Makanan", "Gaji", "Hiburan", "Lainnya"].map((
                kategori,
              ) {
                return DropdownMenuItem(value: kategori, child: Text(kategori));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  widget.categoryController.text = value;
                }
              },
            ),
            DropdownButton<String>(
              value: type,
              items: const [
                DropdownMenuItem(value: "income", child: Text("Pendapatan")),
                DropdownMenuItem(value: "expense", child: Text("Pengeluaran")),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    type = value;
                  });
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Batal"),
        ),
        ElevatedButton(
          onPressed: () {
            final updateTransaction = TransactionModel(
              id: widget.transaction.id,
              type: type,
              date: widget.transaction.date,
              amount:
                  double.tryParse(widget.amountController.text) ??
                  widget.transaction.amount,
              description: widget.descriptionController.text,
              category: widget.categoryController.text,
            );
            widget.provider.updateTransaction(updateTransaction);
            Navigator.pop(context);
          },
          child: const Text("Simpan"),
        ),
      ],
    );
  }
}

void showEditTransactionDialog(
  BuildContext context,
  TransactionModel transaction,
  TransactionProvider provider,
) {
  showDialog(
    context: context,
    builder: (context) =>
        EditTransactionDialog(transaction: transaction, provider: provider),
  );
}
