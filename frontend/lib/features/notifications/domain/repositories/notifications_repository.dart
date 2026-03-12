import 'package:magna_coders/features/notifications/domain/entities/notification_entity.dart';

/// Abstraction that unifies notifications from REST and WebSocket.
abstract class NotificationsRepository {
  /// Fetches the latest notifications snapshot from REST.
  Future<List<NotificationEntity>> fetchNotifications();

  /// Marks a notification as read via REST.
  Future<void> markAsRead(String notificationId);
}

