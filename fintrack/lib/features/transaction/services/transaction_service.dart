import 'package:fintrack/core/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TransactionService {
  SupabaseClient get supabase => SupabaseConfig.client;

  Future<bool> addTransaction({
    required String category,
    required String description,
    required double amount,
    required String type,
    required DateTime date,
  }) async {
    final userId = supabase.auth.currentUser?.id;
    print("DEBUG: addTransaction - User ID: $userId"); // DEBUG LOG
    if (userId == null) {
      print("DEBUG: addTransaction - No user logged in!");
      return false;
    }

    try {
      final response = await supabase.from('transactions').insert({
        'user_id': userId,
        'category': category,
        'description': description,
        'amount': amount,
        'type': type,
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

    final result = await supabase
        .from('transactions')
        .select()
        .eq('user_id', userId)
        .order('date', ascending: false)
        .limit(10);

    print("FETCH RESULT → $result");
    return List<Map<String, dynamic>>.from(result as List);
  }

  Future<bool> deleteTransaction(String id) async {
    final response = await supabase.from('transactions').delete().match({
      'id': id,
    });
    print(
      "DELETE RESPONSE → ${response.data}, ERROR → ${response.error?.message}",
    );
    return response.error == null;
  }

  Future<bool> updateTransaction({
    required String id,
    required String category,
    required String description,
    required double amount,
    required String type,
    required DateTime date,
  }) async {
    final response = await supabase
        .from('transactions')
        .update({
          'category': category,
          'description': description,
          'amount': amount,
          'type': type,
          'date': date.toIso8601String(),
        })
        .match({'id': id});

    print(
      "UPDATE RESPONSE → ${response.data}, ERROR → ${response.error?.message}",
    );
    return response.error == null;
  }
}
