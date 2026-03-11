import 'message_attachment_entity.dart';

class MessageSenderEntity {
  final String id;
  final String username;
  final String? avatarUrl;

  MessageSenderEntity({
    required this.id,
    required this.username,
    required this.avatarUrl,
  });
}

class MessageEntity {
  final String id;
  final String conversationId;
  final MessageSenderEntity sender;
  final String content;
  final String messageType;
  final String? replyToMessageId;
  final String status;
  final List<MessageAttachmentEntity> attachments;
  final DateTime createdAt;
  final DateTime? editedAt;
  final DateTime? deletedAt;
  final DateTime? deliveredAt;
  final DateTime? readAt;
  final bool isOwnMessage;

  MessageEntity({
    required this.id,
    required this.conversationId,
    required this.sender,
    required this.content,
    required this.messageType,
    required this.replyToMessageId,
    required this.status,
    required this.attachments,
    required this.createdAt,
    required this.editedAt,
    required this.deletedAt,
    required this.deliveredAt,
    required this.readAt,
    required this.isOwnMessage,
  });
}

