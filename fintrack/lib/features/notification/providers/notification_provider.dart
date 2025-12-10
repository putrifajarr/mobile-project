import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';

class NotificationProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  // FETCH NOTIFICATIONS
  Future<void> fetchNotifications() async {
    try {
      _isLoading = true;
      notifyListeners();

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final data = response as List<dynamic>;
      _notifications = data.map((e) => NotificationModel.fromJson(e)).toList();
    } catch (e) {
      print("Error fetching notifications: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
      subscribeToNotifications(); // Start listening for new ones
    }
  }

  // MARK AS READ (Single)
  Future<void> markAsRead(String id) async {
    try {
      // Optimistic update
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        final old = _notifications[index];
        _notifications[index] = NotificationModel(
          id: old.id,
          userId: old.userId,
          title: old.title,
          body: old.body,
          type: old.type,
          isRead: true,
          createdAt: old.createdAt,
        );
        notifyListeners();
      }

      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('id', id);
    } catch (e) {
      print("Error marking as read: $e");
      // Revert if needed (omitted for simplicity)
    }
  }

  // MARK ALL AS READ
  Future<void> markAllAsRead() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Optimistic update
      _notifications = _notifications.map((n) {
        return NotificationModel(
          id: n.id,
          userId: n.userId,
          title: n.title,
          body: n.body,
          type: n.type,
          isRead: true,
          createdAt: n.createdAt,
        );
      }).toList();
      notifyListeners();

      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);
    } catch (e) {
      print("Error marking all as read: $e");
    }
  }

  RealtimeChannel? _subscription;

  // SUBSCRIBE TO REALTIME INSERTS
  void subscribeToNotifications() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    // Prevent duplicate subscriptions
    if (_subscription != null) return;

    _subscription = _supabase
        .channel('public:notifications:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            final newNotif = NotificationModel.fromJson(payload.newRecord);
            addNotification(newNotif);
          },
        )
        .subscribe();
  }

  // ADD NOTIFICATION (Local Update)
  void addNotification(NotificationModel item) {
    _notifications.insert(0, item); // Add to top
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.unsubscribe();
    super.dispose();
  }
}
