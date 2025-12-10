import 'package:fintrack/core/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';
import 'dart:convert'; // Wajib untuk encode payload JSON

class TransactionService {
  SupabaseClient get supabase => SupabaseConfig.client;

  // Kunci Service Role Anda (wajib untuk memanggil Edge Function)
  static const _serviceRoleKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZxZ3BsbHJscmRvd2h6bHNtZWx5Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2NDU5MzMxNCwiZXhwIjoyMDgwMTY5MzE0fQ.ShnlHUeQHP35h8yA5SoFOjxH1KLNfze13iBwbl5kgD8';
  
  // <--- FUNGSI NOTIFIKASI BARU: Dipanggil ASYNC setelah INSERT berhasil --->
  Future<void> _notifyRealtime(Map<String, dynamic> newRecord) async {
    final payload = jsonEncode({
      'table': 'transactions',
      'type': 'INSERT',
      'record': newRecord,
      'user_id': newRecord['user_id'],
    });

    try {
      // Memanggil Edge Function melalui Supabase Client (Cara Paling Andal)
      await supabase.functions.invoke('realtime-notify',
        body: payload,
        headers: {
          'Authorization': 'Bearer $_serviceRoleKey',
          'Content-Type': 'application/json',
        },
      );
      print("DEBUG: Edge Function realtime-notify dipanggil dari client.");
    } catch (e) {
      print("DEBUG: Gagal memanggil Edge Function dari client: $e");
    }
  }


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
    
    // VERIFIKASI USER ID (User Request)
    print("DEBUG: addTransaction - Auth Check: CurrentUser.id = $userId");
    print("DEBUG: addTransaction - Payload user_id = $userId");


    final dataToInsert = {
      'user_id': userId,
      'category_id': categoryId,
      'description': description,
      'amount': amount,
      'date': date.toIso8601String(),
      'created_at': DateTime.now().toIso8601String(), // Wajib untuk sorting UI
    };

    try {
      // 1. INSERT TRANSAKSI ke database (Wajib menggunakan .select() untuk konfirmasi)
      final response = await supabase.from('transactions').insert(dataToInsert).select();
      
      final isSuccess = response is List && response.isNotEmpty;
      
      if (isSuccess) {
        // JIKA BERHASIL, PANGGIL EDGE FUNCTION (async, tidak memblokir insert)
        _notifyRealtime(response.first as Map<String, dynamic>);
      }
      
      print("DEBUG: addTransaction - Response: $response");
      return isSuccess; 
    } catch (e) {
      print("DEBUG: addTransaction - Error: $e");
      return false;
    }
  }

  // --- FUNGSI LAIN ---
  Future<List<Map<String, dynamic>>> getLatestTransactions() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final result = await supabase
          .from('transactions')
          .select('*, master_categories(id, name, type)')
          .eq('user_id', userId)
          .order('date', ascending: false)
          .order('created_at', ascending: false)
          .limit(50); 

      // Memperbaiki warnings 'unnecessary_cast' dan 'unnecessary_type_check'
      return List<Map<String, dynamic>>.from(result); 
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
    final userId = supabase.auth.currentUser?.id;
    print("DEBUG: updateTransaction - Auth Check: CurrentUser.id = $userId");
    
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

  Future<List<TransactionModel>> getTransactionsInRange(
    DateTime start,
    DateTime end,
  ) async {
    final response = await supabase
        .from('transactions')
        .select('*, master_categories(id, name, type)')
        .gte('date', start.toIso8601String())
        .lte('date', end.toIso8601String())
        .order('date', ascending: true);

    // Memperbaiki warning 'unnecessary_cast'
    final data = response; 
    return (data as List<dynamic>).map((e) => TransactionModel.fromJson(e)).toList();
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