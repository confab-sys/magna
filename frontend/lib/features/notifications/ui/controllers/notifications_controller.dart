import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:magna_coders/features/notifications/data/services/notifications_socket_service.dart';
import 'package:magna_coders/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:magna_coders/features/notifications/data/dto/notification_dto.dart';
import 'package:magna_coders/features/notifications/data/models/notification_model.dart';
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
    debugPrint('NotificationsController.initialize -> start');
    await _socketService.connect();
    _listenToSocket();
    await syncFromRest();
    debugPrint('NotificationsController.initialize -> done');
  }

  void _listenToSocket() {
    _socketSub?.cancel();
    _socketSub = _socketService.events.listen(_handleSocketEvent);
  }

  Future<void> syncFromRest() async {
    if (_state.status == NotificationsStatus.loading) return;

    debugPrint('NotificationsController.syncFromRest -> fetching from REST...');

    _setState(
      _state.copyWith(
        status: _state.notifications.isEmpty
            ? NotificationsStatus.loading
            : NotificationsStatus.refreshing,
      ),
    );

    try {
      final fetched = await _repository.fetchNotifications();
      debugPrint(
        'NotificationsController.syncFromRest -> fetched ${fetched.length} notifications',
      );

      // Only keep unread notifications in the local list so that
      // refresh does not re-show already read/opened items.
      final items = fetched.where((n) => !n.isRead).toList();
      final unread = items.length;

      _setState(
        _state.copyWith(
          status:
              items.isEmpty ? NotificationsStatus.empty : NotificationsStatus.loaded,
          notifications: items,
          unreadCount: unread,
          errorMessage: null,
        ),
      );
    } catch (e) {
      debugPrint('NotificationsController.syncFromRest error: $e');
      _setState(
        _state.copyWith(
          status: NotificationsStatus.error,
          errorMessage: 'Failed to load notifications',
        ),
      );
    }
  }

  Future<void> refreshNotifications() => syncFromRest();

  void clearAll() {
    if (_state.notifications.isEmpty) return;

    _setState(
      _state.copyWith(
        notifications: const [],
        unreadCount: 0,
        status: NotificationsStatus.empty,
      ),
    );
  }

  Future<void> markAllAsRead() async {
    if (_state.unreadCount == 0) return;

    final updated = _state.notifications
        .map((n) => n.isRead ? n : n.copyWith(isRead: true))
        .toList();

    _setState(
      _state.copyWith(
        notifications: updated,
        unreadCount: 0,
      ),
    );

    try {
      await _repository.markAllAsRead();
    } catch (e) {
      debugPrint('NotificationsController.markAllAsRead REST error: $e, resyncing from REST');
      await syncFromRest();
    }
  }

  void _handleSocketEvent(NotificationSocketEvent event) {
    debugPrint('NotificationsController._handleSocketEvent type=${event.type} payload=${event.payload}');
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
      debugPrint('NotificationsController._handleSocketNotificationCreated id=${entity.id}');

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
    } catch (e) {
      debugPrint('NotificationsController._handleSocketNotificationCreated mapping error: $e payload=$payload');
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
    } catch (e) {
      debugPrint('NotificationsController._handleSocketNotificationUpdated mapping error: $e payload=$payload');
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

  Future<void> markAsRead(NotificationEntity entity, BuildContext context) async {
    if (entity.isRead) {
      _navigateFor(entity, context: context);
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
    } catch (e) {
      debugPrint('NotificationsController.markAsRead REST error: $e, resyncing from REST');
      // On failure, re-sync from REST to repair state.
      await syncFromRest();
    }

    _navigateFor(entity, context: context);
  }

  void _navigateFor(NotificationEntity entity, {required BuildContext context}) {
    final ctx = context;

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

