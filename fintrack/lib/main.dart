import 'package:flutter/material.dart';
import 'core/supabase_config.dart';
import 'app.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // inisialisasi Firebase Core
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");

  // data payload
  if (message.data.isNotEmpty) {
    print("Background Notification Data: ${message.data}");
    // Lakukan logging atau penyimpanan data sementara jika diperlukan
  }
}

void main() async {
  // Wajib dipanggil hanya SEKALI di awal untuk mengizinkan pemanggilan metode native.
  WidgetsFlutterBinding.ensureInitialized();

  // INISIALISASI FIREBASE
  // Ini harus dipanggil sebelum package Firebase lainnya (seperti Messaging) digunakan.
  try {
    await Firebase.initializeApp();
    print("DEBUG: Firebase initialized successfully.");
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e) {
    print("ERROR: Firebase Initialization Failed: $e");
    // Lanjutkan aplikasi, tetapi fitur FCM tidak akan berfungsi
  }

  // INISIALISASI SUPABASE
  await SupabaseConfig.init();

  // INISIALISASI WAKTU LOKAL (INTL)
  await initializeDateFormatting('id_ID', null);

  // INISIALISASI NOTIFIKASI
  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.requestPermissions();

  runApp(const MyApp());
}