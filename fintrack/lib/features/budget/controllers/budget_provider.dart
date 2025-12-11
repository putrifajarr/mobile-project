import 'package:fintrack/features/budget/services/budget_service.dart';
import 'package:fintrack/features/budget/model/budget_model.dart';
import 'package:fintrack/services/notification_service.dart';
import 'package:flutter/material.dart';

class BudgetProvider with ChangeNotifier {
  final BudgetService _service = BudgetService();
  final NotificationService _notificationService = NotificationService();

  List<BudgetModel> _budgets = [];
  List<BudgetModel> get budgets => _budgets;

  Future<void> loadBudgets() async {
    _budgets = await _service.getBudgets();
    notifyListeners();
  }

  // Initialize Check on App Startup
  Future<void> initializeBudgetChecks() async {
    await loadBudgets();
    final newBudgets = await _service.checkAndRolloverBudgets();

    if (newBudgets.isNotEmpty) {
      for (var b in newBudgets) {
        await _notificationService.showNotification(
          id: b.id.hashCode,
          title: "Pergantian Periode Anggaran",
          body:
              "Periode anggaran ${b.kategori} Anda sudah selesai. Periode baru sudah dimulai.",
        );
      }
      await loadBudgets(); // Reload to see new rows
    }
  }

  // Called whenever a transaction is added
  Future<void> checkBudgetHealth(String category, double newAmount) async {
    print(
      "DEBUG: checkBudgetHealth called for $category with amount $newAmount",
    );

    // Find active budgets for this category
    final now = DateTime.now();
    final activeBudgets = _budgets.where((b) {
      return b.kategori == category &&
          now.isAfter(b.tanggalMulai) &&
          now.isBefore(b.tanggalAkhir);
    }).toList();

    print("DEBUG: Found ${activeBudgets.length} active budgets for $category");

    for (var b in activeBudgets) {
      // CRITICAL FIX: Calculate total used including the NEW transaction
      // because _budgets list might be stale until next reload.
      final currentUsed = b.totalDipakai + newAmount;
      final limit = b.jumlahAnggaran;
      final ratio = currentUsed / limit;

      print(
        "DEBUG: Budget '${b.nama}' - Used: $currentUsed / $limit (Ratio: ${(ratio * 100).toStringAsFixed(1)}%)",
      );
      print("DEBUG: Flags - 90: ${b.notif90Sent}, 100: ${b.notif100Sent}");

      // Trigger 1: WARNING (>= 80% to 90% logic)
      // Requirement: "Trigger Warning" when >= 90%
      if (ratio >= 0.9 && !b.notif90Sent) {
        print("DEBUG: Triggering 90% Notification!");
        await _notificationService.showNotification(
          id: b.id.hashCode,
          title: "Peringatan Anggaran: ${b.kategori}",
          body:
              "Anda telah menggunakan ${(ratio * 100).toStringAsFixed(0)}% dari limit anggaran.",
        );
        await _service.updateNotificationStatus(b.id, 'notif_90_sent', true);
      }

      // Trigger 2: EXCEEDED (> 100%)
      if (currentUsed > limit && !b.notif100Sent) {
        print("DEBUG: Triggering 100% Notification!");
        await _notificationService.showNotification(
          id: b.id.hashCode + 1, // distinct ID
          title: "Peringatan Anggaran: ${b.kategori}",
          body: "Anda telah melebihi limit anggaran!",
        );
        await _service.updateNotificationStatus(b.id, 'notif_100_sent', true);
      }
    }
  }

  Future<void> addBudget(BudgetModel budget) async {
    final success = await _service.addBudget(budget);
    if (success) {
      await loadBudgets();
    }
  }

  // <--- TAMBAHAN: UPDATE LOGIC DI PROVIDER --->
  Future<void> updateBudget(BudgetModel budget) async {
    final success = await _service.updateBudget(budget);
    if (success) {
      await loadBudgets();
    }
  }
  // <--- END TAMBAHAN --->

  Future<void> deleteBudget(String id) async {
    final success = await _service.deleteBudget(id);
    if (success) {
      // Optimistic update for UI responsiveness
      _budgets.removeWhere((element) => element.id == id);
      notifyListeners();
      await loadBudgets(); // Sync with server for consistency
    }
  }

  void resetState() {
    _budgets = [];
    print("DEBUG: BudgetProvider state reset.");
    notifyListeners();
  }
}
