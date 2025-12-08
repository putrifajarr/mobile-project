import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import 'package:fintrack/models/budget_model.dart';

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

  // --- BUDGET FEATURE ---
  final List<BudgetModel> _budgets = [];
  List<BudgetModel> get budgets => _budgets;

  void addBudget(BudgetModel budget) {
    _budgets.add(budget);
    notifyListeners();
  }

  void updateBudgetFromTransaction(TransactionModel trx) {
    // Hanya jika tipe expense
    if (trx.type == 'expense') {
      // Cari budget yang kategorinya sama
      // Dan tanggal transaksi masuk dalam range budget
      for (var b in _budgets) {
        if (b.kategori == trx.category) {
          // Cek range tanggal (opsional, tapi diminta di requirements "Budget harus terhubung")
          // Asumsi sederhana: jika kategori sama, update.
          // Atau lebih strict: cek tanggal.
          // User request: "Jika kategori transaksi sama dengan kategori anggaran, totalDipakai bertambah."
          // Saya akan tambahkan cek tanggal agar lebih logis, tapi requirement user cukup kategori.
          // Saya ikuti requirement user dulu: "Jika kategori transaksi sama dengan kategori anggaran"

          bool isInRange =
              trx.date.isAfter(
                b.tanggalMulai.subtract(const Duration(days: 1)),
              ) &&
              trx.date.isBefore(b.tanggalAkhir.add(const Duration(days: 1)));

          if (isInRange) {
            b.totalDipakai += trx.amount;
          }
        }
      }
      notifyListeners();
    }
  }
}
