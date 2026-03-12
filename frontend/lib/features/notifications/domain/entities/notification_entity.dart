import 'package:meta/meta.dart';

/// Canonical notification type used throughout the app.
@immutable
class NotificationEntity {
  final String id;
  final NotificationType notificationType;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  final String? actorId;
  final String? actorName;
  final String? actorAvatarUrl;

  final NotificationTargetType targetType;
  final String? targetId;

  /// Arbitrary backend-provided extra fields.
  final Map<String, dynamic> metadata;

  const NotificationEntity({
    required this.id,
    required this.notificationType,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
    required this.targetType,
    this.actorId,
    this.actorName,
    this.actorAvatarUrl,
    this.targetId,
    this.metadata = const {},
  });

  NotificationEntity copyWith({
    bool? isRead,
    int? unreadCountDelta,
  }) {
    return NotificationEntity(
      id: id,
      notificationType: notificationType,
      title: title,
      message: message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      actorId: actorId,
      actorName: actorName,
      actorAvatarUrl: actorAvatarUrl,
      targetType: targetType,
      targetId: targetId,
      metadata: metadata,
    );
  }
}

enum NotificationType {
  jobPosted,
  projectPosted,
  postCreated,
  postLiked,
  projectLiked,
  jobLiked,
  postCommented,
  projectCommented,
  jobCommented,
  friendRequestReceived,
  unknown,
}

enum NotificationTargetType {
  post,
  project,
  job,
  user,
  friendRequest,
  unknown,
}

