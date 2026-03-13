import '../entities/ai_conversation_entity.dart';
import '../entities/ai_message_entity.dart';

abstract class MagnaAiRepository {
  Future<List<AIConversationEntity>> getConversations();
  Future<AIConversationEntity> createConversation({String? title});
  Future<List<AIMessageEntity>> getMessages(String conversationId);
  Future<AIMessageEntity> sendMessage(String conversationId, String content);
}
