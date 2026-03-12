import '../entities/conversation_entity.dart';
import '../entities/message_entity.dart';

abstract class MessagesRepository {
  Future<List<ConversationEntity>> getConversations({
    String? cursor,
    int? limit,
    bool includeArchived,
    String? query,
  });

  Future<ConversationEntity> getConversationById(String conversationId);

  Future<List<MessageEntity>> getMessages({
    required String conversationId,
    String? cursor,
    int? limit,
    String? direction,
    required String currentUserId,
  });

  Future<MessageEntity> sendMessage({
    required String conversationId,
    required String currentUserId,
    required String content,
    String messageType,
    String? replyToMessageId,
    List<Map<String, dynamic>> attachments,
  });

  Future<void> markConversationRead({
    required String conversationId,
    required String lastReadMessageId,
  });

  Future<void> updateConversationPreferences({
    required String conversationId,
    bool? isPinned,
    bool? isArchived,
    String? notificationPreference,
  });

  Future<void> editMessage({
    required String messageId,
    required String content,
  });

  Future<void> deleteMessage({
    required String messageId,
  });

  Future<ConversationEntity> createConversation({
    required String conversationType,
    String? name,
    String? description,
    required List<String> memberUserIds,
  });

  Future<ConversationEntity> getOrCreateDirectConversation({
    required String otherUserId,
  });
}

