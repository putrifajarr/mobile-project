import 'package:flutter/material.dart';
import '../models/transaction_model.dart';

class TransactionProvider with ChangeNotifier {
  final List<TransactionModel> _transactions = [];

  List<TransactionModel> get transactions => _transactions;

  // Total pemasukan
  double get totalIncome {
    return _transactions
        .where((t) => t.type == 'income')
        .fold(0, (sum, t) => sum + t.amount);
  }

  // Total pengeluaran
  double get totalExpense {
    return _transactions
        .where((t) => t.type == 'expense')
        .fold(0, (sum, t) => sum + t.amount);
  }

  // Total saldo
  double get totalBalance {
    return totalIncome - totalExpense;
  }

  // CREATE
  void addTransaction(TransactionModel trx) {
    _transactions.add(trx);
    notifyListeners();
  }

  // UPDATE
  void updateTransaction(TransactionModel trx) {
    int index = _transactions.indexWhere((t) => t.id == trx.id);
    if (index != -1) {
      _transactions[index] = trx;
      notifyListeners();
    }
  }

  // DELETE
  void deleteTransaction(String id) {
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
  }
}
