// File: fintrack/lib/main.dart

import 'package:flutter/material.dart';

// Import yang sudah ada
import 'core/supabase_config.dart';
import 'app.dart';
import 'package:intl/date_symbol_data_local.dart';

// --- TAMBAHAN WAJIB FIREBASE ---
import 'package:firebase_core/firebase_core.dart'; 
import 'package:firebase_messaging/firebase_messaging.dart';
// --- END TAMBAHAN ---

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Lakukan inisialisasi Firebase Core lagi di isolate terpisah ini
  await Firebase.initializeApp(); 
  
  print("Handling a background message: ${message.messageId}");
  
  // Di sini Anda bisa memproses data payload
  if (message.data.isNotEmpty) {
    print("Background Notification Data: ${message.data}");
    // Lakukan logging atau penyimpanan data sementara jika diperlukan
  }
}

void main() async {
  // 1. Wajib dipanggil hanya SEKALI di awal untuk mengizinkan pemanggilan metode native.
  WidgetsFlutterBinding.ensureInitialized(); 

  // 2. INISIALISASI FIREBASE
  // Ini harus dipanggil sebelum package Firebase lainnya (seperti Messaging) digunakan.
  try {
    await Firebase.initializeApp(); 
    print("DEBUG: Firebase initialized successfully.");
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e) {
    print("ERROR: Firebase Initialization Failed: $e");
    // Lanjutkan aplikasi, tetapi fitur FCM tidak akan berfungsi
  }

  // 3. INISIALISASI SUPABASE
  await SupabaseConfig.init();

  // 4. INISIALISASI WAKTU LOKAL (INTL)
  await initializeDateFormatting('id_ID', null);
  
  // 5. RUN APP
  runApp(const MyApp());
}

// Catatan: Pastikan Anda mengganti 'MyApp' jika nama widget utama Anda berbeda
// (Misalnya: FintrackApp, seperti yang disarankan di respons sebelumnya).