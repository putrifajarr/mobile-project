import 'package:fintrack/core/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fintrack/features/notification/providers/notification_provider.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initial fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(
        context,
        listen: false,
      ).fetchNotifications();
    });

    return Scaffold(
      backgroundColor: ColorPallete.black,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: ColorPallete.black,
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
          Consumer<NotificationProvider>(
            builder: (context, provider, _) {
              if (provider.unreadCount == 0) return const SizedBox.shrink();
              return TextButton(
                onPressed: () {
                  provider.markAllAsRead();
                },
                child: const Text(
                  "Tandai dibaca",
                  style: TextStyle(
                    color: ColorPallete.green,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: ColorPallete.green),
            );
          }

          if (provider.notifications.isEmpty) {
            return Center(
              child: Text(
                "Belum ada notifikasi",
                style: TextStyle(color: Colors.grey[600]),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => provider.fetchNotifications(),
            color: ColorPallete.green,
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: provider.notifications.length,
              itemBuilder: (context, index) {
                final notif = provider.notifications[index];
                return _buildNotificationItem(
                  id: notif.id,
                  title: notif.title,
                  message: notif.body,
                  time: _formatTime(notif.createdAt),
                  type: notif.type,
                  isUnread: !notif.isRead,
                  provider: provider,
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _formatTime(DateTime time) {
    // Simple formatter, can use intl if preferred
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inDays > 0) return "${diff.inDays}h lalu";
    if (diff.inHours > 0) return "${diff.inHours}j lalu";
    if (diff.inMinutes > 0) return "${diff.inMinutes}m lalu";
    return "Baru saja";
  }

  Widget _buildNotificationItem({
    required String id,
    required String title,
    required String message,
    required String time,
    required String type,
    required bool isUnread,
    required NotificationProvider provider,
  }) {
    IconData iconData;
    Color iconColor;
    Color iconBgColor;

    switch (type) {
      case 'alert':
        iconData = Icons.lock;
        iconColor = Colors.redAccent;
        iconBgColor = Colors.redAccent.withOpacity(0.1);
        break;
      case 'warning':
        iconData = Icons.warning_amber_rounded;
        iconColor = Colors.orangeAccent;
        iconBgColor = Colors.orangeAccent.withOpacity(0.1);
        break;
      case 'info':
      default:
        iconData = Icons.notifications;
        iconColor = Colors.blueAccent;
        iconBgColor = Colors.blueAccent.withOpacity(0.1);
        break;
    }

    return GestureDetector(
      onTap: () {
        if (isUnread) provider.markAsRead(id);
      },
      child: Container(
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
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            color: ColorPallete.white,
                            fontSize: 16,
                            fontWeight: isUnread
                                ? FontWeight.bold
                                : FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        time,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
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
      ),
    );
  }
}

enum NotificationType { success, alert, warning, info }
