import 'dart:async';
import 'dart:convert';

import 'package:magna_coders/app/bootstrap.dart';
import 'package:magna_coders/core/auth/token_storage.dart';
import 'package:magna_coders/core/network/websocket_client.dart';

enum NotificationSocketEventType {
  notificationCreated,
  notificationUpdated,
  notificationRead,
  notificationsCountUpdated,
  unknown,
}

class NotificationSocketEvent {
  final NotificationSocketEventType type;
  final Map<String, dynamic> payload;

  NotificationSocketEvent({
    required this.type,
    required this.payload,
  });
}

/// Handles low-level websocket connection and maps raw messages into
/// high-level notification socket events.
class NotificationsSocketService {
  final WebSocketClient _client;
  StreamSubscription<dynamic>? _subscription;
  final _controller = StreamController<NotificationSocketEvent>.broadcast();
  bool _isConnected = false;

  NotificationsSocketService({WebSocketClient? client})
      : _client = client ?? WebSocketClient();

  Stream<NotificationSocketEvent> get events => _controller.stream;

  Future<void> connect() async {
    if (_isConnected) return;

    final token = await TokenStorage.readAccessToken();
    if (token == null || token.isEmpty) {
      return;
    }

    final userId = await TokenStorage.readUserId();
    if (userId == null || userId.isEmpty) {
      return;
    }

    // Prefer explicit realtime base; fall back to transforming the API base
    // from "-api" to "-realtime" when using the Workers.dev naming convention.
    String httpBase = ApiConfig.realtimeBase ?? ApiConfig.apiBase;
    if (ApiConfig.realtimeBase == null || ApiConfig.realtimeBase!.isEmpty) {
      httpBase = httpBase.replaceFirst('-api.', '-realtime.');
    }

    final baseUri = Uri.parse(httpBase);
    final withPath = baseUri.replace(path: '/notifications/$userId');

    _client.connect(token, url: withPath.toString());
    _isConnected = true;

    _subscription = _client.messages?.listen(
      _handleRawMessage,
      onError: (_) {
        _isConnected = false;
      },
      onDone: () {
        _isConnected = false;
      },
    );
  }

  void _handleRawMessage(dynamic raw) {
    try {
      final data = raw is String ? jsonDecode(raw) : raw;
      if (data is! Map<String, dynamic>) return;

      final rawType = data['type'] as String? ?? '';
      final payload = (data['payload'] as Map?)?.cast<String, dynamic>() ??
          <String, dynamic>{};

      final type = _mapEventType(rawType);
      _controller.add(
        NotificationSocketEvent(
          type: type,
          payload: payload,
        ),
      );
    } catch (_) {
      // Swallow malformed messages; keep stream healthy.
    }
  }

  NotificationSocketEventType _mapEventType(String raw) {
    switch (raw) {
      case 'notification.created':
        return NotificationSocketEventType.notificationCreated;
      case 'notification.updated':
        return NotificationSocketEventType.notificationUpdated;
      case 'notification.read':
        return NotificationSocketEventType.notificationRead;
      case 'notifications.count.updated':
        return NotificationSocketEventType.notificationsCountUpdated;
      default:
        return NotificationSocketEventType.unknown;
    }
  }

  Future<void> disconnect() async {
    await _subscription?.cancel();
    _subscription = null;
    await _client.disconnect();
    _isConnected = false;
  }

  Future<void> dispose() async {
    await disconnect();
    await _controller.close();
  }
}

