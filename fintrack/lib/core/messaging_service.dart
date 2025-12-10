// File: fintrack/lib/core/services/messaging_service.dart (KOREKSI LENGKAP)

import 'package:fintrack/core/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
// Import wajib untuk Context dan Navigator
import 'package:flutter/material.dart'; 

class MessagingService {
  final SupabaseClient supabase = SupabaseConfig.client;

  Future<void> saveFCMToken() async {
    // ... (Logic penyimpanan token, sudah benar)
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      print("DEBUG FCM: User not logged in, cannot save token.");
      return;
    }
    
    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken == null) {
      print("DEBUG FCM: Failed to get FCM token.");
      return;
    }

    final Map<String, dynamic> tokenData = {
      'fcm_token': fcmToken,
      'user_id': userId,
    };

    try {
      await supabase
          .from('fcm_tokens')
          .upsert(tokenData, onConflict: 'fcm_token');
      
      print('DEBUG FCM: Token successfully saved/updated for user $userId');
    } catch (e) {
      print('DEBUG FCM: Error saving FCM Token: $e');
    }
  }

  void monitorTokenRefresh() {
    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
      saveFCMToken();
    });
  }

  // --- TAMBAHAN FASE B: LISTENER DAN DEEP LINKING ---

  void setupInteractions(BuildContext context) {
    // 1. Terminated / App Opened from a Tap
    // Mendapatkan pesan jika aplikasi dibuka dari notifikasi yang diklik
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        _handleMessage(context, message);
      }
    });

    // 2. Background / Foreground Tap
    // Dipanggil ketika user mengklik notifikasi saat aplikasi di background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleMessage(context, message);
    });
    
    // 3. Foreground Messages
    // Dipanggil ketika notifikasi datang saat aplikasi sedang dibuka
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Foreground message received: ${message.notification?.title}");
      // Di sini Anda bisa menggunakan flutter_local_notifications untuk menampilkan notifikasi pop-up lokal
      // Agar notifikasi terlihat oleh user saat aplikasi terbuka.
      // Kita hanya akan menampilkan SnackBar untuk demo.
      if (context.mounted && message.notification != null) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(message.notification!.body!),
                  duration: const Duration(seconds: 5),
              ),
          );
      }
    });
  }

  // Helper untuk melakukan navigasi berdasarkan data payload (Deep Link)
  void _handleMessage(BuildContext context, RemoteMessage message) {
    final data = message.data;
    
    // Logika Deep Link berdasarkan 'type' data dari Edge Function Supabase (Contoh: 'budget' atau 'transaction')
    final String type = data['type'] ?? 'notification'; 

    switch (type) {
      case 'budget':
        // Navigasi ke layar Anggaran
        Navigator.of(context).pushNamed('/budget_screen'); // Asumsi rute '/budget_screen' ada
        break;
      case 'transaction':
        // Navigasi ke layar Riwayat/History
        Navigator.of(context).pushNamed('/history_screen'); // Asumsi rute '/history_screen' ada
        break;
      default:
        // Navigasi default (misalnya ke NotifikasiScreen)
        Navigator.of(context).pushNamed('/notification_screen'); // Asumsi rute /notification_screen ada
    }
  }
  // --- END TAMBAHAN FASE B ---
}