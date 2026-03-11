import 'member_entity.dart';
import 'message_entity.dart';

class ConversationEntity {
  final String id;
  final String? name;
  final String? avatarUrl;
  final String? description;
  final bool isGroup;
  final String createdBy;
  final String? lastMessagePreview;
  final DateTime? lastMessageAt;
  final String? lastSenderId;
  final int unreadCount;
  final bool isPinned;
  final bool isArchived;
  final String notificationPreference;
  final String conversationType;
  final List<MemberEntity> members;

  ConversationEntity({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.description,
    required this.isGroup,
    required this.createdBy,
    required this.lastMessagePreview,
    required this.lastMessageAt,
    required this.lastSenderId,
    required this.unreadCount,
    required this.isPinned,
    required this.isArchived,
    required this.notificationPreference,
    required this.conversationType,
    required this.members,
  });
}

