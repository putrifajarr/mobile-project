// File: features/notification/view/notification_screen.dart

import 'package:fintrack/core/constants/constants.dart';
import 'package:flutter/material.dart';

// --- TAMBAHAN WAJIB ---
import 'package:supabase_flutter/supabase_flutter.dart'; // Wajib untuk Supabase Client
import 'package:intl/intl.dart'; // Untuk memformat tanggal
// Asumsi 'supabase_config.dart' tidak diperlukan jika hanya berisi Supabase.initialize
// --- END TAMBAHAN WAJIB ---


// 1. MODEL DATA NOTIFIKASI
// Model ini memetakan kolom dari tabel 'user_notifications'
class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type; // 'large_transaction', 'budget_warning', 'log_reminder', dll.
  final bool isRead;
  final DateTime createdAt;

  NotificationModel.fromJson(Map<String, dynamic> json)
      : id = json['id'] as String,
        userId = json['user_id'] as String,
        title = json['title'] as String,
        message = json['message'] as String,
        type = json['type'] as String,
        isRead = json['is_read'] as bool,
        // Konversi waktu dari UTC database ke Local time
        createdAt = DateTime.parse(json['created_at'] as String).toLocal();
}

// Enum yang Anda definisikan sebelumnya (dibiarkan di akhir file)
enum NotificationType { success, alert, warning, info }


class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late Future<List<NotificationModel>> _notificationsFuture;
  
  // --- PERBAIKAN AKSES SUPABASE (Mengatasi error 'undefined_getter') ---
  // Menggunakan cara standar akses klien Supabase
  final SupabaseClient supabase = Supabase.instance.client; 
  // --- END PERBAIKAN ---

  @override
  void initState() {
    super.initState();
    // Pastikan Intl.defaultLocale sudah diatur di main.dart
    _fetchNotifications();
  }

  // Fungsi ASYNC untuk mengambil data notifikasi dari Supabase
  void _fetchNotifications() {
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      setState(() {
        _notificationsFuture = Future.value([]);
      });
      return;
    }

    setState(() {
      _notificationsFuture = supabase
          .from('user_notifications')
          .select()
          .eq('user_id', userId)
          // Urutkan berdasarkan waktu terbaru
          .order('created_at', ascending: false) 
          .then((data) {
            // Mapping data JSON ke List<NotificationModel>
            return data.map((json) => NotificationModel.fromJson(json)).toList();
          });
    });
  }

  // Fungsi untuk menandai semua notifikasi sebagai telah dibaca
  Future<void> _markAllAsRead() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      // Lakukan update di database. 
      // Menggunakan .execute() atau .select() yang tidak disarankan untuk PostgrestClient 
      // di Dart menyebabkan tipe kembali menjadi PostgrestList yang tidak memiliki getter .error.
      // Kita akan menggunakan update sederhana dan mengandalkan try-catch untuk error koneksi/RLS.
      await supabase
          .from('user_notifications')
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);
      
      // Jika update sukses, cetak log
      print('Notifications marked as read successfully.');

    } catch (e) {
      // Menangkap error jika update gagal (misalnya, masalah koneksi atau RLS)
      print('Error marking all notifications as read: $e');
    }

    // Refresh tampilan
    _fetchNotifications(); 
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ColorPallete.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Notifikasi",
          style: TextStyle(
            color: ColorPallete.white,
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _markAllAsRead, // Panggil fungsi mark as read
            child: const Text(
              "Tandai dibaca",
              style: TextStyle(
                color: ColorPallete.green,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      
      // Menggantikan ListView statis dengan FutureBuilder dinamis
      body: FutureBuilder<List<NotificationModel>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error memuat: ${snapshot.error}', style: TextStyle(color: Colors.red[300])));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Tidak ada notifikasi.", style: TextStyle(color: Colors.grey[400])));
          }

          final notifications = snapshot.data!;
          
          // Mengelompokkan notifikasi
          final grouped = _groupNotifications(notifications);

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: grouped.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(entry.key), // "Hari Ini", "Kemarin", dll
                  const SizedBox(height: 12),
                  // Menghapus .toList() yang tidak perlu di spread, memperbaiki error minor
                  ...entry.value.map((notif) {
                    return _buildNotificationItem(
                      title: notif.title,
                      message: notif.message,
                      time: _formatTime(notif.createdAt),
                      type: _mapType(notif.type),
                      isUnread: !notif.isRead,
                    );
                  }), 
                  // Spacer di antara grup
                  const SizedBox(height: 24), 
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }

  // Helper untuk mengelompokkan notifikasi (Hari Ini, Kemarin, Tanggal Lain)
  Map<String, List<NotificationModel>> _groupNotifications(List<NotificationModel> notifications) {
    final Map<String, List<NotificationModel>> grouped = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (var notif in notifications) {
      final date = notif.createdAt.toLocal();
      final day = DateTime(date.year, date.month, date.day);
      
      String key;
      if (day.isAtSameMomentAs(today)) {
        key = "Hari Ini";
      } else if (day.isAtSameMomentAs(yesterday)) {
        key = "Kemarin";
      } else {
        // Asumsi 'id_ID' sudah diinisialisasi di main.dart
        key = DateFormat('d MMM yyyy', 'id_ID').format(day); 
      }

      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(notif);
    }
    return grouped;
  }

  // Helper untuk memformat waktu (hanya jam:menit)
  String _formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  // Helper untuk memetakan string type dari DB ke Enum NotificationType
  NotificationType _mapType(String type) {
    switch (type) {
      case 'success': 
        return NotificationType.success;
      case 'alert': 
      case 'budget_exceeded':
        return NotificationType.alert;
      case 'warning':
      case 'budget_warning':
        return NotificationType.warning;
      case 'info':
      case 'large_transaction':
      case 'log_reminder':
      case 'budget_end':
        return NotificationType.info;
      default:
        return NotificationType.info;
    }
  }

  // Metode _buildSectionHeader
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.grey,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  // Metode _buildNotificationItem
  Widget _buildNotificationItem({
    required String title,
    required String message,
    required String time,
    required NotificationType type,
    bool isUnread = false,
  }) {
    IconData iconData;
    Color iconColor;
    Color iconBgColor;

    switch (type) {
      case NotificationType.success:
        iconData = Icons.check_circle;
        iconColor = ColorPallete.greenLight;
        iconBgColor = ColorPallete.green.withOpacity(0.14);
        break;
      case NotificationType.alert:
        iconData = Icons.lock; // Menggunakan lock untuk alert/exceeded
        iconColor = Colors.redAccent;
        iconBgColor = Colors.redAccent.withOpacity(0.1);
        break;
      case NotificationType.warning:
        iconData = Icons.warning_amber_rounded;
        iconColor = Colors.orangeAccent;
        iconBgColor = Colors.orangeAccent.withOpacity(0.1);
        break;
      case NotificationType.info:
        iconData = Icons.notifications;
        iconColor = Colors.blueAccent;
        iconBgColor = Colors.blueAccent.withOpacity(0.1);
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnread ? ColorPallete.blackLight : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: isUnread ? Border.all(color: Colors.white10) : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: ColorPallete.white,
                        fontSize: 16,
                        fontWeight: isUnread
                            ? FontWeight.bold
                            : FontWeight.w500,
                      ),
                    ),
                    Text(
                      time,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 13,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          if (isUnread) ...[
            const SizedBox(width: 8),
            Container(
              margin: const EdgeInsets.only(top: 6),
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
// Enum tetap di akhir file
// enum NotificationType { success, alert, warning, info }