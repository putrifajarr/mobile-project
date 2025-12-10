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
    // Find active budgets for this category
    final now = DateTime.now();
    final activeBudgets = _budgets.where((b) {
      return b.kategori == category &&
          now.isAfter(b.tanggalMulai) &&
          now.isBefore(b.tanggalAkhir);
    }).toList();

    for (var b in activeBudgets) {
      final used = b.totalDipakai;
      final limit = b.jumlahAnggaran;
      final ratio = used / limit;

      // Trigger 1: WARNING (>= 80%)
      if (ratio >= 0.8 && !b.notif90Sent) {
        await _notificationService.showNotification(
          id: b.id.hashCode,
          title: "Peringatan Anggaran: ${b.kategori}",
          body:
              "Anda telah menggunakan ${(ratio * 100).toStringAsFixed(0)}% dari limit anggaran.",
        );
        await _service.updateNotificationStatus(b.id, 'notif_90_sent', true);
      }

      // Trigger 2: EXCEEDED (> 100%)
      if (used > limit && !b.notif100Sent) {
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

  Future<void> updateBudget(BudgetModel budget) async {
    final success = await _service.updateBudget(budget);
    if (success) {
      await loadBudgets();
    }
  }

  Future<void> deleteBudget(String id) async {
    final success = await _service.deleteBudget(id);
    if (success) {
      _budgets.removeWhere((element) => element.id == id);
      notifyListeners();
    }
  }

  void resetState() {
    _budgets = [];
    print("DEBUG: BudgetProvider state reset.");
    notifyListeners();
  }
}
