import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/transaction_service.dart';

class TransactionProvider with ChangeNotifier {
  final TransactionService _service = TransactionService();

  List<TransactionModel> _transactions = [];
  List<TransactionModel> get transactions => _transactions;

  /// LOAD DATA DARI SUPABASE
  Future<void> loadLatest() async {
    final data = await _service.getLatestTransactions();
    _transactions = data.map((e) => TransactionModel.fromJson(e)).toList();
    _transactions.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  /// TAMBAH TRANSAKSI
  Future<void> add(TransactionModel trx) async {
    final success = await _service.addTransaction(
      category: trx.category,
      description: trx.description,
      amount: trx.amount,
      type: trx.type,
    );

    if (success) {
      await loadLatest();
    }
  }

  /// DELETE TRANSAKSI
  Future<void> deleteTransaction(String id) async {
    await _service.deleteTransaction(id);
    await loadLatest();
  }

  /// UPDATE TRANSAKSI
  Future<void> updateTransaction(TransactionModel trx) async {
    final success = await _service.updateTransaction(
      id: trx.id,
      category: trx.category,
      description: trx.description,
      amount: trx.amount,
      type: trx.type,
      date: trx.date,
    );

    if (success) {
      await loadLatest();
    }
  }

  Future<void> updateBudgetFromTransaction(TransactionModel trx) async {
    // TODO: Implement budget update logic
  }

  double get totalIncome => _transactions
      .where((t) => t.type == "income")
      .fold(0, (s, t) => s + t.amount);

  double get totalExpense => _transactions
      .where((t) => t.type == "expense")
      .fold(0, (s, t) => s + t.amount);

  double get totalBalance => totalIncome - totalExpense;
}
