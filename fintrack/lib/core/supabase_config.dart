import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String url = 'https://fqgpllrlrdowhzlsmely.supabase.co';
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZxZ3BsbHJscmRvd2h6bHNtZWx5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ1OTMzMTQsImV4cCI6MjA4MDE2OTMxNH0.NIwPBQlkY33Ac34TcnWxi9zvsShRH1UCDsGZdoijY7I';

  static Future<void> init() async {
    await Supabase.initialize(url: url, anonKey: anonKey);
  }

  static SupabaseClient get client => Supabase.instance.client;
}
