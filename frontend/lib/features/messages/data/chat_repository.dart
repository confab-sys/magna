import 'package:dio/dio.dart';
import 'package:magna_coders/core/network/api_client.dart';
import 'package:magna_coders/core/network/endpoints.dart';
import 'package:magna_coders/features/messages/domain/conversation.dart';
import 'package:magna_coders/features/messages/domain/message.dart';

class ChatRepository {
  final Dio _dio = ApiClient.dio;

  Future<List<Conversation>> getConversations() async {
    try {
      final response = await _dio.get(Endpoints.chatConversations);
      if (response.statusCode == 200) {
        final List<dynamic> list = response.data['conversations'];
        return list.map((json) => Conversation.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Message>> getMessages(String conversationId) async {
    try {
      final response = await _dio.get(Endpoints.conversationMessages(conversationId));
      if (response.statusCode == 200) {
        final List<dynamic> list = response.data['messages'];
        return list.map((json) => Message.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> sendMessage(String conversationId, String content) async {
    try {
      final response = await _dio.post(Endpoints.chatMessages, data: {
        'conversation_id': conversationId,
        'content': content,
      });
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}
