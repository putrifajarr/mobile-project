import 'package:fintrack/core/supabase_config.dart';
import 'package:fintrack/features/budget/model/budget_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BudgetService {
  SupabaseClient get supabase => SupabaseConfig.client;

  Future<bool> addBudget(BudgetModel budget) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return false;

    final response = await supabase.from('budgets').insert({
      'user_id': userId,
      'name': budget.nama,
      'category': budget.kategori,
      'amount': budget.jumlahAnggaran,
      'start_date': budget.tanggalMulai.toIso8601String(),
      'end_date': budget.tanggalAkhir.toIso8601String(),
    });

    if (response.error != null) {
      return false;
    }
    return true;
  }

  // <--- TAMBAHAN UNTUK UPDATE --->
  Future<bool> updateBudget(BudgetModel budget) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return false;

    try {
      // Melakukan UPDATE ke tabel 'budgets'
      await supabase.from('budgets').update({
        'name': budget.nama,
        'category': budget.kategori,
        'amount': budget.jumlahAnggaran,
        'start_date': budget.tanggalMulai.toIso8601String(),
        'end_date': budget.tanggalAkhir.toIso8601String(),
      }).match({
        'id': budget.id,
        'user_id': userId, // Memastikan hanya user yang bersangkutan yang bisa update
      });
      return true;
    } catch (e) {
      print("DEBUG: updateBudget - Error: $e");
      return false;
    }
  }

  // <--- FUNGSI PEMBANTU UNTUK MENGHITUNG TOTAL DIPAKAI --->
  Future<double> _calculateTotalSpent(
      String categoryName, DateTime start, DateTime end) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return 0.0;

    try {
      // 1. Cari ID kategori berdasarkan nama dan pastikan tipenya 'expense'
      final categoryResponse = await supabase
          .from('master_categories')
          .select('id')
          .eq('name', categoryName)
          .eq('type', 'expense')
          .maybeSingle();

      if (categoryResponse == null) return 0.0;
      final categoryId = categoryResponse['id'];

      // 2. Jumlahkan transaksi yang cocok dalam rentang waktu
      final transactionResponse = await supabase
          .from('transactions')
          .select('amount')
          .eq('user_id', userId)
          .eq('category_id', categoryId)
          .gte('date', start.toIso8601String())
          .lte('date', end.toIso8601String());

      if (transactionResponse.isEmpty) return 0.0;

      final List<dynamic> data = transactionResponse as List<dynamic>;
      final total = data.fold<double>(
        0.0,
        (sum, item) => sum + (item['amount'] as num).toDouble(),
      );
      return total;
    } catch (e) {
      print("DEBUG: _calculateTotalSpent - Error: $e");
      return 0.0;
    }
  }

  // <--- MODIFIKASI: getBudgets sekarang menghitung totalDipakai --->
  Future<List<BudgetModel>> getBudgets() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await supabase
        .from('budgets')
        .select()
        .eq('user_id', userId)
        .order('start_date', ascending: false);

    final List<dynamic> rawData = response as List<dynamic>;
    final List<BudgetModel> budgets = [];

    // Proses setiap anggaran secara asinkron
    for (var e in rawData) {
      final budgetModel = BudgetModel(
        id: e['id'],
        nama: e['name'],
        kategori: e['category'],
        jumlahAnggaran: (e['amount'] as num).toDouble(),
        tanggalMulai: DateTime.parse(e['start_date']),
        tanggalAkhir: DateTime.parse(e['end_date']),
        totalDipakai: 0, 
      );

      // Panggil fungsi hitung untuk mendapatkan total pengeluaran
      final spent = await _calculateTotalSpent(
        budgetModel.kategori,
        budgetModel.tanggalMulai,
        budgetModel.tanggalAkhir,
      );
      
      // Update nilai totalDipakai sebelum ditambahkan ke list
      budgetModel.totalDipakai = spent;
      budgets.add(budgetModel);
    }

    return budgets;
  }

  Future<bool> deleteBudget(String id) async {
    final response = await supabase.from('budgets').delete().eq('id', id);
    return response.error == null;
  }
}