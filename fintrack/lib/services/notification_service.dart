import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Note: Request permission is handled separately for iOS
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        // Handle notification tap
      },
    );
  }

  Future<void> requestPermissions() async {
    if (Platform.isIOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      // Request permission for Android 13+
      await androidImplementation?.requestNotificationsPermission();

      // Request exact alarm permission (optional, depending on use case)
      // await androidImplementation?.requestExactAlarmsPermission();
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'budget_alerts_channel',
          'Budget Alerts',
          channelDescription: 'Notifications for budget warnings and limits',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );

    // Log to Supabase automatically
    // Determine type based on title content (simple heuristic)
    String type = 'info';
    if (title.toLowerCase().contains('warning') ||
        title.toLowerCase().contains('peringatan')) {
      type = 'warning';
    } else if (title.toLowerCase().contains('exceeded') ||
        title.toLowerCase().contains('melebihi')) {
      type = 'alert';
    }

    logNotificationToSupabase(title: title, body: body, type: type);
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required Duration duration,
    required dynamic UILocalNotificationDateInterpretation,
  }) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.now(tz.local).add(duration),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminders_channel',
          'Reminders',
          channelDescription: 'Engagement reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> logNotificationToSupabase({
    required String title,
    required String body,
    String type = 'info',
  }) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      // Validate type (fallback to 'info' if invalid)
      const validTypes = ['warning', 'info', 'alert'];
      final safeType = validTypes.contains(type) ? type : 'info';

      await Supabase.instance.client.from('notifications').insert({
        'user_id': user.id,
        'title': title,
        'body': body,
        'type': safeType,
        'is_read': false,
      });
      print("DEBUG: Notification logged to Supabase: $title");
    } catch (e) {
      print("ERROR: Failed to log notification: $e");
    }
  }
}
