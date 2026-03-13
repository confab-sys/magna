import 'package:magna_coders/features/magna_ai/domain/entities/ai_conversation_entity.dart';
import 'package:magna_coders/features/magna_ai/domain/entities/ai_message_entity.dart';
import 'ai_message_model.dart';

class AIConversationModel extends AIConversationEntity {
  const AIConversationModel({
    required super.id,
    required super.title,
    required super.createdAt,
    required super.updatedAt,
    super.lastMessage,
  });

  factory AIConversationModel.fromJson(Map<String, dynamic> json) {
    return AIConversationModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'New Conversation',
      createdAt: DateTime.parse(json['created_at'] as String),
      // Use last_message_at if available, else created_at
      updatedAt: json['last_message_at'] != null 
          ? DateTime.parse(json['last_message_at'] as String)
          : DateTime.parse(json['created_at'] as String),
      lastMessage: json['last_message'] != null
          ? AIMessageModel(
              id: 'preview', // Preview message doesn't need full ID in list
              conversationId: json['id'],
              role: AIRole.assistant, // Assume preview is from AI usually, or generic
              content: json['last_message'],
              createdAt: DateTime.now(),
            )
          : null,
    );
  }
}
