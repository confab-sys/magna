import 'package:dio/dio.dart';
import 'package:magna_coders/core/network/api_client.dart';
import 'package:magna_coders/core/network/endpoints.dart';

import '../dto/conversation_dto.dart';
import '../dto/message_dto.dart';

class MessagesApiService {
  final Dio _dio;

  MessagesApiService({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  Future<List<ConversationDto>> getConversations({
    String? cursor,
    int? limit,
    bool includeArchived = false,
    String? query,
  }) async {
    final response = await _dio.get(
      Endpoints.conversations,
      queryParameters: {
        if (cursor != null) 'cursor': cursor,
        if (limit != null) 'limit': limit,
        if (includeArchived) 'includeArchived': 'true',
        if (query != null && query.isNotEmpty) 'q': query,
      },
    );

    final raw = response.data;
    if (raw is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Unexpected conversations response shape',
      );
    }

    final Map<String, dynamic> data = raw;
    List<dynamic> rawList;

    // Prefer v2-style object with `conversations` key
    if (data.containsKey('conversations')) {
      rawList = (data['conversations'] as List?) ?? <dynamic>[];
    } else if (data.containsKey('data')) {
      // Backwards-compatible with envelope { success, data, error }
      final success = data['success'] as bool? ?? response.statusCode == 200;
      if (!success) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: data['error']?['message'] as String? ??
              'Failed to load conversations',
        );
      }
      rawList = (data['data'] as List?) ?? <dynamic>[];
    } else {
      rawList = const <dynamic>[];
    }

    final conversations = rawList
        .map((e) => ConversationDto.fromJson(e as Map<String, dynamic>))
        .toList();

    // Debug safeguards to verify mapping in early rollout
    // ignore: avoid_print
    print('Fetched conversations: ${conversations.length}');
    if (conversations.isNotEmpty) {
      final first = conversations.first;
      // ignore: avoid_print
      print(
        'First conversation -> id=${first.id}, type=${first.conversationType}, name=${first.name}',
      );
    }

    return conversations;
  }

  Future<ConversationDto> getConversationById(String conversationId) async {
    final response = await _dio.get(Endpoints.conversationById(conversationId));
    final data = response.data;
    final success = data['success'] as bool? ?? false;
    if (!success) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message:
            data['error']?['message'] as String? ?? 'Failed to load conversation',
      );
    }

    return ConversationDto.fromJson(
      data['data'] as Map<String, dynamic>,
    );
  }

  Future<ConversationDto> getOrCreateDirectConversation({
    required String otherUserId,
  }) async {
    final response = await _dio.post(
      Endpoints.directConversation(otherUserId),
    );

    final data = response.data;
    final success = data['success'] as bool? ?? false;
    if (!success) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: data['error']?['message'] as String? ??
            'Failed to start direct conversation',
      );
    }

    return ConversationDto.fromJson(
      data['data'] as Map<String, dynamic>,
    );
  }

  Future<List<MessageDto>> getMessages({
    required String conversationId,
    String? cursor,
    int? limit,
    String? direction,
  }) async {
    final response = await _dio.get(
      Endpoints.conversationMessages(conversationId),
      queryParameters: {
        if (cursor != null) 'cursor': cursor,
        if (limit != null) 'limit': limit,
        if (direction != null) 'direction': direction,
      },
    );

    final data = response.data;
    final success = data['success'] as bool? ?? false;
    if (!success) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: data['error']?['message'] as String? ?? 'Failed to load messages',
      );
    }

    final List<dynamic> list = data['data'] as List<dynamic>? ?? [];
    return list
        .map((item) => MessageDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<MessageDto> sendMessage({
    required String conversationId,
    required String content,
    required String messageType,
    String? replyToMessageId,
    List<Map<String, dynamic>> attachments = const [],
  }) async {
    final response = await _dio.post(
      Endpoints.createConversationMessage(conversationId),
      data: {
        'content': content,
        'messageType': messageType,
        'replyToMessageId': replyToMessageId,
        'attachments': attachments,
      },
    );

    final data = response.data;
    final success = data['success'] as bool? ?? false;
    if (!success) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: data['error']?['message'] as String? ?? 'Failed to send message',
      );
    }

    return MessageDto.fromJson(
      data['data'] as Map<String, dynamic>,
    );
  }

  Future<void> markConversationRead({
    required String conversationId,
    required String lastReadMessageId,
  }) async {
    final response = await _dio.patch(
      Endpoints.markConversationRead(conversationId),
      data: {
        'lastReadMessageId': lastReadMessageId,
      },
    );

    final data = response.data;
    final success = data['success'] as bool? ?? false;
    if (!success) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message:
            data['error']?['message'] as String? ?? 'Failed to mark as read',
      );
    }
  }

  Future<void> updateConversationPreferences({
    required String conversationId,
    bool? isPinned,
    bool? isArchived,
    String? notificationPreference,
  }) async {
    final response = await _dio.patch(
      Endpoints.updateConversationPreferences(conversationId),
      data: {
        if (isPinned != null) 'isPinned': isPinned,
        if (isArchived != null) 'isArchived': isArchived,
        if (notificationPreference != null)
          'notificationPreference': notificationPreference,
      },
    );

    final data = response.data;
    final success = data['success'] as bool? ?? false;
    if (!success) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message:
            data['error']?['message'] as String? ?? 'Failed to update preferences',
      );
    }
  }

  Future<void> editMessage({
    required String messageId,
    required String content,
  }) async {
    final response = await _dio.patch(
      Endpoints.messageById(messageId),
      data: {
        'content': content,
      },
    );

    final data = response.data;
    final success = data['success'] as bool? ?? false;
    if (!success) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: data['error']?['message'] as String? ?? 'Failed to edit message',
      );
    }
  }

  Future<void> deleteMessage({
    required String messageId,
  }) async {
    final response = await _dio.delete(
      Endpoints.messageById(messageId),
    );

    final data = response.data;
    final success = data['success'] as bool? ?? false;
    if (!success) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message:
            data['error']?['message'] as String? ?? 'Failed to delete message',
      );
    }
  }

  Future<ConversationDto> createConversation({
    required String conversationType,
    String? name,
    String? description,
    required List<String> memberUserIds,
  }) async {
    final response = await _dio.post(
      Endpoints.conversations,
      data: {
        'conversationType': conversationType,
        'name': name,
        'description': description,
        'memberUserIds': memberUserIds,
      },
    );

    final data = response.data;
    final success = data['success'] as bool? ?? false;
    if (!success) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message:
            data['error']?['message'] as String? ?? 'Failed to create conversation',
      );
    }

    return ConversationDto.fromJson(
      data['data'] as Map<String, dynamic>,
    );
  }
}

