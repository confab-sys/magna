import 'package:dio/dio.dart';
import 'package:magna_coders/core/network/api_client.dart';
import 'package:magna_coders/core/network/endpoints.dart';
import 'package:magna_coders/features/magna_ai/data/models/ai_conversation_model.dart';
import 'package:magna_coders/features/magna_ai/data/models/ai_message_model.dart';

class MagnaAiApiService {
  final Dio _dio = ApiClient.dio;

  Future<List<AIConversationModel>> getConversations() async {
    try {
      final response = await _dio.get(Endpoints.aiConversations);
      final list = response.data['conversations'] as List;
      return list.map((e) => AIConversationModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load conversations: $e');
    }
  }

  Future<AIConversationModel> createConversation({String? title}) async {
    try {
      final response = await _dio.post(Endpoints.aiConversations, data: {
        'title': title,
      });
      return AIConversationModel.fromJson(response.data['conversation']);
    } catch (e) {
      throw Exception('Failed to create conversation: $e');
    }
  }

  Future<List<AIMessageModel>> getMessages(String conversationId) async {
    try {
      final response = await _dio.get(Endpoints.aiConversationMessages(conversationId));
      final list = response.data['messages'] as List;
      return list.map((e) => AIMessageModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load messages: $e');
    }
  }

  // Returns list of [UserMessage, AiMessage]
  Future<List<AIMessageModel>> sendMessage(String conversationId, String content) async {
    try {
      final response = await _dio.post(
        Endpoints.aiConversationMessages(conversationId),
        data: {'content': content},
      );
      
      final userMsg = AIMessageModel.fromJson(response.data['userMessage']);
      final aiMsg = AIMessageModel.fromJson(response.data['aiMessage']);
      
      return [userMsg, aiMsg];
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }
}
