import 'package:fintrack/features/budget/services/budget_service.dart';
import 'package:fintrack/features/budget/model/budget_model.dart';
import 'package:flutter/material.dart';

class BudgetProvider with ChangeNotifier {
  final BudgetService _service = BudgetService();

  List<BudgetModel> _budgets = [];
  List<BudgetModel> get budgets => _budgets;

  Future<void> loadBudgets() async {
    _budgets = await _service.getBudgets();
    notifyListeners();
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
      await loadBudgets();
    }
  }
}