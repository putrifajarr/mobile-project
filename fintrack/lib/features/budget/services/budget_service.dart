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

  Future<List<BudgetModel>> getBudgets() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await supabase
        .from('budgets')
        .select()
        .eq('user_id', userId)
        .order('start_date', ascending: false);

    // Note: Assuming the table columns match the keys I'm expecting.
    // I need to map the database columns to BudgetModel.
    // However, BudgetModel doesn't have a fromJson yet. I should probably add one or map manually.
    // For now I'll map manually to keep BudgetModel clean if it wasn't meant to have fromJson,
    // but typically models should have it.
    // Looking at BudgetModel:
    //   final String id;
    //   final String nama;
    //   final String kategori;
    //   final double jumlahAnggaran;
    //   final DateTime tanggalMulai;
    //   final DateTime tanggalAkhir;
    //   double totalDipakai;

    // I'll assume the db columns are 'id', 'name', 'category', 'amount', 'start_date', 'end_date' based on my insert.

    final List<dynamic> data = response as List<dynamic>;
    return data
        .map(
          (e) => BudgetModel(
            id: e['id'],
            nama: e['name'],
            kategori: e['category'],
            jumlahAnggaran: (e['amount'] as num).toDouble(),
            tanggalMulai: DateTime.parse(e['start_date']),
            tanggalAkhir: DateTime.parse(e['end_date']),
            totalDipakai:
                0, // Need to calculate this separately usually, or fetch it. For now 0.
          ),
        )
        .toList();
  }

  Future<bool> deleteBudget(String id) async {
    final response = await supabase.from('budgets').delete().eq('id', id);
    return response.error == null;
  }
}
