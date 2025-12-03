import 'package:fintrack/constants/constants.dart';
import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final String message;
  final VoidCallback? onAction;
  final String actionLabel;

  const EmptyState({
    super.key,
    this.message = 'Belum ada transaksi untuk ditampilkan.',
    this.onAction,
    this.actionLabel = 'Bersihkan Filter',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 72, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text(
              'Transaksi tidak ditemukan',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
              textAlign: TextAlign.center,
            ),
            if (onAction != null) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorPallete.green,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                    ),
                    onPressed: onAction,
                    child: Text(actionLabel),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
