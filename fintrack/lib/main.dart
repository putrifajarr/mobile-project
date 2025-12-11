// File: fintrack/lib/main.dart

import 'package:flutter/material.dart';

// Import yang sudah ada
import 'core/supabase_config.dart';
import 'app.dart';
import 'package:intl/date_symbol_data_local.dart';

// --- TAMBAHAN WAJIB FIREBASE & LOCAL NOTIFICATIONS ---
import 'package:firebase_core/firebase_core.dart'; 
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // <--- TAMBAHAN KRITIS
// --- END TAMBAHAN ---

// 1. Definisikan plugin notifikasi lokal (GLOBAL)
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// 2. Handler untuk pesan background/terminated
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(); 
  
  print("Handling a background message: ${message.messageId}");
  
  if (message.data.isNotEmpty) {
    print("Background Notification Data: ${message.data}");
  }
}

// 3. Handler untuk menampilkan notifikasi lokal saat di foreground
void _handleForegroundMessage(RemoteMessage message) {
  // Hanya tampilkan jika ada payload notifikasi
  if (message.notification != null) {
    _showLocalNotification(message.notification!);
  }
  
  // Log untuk debugging
  print("Foreground message received: ${message.notification?.title}");
}

// 4. Fungsi yang sebenarnya menampilkan notifikasi (sebagai popup banner)
Future<void> _showLocalNotification(RemoteNotification notification) async {
  // Konfigurasi Channel Notifikasi Android (WAJIB di Android O ke atas)
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'fintrack_channel_id', // ID unik, harus sama dengan yang Anda atur di AndroidManifest jika ada
    'Fintrack Alerts',    // Nama Channel
    channelDescription: 'Notifikasi penting terkait anggaran dan transaksi besar Fintrack',
    importance: Importance.max,
    priority: Priority.high,
  );
  
  // Detail notifikasi untuk semua platform
  const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);
  
  await flutterLocalNotificationsPlugin.show(
    notification.hashCode, // ID unik berdasarkan hash notifikasi
    notification.title,
    notification.body,
    platformDetails,
  );
}

// 5. Fungsi untuk Meminta Izin dan Mendapatkan FCM Token
Future<void> setupFCM() async {
  final messaging = FirebaseMessaging.instance;

  // Meminta Izin Notifikasi (Wajib di iOS/macOS)
  final settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('DEBUG: User granted permission for notifications');
  } else {
     print('DEBUG: User declined or has not yet granted permission.');
  }

  // --- INISIALISASI LOCAL NOTIFICATION UNTUK FOREGROUND ---
  // Harus dilakukan setelah permissions diminta (khususnya di iOS)
  const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // [KUNCI]: Daftarkan listener pesan foreground
  FirebaseMessaging.onMessage.listen(_handleForegroundMessage); 

  // Anda mungkin ingin mendapatkan token di tempat lain (misalnya setelah user login)
  // Untuk memastikan token FCM tersimpan di Supabase
  final fcmToken = await messaging.getToken();
  if (fcmToken != null) {
      print("DEBUG: Current FCM Token: $fcmToken");
      // Biasanya di sini Anda memanggil fungsi Supabase untuk menyimpan token
  }
}


void main() async {
  // 1. Wajib dipanggil hanya SEKALI di awal
  WidgetsFlutterBinding.ensureInitialized(); 

  // 2. INISIALISASI FIREBASE
  try {
    await Firebase.initializeApp(); 
    print("DEBUG: Firebase initialized successfully.");
    
    // Daftarkan handler background (untuk pesan saat app tertutup)
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
    // Setup Permissions, Local Notif, dan Foreground Handler
    await setupFCM(); // <--- Panggil fungsi setup

  } catch (e) {
    print("ERROR: Firebase Initialization Failed: $e");
  }

  // 3. INISIALISASI SUPABASE
  await SupabaseConfig.init();

  // 4. INISIALISASI WAKTU LOKAL (INTL)
  await initializeDateFormatting('id_ID', null);
  
  // 5. RUN APP
  runApp(const MyApp());
}

// Catatan: Pastikan Anda menambahkan dependency 'flutter_local_notifications' 
// di file pubspec.yaml Anda!