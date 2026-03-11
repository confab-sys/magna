import '../../domain/entities/conversation_entity.dart';
import '../../domain/entities/member_entity.dart';
import '../../domain/entities/message_attachment_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../dto/conversation_dto.dart';
import '../dto/member_dto.dart';
import '../dto/message_attachment_dto.dart';
import '../dto/message_dto.dart';

class ConversationModel extends ConversationEntity {
  ConversationModel({
    required super.id,
    required super.name,
    required super.avatarUrl,
    required super.description,
    required super.isGroup,
    required super.createdBy,
    required super.lastMessagePreview,
    required super.lastMessageAt,
    required super.lastSenderId,
    required super.unreadCount,
    required super.isPinned,
    required super.isArchived,
    required super.notificationPreference,
    required super.members,
    required super.conversationType,
  });

  factory ConversationModel.fromDto(ConversationDto dto) {
    final String? effectiveName;
    if (dto.name != null && dto.name!.isNotEmpty) {
      effectiveName = dto.name;
    } else if (dto.conversationType == 'direct') {
      effectiveName = 'Direct Conversation';
    } else {
      effectiveName = 'Conversation';
    }

    final String? effectivePreview;
    if (dto.lastMessagePreview != null && dto.lastMessagePreview!.isNotEmpty) {
      effectivePreview = dto.lastMessagePreview;
    } else if (dto.lastMessage != null &&
        dto.lastMessage!.preview.isNotEmpty) {
      effectivePreview = dto.lastMessage!.preview;
    } else {
      effectivePreview = 'No messages yet';
    }

    return ConversationModel(
      id: dto.id,
      name: effectiveName,
      avatarUrl: dto.avatarUrl,
      description: dto.description,
      isGroup: dto.isGroup,
      createdBy: dto.createdBy,
      lastMessagePreview: effectivePreview,
      lastMessageAt: dto.lastMessageAt ?? dto.lastMessage?.createdAt,
      lastSenderId: dto.lastSenderId ?? dto.lastMessage?.senderId,
      unreadCount: dto.unreadCount,
      isPinned: dto.isPinned,
      isArchived: dto.isArchived,
      notificationPreference: dto.notificationPreference ?? 'all',
      conversationType: dto.conversationType,
      members: (dto.members ?? const <MemberDto>[])
          .map((m) => MemberModel.fromDto(m))
          .toList(),
    );
  }
}

class MemberModel extends MemberEntity {
  MemberModel({
    required super.id,
    required super.userId,
    required super.displayName,
    required super.username,
    required super.avatarUrl,
    required super.role,
    required super.isOnline,
  });

  factory MemberModel.fromDto(MemberDto dto) {
    // Backend currently exposes userId + role, richer user info comes from
    // other endpoints; for now we keep minimal mapping and let UI handle
    // missing display fields gracefully.
    return MemberModel(
      id: dto.userId,
      userId: dto.userId,
      displayName: dto.userId,
      username: dto.userId,
      avatarUrl: null,
      role: dto.role,
      isOnline: false,
    );
  }
}

class MessageModel extends MessageEntity {
  MessageModel({
    required super.id,
    required super.conversationId,
    required super.sender,
    required super.content,
    required super.messageType,
    required super.replyToMessageId,
    required super.status,
    required super.attachments,
    required super.createdAt,
    required super.editedAt,
    required super.deletedAt,
    required super.deliveredAt,
    required super.readAt,
    required super.isOwnMessage,
  });

  factory MessageModel.fromDto(
    MessageDto dto, {
    required String currentUserId,
  }) {
    return MessageModel(
      id: dto.id,
      conversationId: dto.conversationId,
      sender: MessageSenderEntity(
        id: dto.sender?.id ?? dto.senderId,
        username: dto.sender?.username ?? dto.senderId,
        avatarUrl: dto.sender?.avatarUrl,
      ),
      content: dto.content ?? '',
      messageType: dto.messageType,
      replyToMessageId: dto.replyToMessageId,
      status: dto.status,
      attachments: dto.attachments
          .map<MessageAttachmentEntity>(
            (a) => MessageAttachmentModel.fromDto(a),
          )
          .toList(),
      createdAt: dto.createdAt,
      editedAt: dto.editedAt,
      deletedAt: dto.deletedAt,
      deliveredAt: dto.deliveredAt,
      readAt: dto.readAt,
      isOwnMessage: dto.senderId == currentUserId,
    );
  }
}

class MessageAttachmentModel extends MessageAttachmentEntity {
  MessageAttachmentModel({
    required super.id,
    required super.type,
    required super.url,
    required super.fileName,
    required super.mimeType,
    required super.sizeBytes,
    required super.thumbnailUrl,
  });

  factory MessageAttachmentModel.fromDto(MessageAttachmentDto dto) {
    // Derive a simple type from mimeType if available.
    final mimeType = dto.mimeType ?? '';
    String type = 'file';
    if (mimeType.startsWith('image/')) {
      type = 'image';
    } else if (mimeType.startsWith('video/')) {
      type = 'video';
    } else if (mimeType.startsWith('audio/')) {
      type = 'audio';
    }

    return MessageAttachmentModel(
      id: dto.id,
      type: type,
      url: dto.fileUrl,
      fileName: dto.fileName,
      mimeType: dto.mimeType,
      sizeBytes: dto.fileSizeBytes,
      thumbnailUrl: dto.thumbnailUrl,
    );
  }
}

