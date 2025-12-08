import 'package:fintrack/core/constants/constants.dart';
import 'package:fintrack/features/transaction/models/transaction_model.dart';
import 'package:fintrack/core/utils/format_rupiah.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

class HistoryItem extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const HistoryItem({
    super.key,
    required this.transaction,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.category?.type == 'expense';
    final color = isExpense ? ColorPallete.red : ColorPallete.green;
    final bool hasDescription = transaction.description.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: Slidable(
        key: ValueKey(transaction.hashCode),

        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.5,
          children: [
            if (onEdit != null)
              SlidableAction(
                onPressed: (context) => onEdit!(),
                backgroundColor: const Color.fromARGB(255, 38, 38, 38),
                foregroundColor: ColorPallete.blue,
                icon: Icons.edit,
                label: 'Edit',
              ),

            if (onDelete != null)
              SlidableAction(
                onPressed: (context) => onDelete!(),
                backgroundColor: const Color.fromARGB(255, 38, 38, 38),
                foregroundColor: ColorPallete.red,
                icon: Icons.delete,
                label: 'Hapus',
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
          ],
        ),

        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 31, 31, 31),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ColorPallete.blackLight),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      transaction.category?.name ?? 'Umum',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (hasDescription) ...[
                      const SizedBox(height: 8),
                      Text(
                        transaction.description,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 12),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    formatRupiah(transaction.amount),
                    style: TextStyle(
                      color: color,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('dd MMM yyyy').format(transaction.date),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
