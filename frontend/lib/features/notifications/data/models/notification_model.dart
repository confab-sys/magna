import 'package:magna_coders/features/notifications/data/dto/notification_dto.dart';
import 'package:magna_coders/features/notifications/domain/entities/notification_entity.dart';

class NotificationModel {
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
  final Map<String, dynamic> metadata;

  NotificationModel({
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

  factory NotificationModel.fromDto(NotificationDto dto) {
    return NotificationModel(
      id: dto.id,
      notificationType: _mapType(dto.type),
      title: dto.title,
      message: dto.message,
      isRead: dto.isRead,
      createdAt: dto.createdAt,
      actorId: dto.actorId,
      actorName: dto.actorName,
      actorAvatarUrl: dto.actorAvatarUrl,
      targetType: _mapTargetType(dto.targetType),
      targetId: dto.targetId,
      metadata: dto.metadata ?? const {},
    );
  }

  NotificationEntity toEntity() {
    return NotificationEntity(
      id: id,
      notificationType: notificationType,
      title: title,
      message: message,
      isRead: isRead,
      createdAt: createdAt,
      actorId: actorId,
      actorName: actorName,
      actorAvatarUrl: actorAvatarUrl,
      targetType: targetType,
      targetId: targetId,
      metadata: metadata,
    );
  }

  static NotificationType _mapType(String raw) {
    switch (raw) {
      case 'job_posted':
        return NotificationType.jobPosted;
      case 'project_posted':
        return NotificationType.projectPosted;
      case 'post_created':
        return NotificationType.postCreated;
      case 'post_liked':
        return NotificationType.postLiked;
      case 'project_liked':
        return NotificationType.projectLiked;
      case 'job_liked':
        return NotificationType.jobLiked;
      case 'post_commented':
        return NotificationType.postCommented;
      case 'project_commented':
        return NotificationType.projectCommented;
      case 'job_commented':
        return NotificationType.jobCommented;
      case 'friend_request_received':
        return NotificationType.friendRequestReceived;
      default:
        return NotificationType.unknown;
    }
  }

  static NotificationTargetType _mapTargetType(String? raw) {
    switch (raw) {
      case 'post':
        return NotificationTargetType.post;
      case 'project':
        return NotificationTargetType.project;
      case 'job':
        return NotificationTargetType.job;
      case 'user':
        return NotificationTargetType.user;
      case 'friend_request':
        return NotificationTargetType.friendRequest;
      default:
        return NotificationTargetType.unknown;
    }
  }
}

