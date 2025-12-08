import 'package:fintrack/core/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category_model.dart';

class TransactionService {
  SupabaseClient get supabase => SupabaseConfig.client;

  Future<bool> addTransaction({
    required int categoryId,
    required String description,
    required double amount,
    required DateTime date,
  }) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      print("DEBUG: addTransaction - No user logged in!");
      return false;
    }

    try {
      final response = await supabase.from('transactions').insert({
        'user_id': userId,
        'category_id': categoryId,
        'description': description,
        'amount': amount,
        'date': date.toIso8601String(),
      });

      print("DEBUG: addTransaction - Response: $response");
      return true;
    } catch (e) {
      print("DEBUG: addTransaction - Error: $e");
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getLatestTransactions() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final result = await supabase
          .from('transactions')
          .select('*, master_categories(id, name, type)')
          .eq('user_id', userId)
          .order('date', ascending: false)
          .limit(50); // Increased limit for better visibility

      // print("FETCH RESULT → $result");
      return List<Map<String, dynamic>>.from(result as List);
    } catch (e) {
      print("DEBUG: getLatestTransactions - Error: $e");
      return [];
    }
  }

  Future<bool> deleteTransaction(String id) async {
    try {
      await supabase.from('transactions').delete().match({'id': id});
      return true;
    } catch (e) {
      print("DEBUG: deleteTransaction - Error: $e");
      return false;
    }
  }

  Future<bool> updateTransaction({
    required String id,
    required int categoryId,
    required String description,
    required double amount,
    required DateTime date,
  }) async {
    try {
      await supabase
          .from('transactions')
          .update({
            'category_id': categoryId,
            'description': description,
            'amount': amount,
            'date': date.toIso8601String(),
          })
          .match({'id': id});
      return true;
    } catch (e) {
      print("DEBUG: updateTransaction - Error: $e");
      return false;
    }
  }

  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await supabase.from('master_categories').select();
      final data = List<Map<String, dynamic>>.from(response as List);
      return data.map((json) => CategoryModel.fromJson(json)).toList();
    } catch (e) {
      print("DEBUG: getCategories - Error: $e");
      return [];
    }
  }
}
