import 'package:magna_coders/features/notifications/data/models/notification_model.dart';
import 'package:magna_coders/features/notifications/data/services/notifications_api_service.dart';
import 'package:magna_coders/features/notifications/domain/entities/notification_entity.dart';
import 'package:magna_coders/features/notifications/domain/repositories/notifications_repository.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsApiService _api;

  NotificationsRepositoryImpl({NotificationsApiService? api})
      : _api = api ?? NotificationsApiService();

  @override
  Future<List<NotificationEntity>> fetchNotifications() async {
    final dtos = await _api.getNotifications();
    final models = dtos.map(NotificationModel.fromDto).toList();
    final entities = models.map((m) => m.toEntity()).toList();

    entities.sort(
      (a, b) => b.createdAt.compareTo(a.createdAt),
    );

    return entities;
  }

  @override
  Future<void> markAsRead(String notificationId) {
    return _api.markAsRead(notificationId);
  }
}

