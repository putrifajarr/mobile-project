import 'package:fintrack/core/constants/constants.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

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
            onPressed: () {},
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
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionHeader("Hari Ini"),
          const SizedBox(height: 12),
          _buildNotificationItem(
            title: "Peringatan Anggaran",
            message: "Pengeluaran kategori Makanan mencapai 90% dari batas.",
            time: "10:30",
            type: NotificationType.warning,
            isUnread: true,
          ),
          _buildNotificationItem(
            title: "Transaksi Besar Terdeteksi",
            message: "Pengeluaran Rp 1.500.000 untuk Belanja Bulanan.",
            time: "08:15",
            type: NotificationType.info,
            isUnread: true,
          ),

          const SizedBox(height: 24),

          _buildSectionHeader("Kemarin"),
          const SizedBox(height: 12),
          _buildNotificationItem(
            title: "Anggaran Terlampaui",
            message:
                "Kategori Hiburan telah melebihi batas anggaran bulan ini.",
            time: "19:00",
            type: NotificationType.alert,
            isUnread: false,
          ),
          _buildNotificationItem(
            title: "Tips Keuangan",
            message: "Hemat 10% pendapatanmu untuk dana darurat.",
            time: "09:00",
            type: NotificationType.success,
            isUnread: false,
          ),
        ],
      ),
    );
  }

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
        iconData = Icons.lock;
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

enum NotificationType { success, alert, warning, info }
