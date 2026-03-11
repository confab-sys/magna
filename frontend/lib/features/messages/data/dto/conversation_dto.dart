import 'member_dto.dart';

bool _intToBool(Object? value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  return false;
}

DateTime? _dateTimeOrNull(Object? value) {
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value);
  }
  return null;
}

class ConversationDto {
  final String id;

  final String conversationType;

  final String? name;
  final String? description;
  final String? avatarUrl;

  final bool isGroup;

  final String createdBy;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  final ConversationLastMessageDto? lastMessage;

  final String? lastMessageId;

  final String? lastMessagePreview;

  final DateTime? lastMessageAt;

  final String? lastSenderId;

  final int unreadCount;

  final bool isPinned;

  final bool isArchived;

  final bool isLocked;

  final String? notificationPreference;

  // Members may not be populated yet; keep it nullable-safe.
  final List<MemberDto>? members;

  ConversationDto({
    required this.id,
    required this.conversationType,
    required this.name,
    required this.description,
    required this.avatarUrl,
    required this.isGroup,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.lastMessage,
    required this.lastMessageId,
    required this.lastMessagePreview,
    required this.lastMessageAt,
    required this.lastSenderId,
    required this.unreadCount,
    required this.isPinned,
    required this.isArchived,
    required this.isLocked,
    required this.notificationPreference,
    required this.members,
  });

  factory ConversationDto.fromJson(Map<String, dynamic> json) {
    return ConversationDto(
      id: json['id'] as String,
      conversationType: (json['conversation_type'] ??
              json['conversationType'] ??
              'direct') as String,
      name: json['name'] as String?,
      description: json['description'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      isGroup: _intToBool(json['is_group']),
      createdBy: (json['created_by'] ?? '') as String,
      createdAt: _dateTimeOrNull(json['created_at']),
      updatedAt: _dateTimeOrNull(json['updated_at']),
      lastMessage: json['last_message'] is Map<String, dynamic>
          ? ConversationLastMessageDto.fromJson(
              json['last_message'] as Map<String, dynamic>,
            )
          : null,
      lastMessageId: json['last_message_id'] as String?,
      lastMessagePreview: json['last_message_preview'] as String?,
      lastMessageAt: _dateTimeOrNull(json['last_message_at']),
      lastSenderId: json['last_sender_id'] as String?,
      unreadCount: (json['unread_count'] as num?)?.toInt() ?? 0,
      isPinned: _intToBool(json['is_pinned']),
      isArchived: _intToBool(json['is_archived']),
      isLocked: _intToBool(json['is_locked']),
      notificationPreference: json['notification_preference'] as String?,
      members: (json['members'] as List?)
          ?.map(
            (e) => MemberDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_type': conversationType,
      'name': name,
      'description': description,
      'avatar_url': avatarUrl,
      'is_group': isGroup ? 1 : 0,
      'created_by': createdBy,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'last_message': lastMessage?.toJson(),
      'last_message_id': lastMessageId,
      'last_message_preview': lastMessagePreview,
      'last_message_at': lastMessageAt?.toIso8601String(),
      'last_sender_id': lastSenderId,
      'unread_count': unreadCount,
      'is_pinned': isPinned ? 1 : 0,
      'is_archived': isArchived ? 1 : 0,
      'is_locked': isLocked ? 1 : 0,
      'notification_preference': notificationPreference,
      'members': members?.map((m) => m.toJson()).toList(),
    };
  }
}

class ConversationLastMessageDto {
  final String id;
  final String preview;
  final String messageType;
  final String senderId;
  final DateTime createdAt;

  ConversationLastMessageDto({
    required this.id,
    required this.preview,
    required this.messageType,
    required this.senderId,
    required this.createdAt,
  });

  factory ConversationLastMessageDto.fromJson(Map<String, dynamic> json) {
    return ConversationLastMessageDto(
      id: json['id'] as String,
      preview: (json['preview'] ?? json['content'] ?? '') as String,
      messageType: (json['message_type'] ?? json['messageType'] ?? 'text')
          as String,
      senderId: (json['sender_id'] ?? json['senderId'] ?? '') as String,
      createdAt:
          _dateTimeOrNull(json['created_at']) ?? DateTime.now().toUtc(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'preview': preview,
      'message_type': messageType,
      'sender_id': senderId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

