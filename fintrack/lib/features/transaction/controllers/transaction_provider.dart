import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../services/transaction_service.dart';

class TransactionProvider with ChangeNotifier {
  final TransactionService _service = TransactionService();

  List<TransactionModel> _transactions = [];
  List<TransactionModel> get transactions => _transactions;

  List<CategoryModel> _categories = [];
  List<CategoryModel> get categories => _categories;

  List<CategoryModel> get incomeCategories =>
      _categories.where((c) => c.type == 'income').toList();

  List<CategoryModel> get expenseCategories =>
      _categories.where((c) => c.type == 'expense').toList();

  /// LOAD DATA DARI SUPABASE
  Future<void> loadLatest() async {
    final data = await _service.getLatestTransactions();
    _transactions = data.map((e) => TransactionModel.fromJson(e)).toList();
    _transactions.sort((a, b) {
      final dateComparison = b.date.compareTo(a.date);
      if (dateComparison != 0) {
        return dateComparison;
      }
      return b.createdAt.compareTo(a.createdAt);
    });
    notifyListeners();
  }

  Future<void> loadCategories() async {
    _categories = await _service.getCategories();
    notifyListeners();
  }

  /// TAMBAH TRANSAKSI
  Future<void> add(TransactionModel trx) async {
    print("DEBUG: Provider adding transaction...");
    final success = await _service.addTransaction(
      categoryId: trx.categoryId,
      description: trx.description,
      amount: trx.amount,
      date: trx.date,
    );
    print("DEBUG: Provider add result: $success");

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
      categoryId: trx.categoryId,
      description: trx.description,
      amount: trx.amount,
      date: trx.date,
    );

    if (success) {
      await loadLatest();
    }
  }

  double get totalIncome => _transactions
      .where((t) => t.category?.type == "income")
      .fold(0, (s, t) => s + t.amount);

  double get totalExpense => _transactions
      .where((t) => t.category?.type == "expense")
      .fold(0, (s, t) => s + t.amount);

  double get totalBalance => totalIncome - totalExpense;

  void resetState() {
    _transactions = [];
    _categories = [];
    print("DEBUG: TransactionProvider state reset.");
    notifyListeners();
  }
}
