part of 'notification_dto.dart';

NotificationDto _$NotificationDtoFromJson(Map<String, dynamic> json) {
  return NotificationDto(
    id: json['id'] as String,
    type: (json['type'] as String?) ?? 'unknown',
    title: json['title'] as String? ?? '',
    message: json['message'] as String? ?? '',
    isRead: _coerceIsRead(json['is_read']),
    createdAt: DateTime.parse(json['created_at'] as String),
    actorId: json['actor_id'] as String?,
    actorName: json['actor_name'] as String?,
    actorAvatarUrl: json['actor_avatar_url'] as String?,
    targetType: json['target_type'] as String?,
    targetId: json['target_id'] as String?,
    metadata: json['metadata'] as Map<String, dynamic>?,
  );
}

bool _coerceIsRead(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final v = value.toLowerCase();
    return v == '1' || v == 'true';
  }
  return false;
}

Map<String, dynamic> _$NotificationDtoToJson(NotificationDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'title': instance.title,
      'message': instance.message,
      'is_read': instance.isRead,
      'created_at': instance.createdAt.toIso8601String(),
      'actor_id': instance.actorId,
      'actor_name': instance.actorName,
      'actor_avatar_url': instance.actorAvatarUrl,
      'target_type': instance.targetType,
      'target_id': instance.targetId,
      'metadata': instance.metadata,
    };

