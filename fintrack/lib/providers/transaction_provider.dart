import 'package:flutter/material.dart';
import 'package:fintrack/features/transaction/controllers/transaction_provider.dart';
import 'package:fintrack/features/transaction/models/transaction_model.dart';

class AppTransactionProvider extends ChangeNotifier {
  final TransactionProvider _trxProvider = TransactionProvider();

  List<TransactionModel> get transactions => _trxProvider.transactions;
  double get totalIncome => _trxProvider.totalIncome;
  double get totalExpense => _trxProvider.totalExpense;
  double get totalBalance => _trxProvider.totalBalance;

  Future<void> loadLatest() async {
    await _trxProvider.loadLatest();
    notifyListeners();
  }

  Future<void> add(TransactionModel trx) async {
    await _trxProvider.add(trx);
    notifyListeners();
  }

  Future<void> remove(String id) async {
    await _trxProvider.remove(id);
    notifyListeners();
  }
}
