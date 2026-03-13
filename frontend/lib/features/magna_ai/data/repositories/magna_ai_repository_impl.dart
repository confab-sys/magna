import 'package:magna_coders/features/magna_ai/data/services/magna_ai_api_service.dart';
import 'package:magna_coders/features/magna_ai/domain/entities/ai_conversation_entity.dart';
import 'package:magna_coders/features/magna_ai/domain/entities/ai_message_entity.dart';
import 'package:magna_coders/features/magna_ai/domain/repositories/magna_ai_repository.dart';

class MagnaAiRepositoryImpl implements MagnaAiRepository {
  final MagnaAiApiService _apiService;

  MagnaAiRepositoryImpl({MagnaAiApiService? apiService})
      : _apiService = apiService ?? MagnaAiApiService();

  @override
  Future<List<AIConversationEntity>> getConversations() =>
      _apiService.getConversations();

  @override
  Future<AIConversationEntity> createConversation({String? title}) =>
      _apiService.createConversation(title: title);

  @override
  Future<List<AIMessageEntity>> getMessages(String conversationId) =>
      _apiService.getMessages(conversationId);

  @override
  Future<AIMessageEntity> sendMessage(String conversationId, String content) async {
    // The API returns both user and AI message. 
    // But the repo contract asks for one return. 
    // We'll return the AI message as the "response". 
    // The controller should handle optimistic UI for user message.
    final messages = await _apiService.sendMessage(conversationId, content);
    return messages.last; // AI message
  }
  
  // Helper to get both for controller convenience if needed, 
  // but let's stick to standard flow or expose a specific method.
  Future<List<AIMessageEntity>> sendMessageAndGetResponse(String conversationId, String content) async {
    return _apiService.sendMessage(conversationId, content);
  }
}
