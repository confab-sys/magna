import 'package:json_annotation/json_annotation.dart';

part 'notification_dto.g.dart';

@JsonSerializable()
class NotificationDto {
  final String id;
  @JsonKey(defaultValue: 'unknown')
  final String type;
  final String title;
  final String message;

  @JsonKey(name: 'is_read')
  final bool isRead;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'actor_id')
  final String? actorId;

  @JsonKey(name: 'actor_name')
  final String? actorName;

  @JsonKey(name: 'actor_avatar_url')
  final String? actorAvatarUrl;

  @JsonKey(name: 'target_type')
  final String? targetType;

  @JsonKey(name: 'target_id')
  final String? targetId;

  /// Optional structured metadata from the backend.
  final Map<String, dynamic>? metadata;

  NotificationDto({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.actorId,
    this.actorName,
    this.actorAvatarUrl,
    this.targetType,
    this.targetId,
    this.metadata,
  });

  factory NotificationDto.fromJson(Map<String, dynamic> json) =>
      _$NotificationDtoFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationDtoToJson(this);
}

