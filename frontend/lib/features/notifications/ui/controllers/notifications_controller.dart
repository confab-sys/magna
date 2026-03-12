import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:magna_coders/features/notifications/data/services/notifications_socket_service.dart';
import 'package:magna_coders/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:magna_coders/features/notifications/domain/entities/notification_entity.dart';
import 'package:magna_coders/features/notifications/domain/repositories/notifications_repository.dart';

enum NotificationsStatus {
  idle,
  loading,
  loaded,
  empty,
  error,
  refreshing,
}

class NotificationsState {
  final NotificationsStatus status;
  final List<NotificationEntity> notifications;
  final int unreadCount;
  final String? errorMessage;

  const NotificationsState({
    required this.status,
    required this.notifications,
    required this.unreadCount,
    this.errorMessage,
  });

  NotificationsState copyWith({
    NotificationsStatus? status,
    List<NotificationEntity>? notifications,
    int? unreadCount,
    String? errorMessage,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class NotificationsController extends ChangeNotifier {
  final NotificationsRepository _repository;
  final NotificationsSocketService _socketService;

  NotificationsState _state = const NotificationsState(
    status: NotificationsStatus.idle,
    notifications: [],
    unreadCount: 0,
  );

  NotificationsState get state => _state;

  StreamSubscription<NotificationSocketEvent>? _socketSub;

  NotificationsController({
    NotificationsRepository? repository,
    NotificationsSocketService? socketService,
  })  : _repository = repository ?? NotificationsRepositoryImpl(),
        _socketService = socketService ?? NotificationsSocketService();

  Future<void> initialize() async {
    await _socketService.connect();
    _listenToSocket();
    await syncFromRest();
  }

  void _listenToSocket() {
    _socketSub?.cancel();
    _socketSub = _socketService.events.listen(_handleSocketEvent);
  }

  Future<void> syncFromRest() async {
    if (_state.status == NotificationsStatus.loading) return;

    _setState(
      _state.copyWith(
        status: _state.notifications.isEmpty
            ? NotificationsStatus.loading
            : NotificationsStatus.refreshing,
      ),
    );

    try {
      final items = await _repository.fetchNotifications();
      final unread = items.where((n) => !n.isRead).length;

      _setState(
        _state.copyWith(
          status: items.isEmpty
              ? NotificationsStatus.empty
              : NotificationsStatus.loaded,
          notifications: items,
          unreadCount: unread,
          errorMessage: null,
        ),
      );
    } catch (e) {
      _setState(
        _state.copyWith(
          status: NotificationsStatus.error,
          errorMessage: 'Failed to load notifications',
        ),
      );
    }
  }

  Future<void> refreshNotifications() => syncFromRest();

  void _handleSocketEvent(NotificationSocketEvent event) {
    switch (event.type) {
      case NotificationSocketEventType.notificationCreated:
        _handleSocketNotificationCreated(event.payload);
        break;
      case NotificationSocketEventType.notificationUpdated:
        _handleSocketNotificationUpdated(event.payload);
        break;
      case NotificationSocketEventType.notificationRead:
        _handleSocketNotificationRead(event.payload);
        break;
      case NotificationSocketEventType.notificationsCountUpdated:
        _handleSocketUnreadCountUpdated(event.payload);
        break;
      case NotificationSocketEventType.unknown:
        break;
    }
  }

  void _handleSocketNotificationCreated(Map<String, dynamic> payload) {
    final dtoJson = payload['notification'] as Map<String, dynamic>? ?? payload;
    try {
      final model = NotificationModel.fromDto(
        NotificationDto.fromJson(dtoJson),
      );
      final entity = model.toEntity();

      final existingIndex =
          _state.notifications.indexWhere((n) => n.id == entity.id);

      final updated = List<NotificationEntity>.from(_state.notifications);
      if (existingIndex >= 0) {
        updated[existingIndex] = entity;
      } else {
        updated.insert(0, entity);
      }

      updated.sort(
        (a, b) => b.createdAt.compareTo(a.createdAt),
      );

      final unreadDelta = entity.isRead ? 0 : 1;

      _setState(
        _state.copyWith(
          status: NotificationsStatus.loaded,
          notifications: updated,
          unreadCount: _state.unreadCount + unreadDelta,
        ),
      );
    } catch (_) {
      // If mapping fails, ignore this event and rely on REST recovery.
    }
  }

  void _handleSocketNotificationUpdated(Map<String, dynamic> payload) {
    final dtoJson = payload['notification'] as Map<String, dynamic>? ?? payload;
    try {
      final model = NotificationModel.fromDto(
        NotificationDto.fromJson(dtoJson),
      );
      final entity = model.toEntity();

      final updated = List<NotificationEntity>.from(_state.notifications);
      final index = updated.indexWhere((n) => n.id == entity.id);

      if (index >= 0) {
        final previous = updated[index];
        updated[index] = entity;

        var unread = _state.unreadCount;
        if (!previous.isRead && entity.isRead) {
          unread = (unread - 1).clamp(0, 1 << 31);
        } else if (previous.isRead && !entity.isRead) {
          unread += 1;
        }

        _setState(
          _state.copyWith(
            notifications: updated,
            unreadCount: unread,
          ),
        );
      } else {
        _handleSocketNotificationCreated(payload);
      }
    } catch (_) {
      // Ignore malformed updates.
    }
  }

  void _handleSocketNotificationRead(Map<String, dynamic> payload) {
    final id = payload['id'] as String? ?? payload['notificationId'] as String?;
    if (id == null) return;

    final updated = List<NotificationEntity>.from(_state.notifications);
    final index = updated.indexWhere((n) => n.id == id);
    if (index < 0) return;

    final current = updated[index];
    if (current.isRead) return;

    updated[index] = current.copyWith(isRead: true);
    final unread = (_state.unreadCount - 1).clamp(0, 1 << 31);

    _setState(
      _state.copyWith(
        notifications: updated,
        unreadCount: unread,
      ),
    );
  }

  void _handleSocketUnreadCountUpdated(Map<String, dynamic> payload) {
    final count = payload['unreadCount'] as int? ??
        payload['unread_count'] as int? ??
        _state.unreadCount;
    _setState(
      _state.copyWith(unreadCount: count),
    );
  }

  Future<void> markAsRead(NotificationEntity entity) async {
    if (entity.isRead) {
      _navigateFor(entity);
      return;
    }

    final updated = List<NotificationEntity>.from(_state.notifications);
    final index = updated.indexWhere((n) => n.id == entity.id);
    if (index >= 0) {
      updated[index] = entity.copyWith(isRead: true);
    }

    _setState(
      _state.copyWith(
        notifications: updated,
        unreadCount: (_state.unreadCount - 1).clamp(0, 1 << 31),
      ),
    );

    try {
      await _repository.markAsRead(entity.id);
    } catch (_) {
      // On failure, re-sync from REST to repair state.
      await syncFromRest();
    }

    _navigateFor(entity);
  }

  void _navigateFor(NotificationEntity entity, {BuildContext? context}) {
    final ctx = context;
    if (ctx == null) return;

    switch (entity.targetType) {
      case NotificationTargetType.post:
        if (entity.targetId != null) {
          ctx.push('/post/${entity.targetId}');
        }
        break;
      case NotificationTargetType.project:
        if (entity.targetId != null) {
          ctx.push('/project/${entity.targetId}');
        }
        break;
      case NotificationTargetType.job:
        if (entity.targetId != null) {
          ctx.push('/job/${entity.targetId}');
        }
        break;
      case NotificationTargetType.friendRequest:
      case NotificationTargetType.user:
        ctx.push('/builders');
        break;
      case NotificationTargetType.unknown:
        break;
    }
  }

  void _setState(NotificationsState newState) {
    _state = newState;
    notifyListeners();
  }

  @override
  void dispose() {
    _socketSub?.cancel();
    _socketService.dispose();
    super.dispose();
  }
}

