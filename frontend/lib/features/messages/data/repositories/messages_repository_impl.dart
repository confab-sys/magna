import '../../domain/entities/conversation_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/messages_repository.dart';
import '../models/conversation_model.dart';
import '../services/messages_api_service.dart';

class MessagesRepositoryImpl implements MessagesRepository {
  final MessagesApiService _api;

  MessagesRepositoryImpl({MessagesApiService? api})
      : _api = api ?? MessagesApiService();

  @override
  Future<List<ConversationEntity>> getConversations({
    String? cursor,
    int? limit,
    bool includeArchived = false,
    String? query,
  }) async {
    final dtos = await _api.getConversations(
      cursor: cursor,
      limit: limit,
      includeArchived: includeArchived,
      query: query,
    );
    return dtos.map(ConversationModel.fromDto).toList();
  }

  @override
  Future<ConversationEntity> getConversationById(String conversationId) async {
    final dto = await _api.getConversationById(conversationId);
    return ConversationModel.fromDto(dto);
  }

  @override
  Future<List<MessageEntity>> getMessages({
    required String conversationId,
    String? cursor,
    int? limit,
    String? direction,
    required String currentUserId,
  }) async {
    final dtos = await _api.getMessages(
      conversationId: conversationId,
      cursor: cursor,
      limit: limit,
      direction: direction,
    );
    return dtos
        .map(
          (dto) => MessageModel.fromDto(
            dto,
            currentUserId: currentUserId,
          ),
        )
        .toList();
  }

  @override
  Future<MessageEntity> sendMessage({
    required String conversationId,
    required String currentUserId,
    required String content,
    String messageType = 'text',
    String? replyToMessageId,
    List<Map<String, dynamic>> attachments = const [],
  }) async {
    final dto = await _api.sendMessage(
      conversationId: conversationId,
      content: content,
      messageType: messageType,
      replyToMessageId: replyToMessageId,
      attachments: attachments,
    );

    return MessageModel.fromDto(
      dto,
      currentUserId: currentUserId,
    );
  }

  @override
  Future<void> markConversationRead({
    required String conversationId,
    required String lastReadMessageId,
  }) {
    return _api.markConversationRead(
      conversationId: conversationId,
      lastReadMessageId: lastReadMessageId,
    );
  }

  @override
  Future<void> updateConversationPreferences({
    required String conversationId,
    bool? isPinned,
    bool? isArchived,
    String? notificationPreference,
  }) {
    return _api.updateConversationPreferences(
      conversationId: conversationId,
      isPinned: isPinned,
      isArchived: isArchived,
      notificationPreference: notificationPreference,
    );
  }

  @override
  Future<void> editMessage({
    required String messageId,
    required String content,
  }) {
    return _api.editMessage(
      messageId: messageId,
      content: content,
    );
  }

  @override
  Future<void> deleteMessage({
    required String messageId,
  }) {
    return _api.deleteMessage(messageId: messageId);
  }

  @override
  Future<ConversationEntity> createConversation({
    required String conversationType,
    String? name,
    String? description,
    required List<String> memberUserIds,
  }) async {
    final dto = await _api.createConversation(
      conversationType: conversationType,
      name: name,
      description: description,
      memberUserIds: memberUserIds,
    );
    return ConversationModel.fromDto(dto);
  }

  @override
  Future<ConversationEntity> getOrCreateDirectConversation({
    required String otherUserId,
  }) async {
    final dto = await _api.getOrCreateDirectConversation(
      otherUserId: otherUserId,
    );
    return ConversationModel.fromDto(dto);
  }
}

