import 'package:magna_coders/features/magna_ai/domain/entities/ai_message_entity.dart';

class AIMessageModel extends AIMessageEntity {
  const AIMessageModel({
    required super.id,
    required super.conversationId,
    required super.role,
    required super.content,
    required super.createdAt,
  });

  factory AIMessageModel.fromJson(Map<String, dynamic> json) {
    return AIMessageModel(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String,
      role: _parseRole(json['role'] as String),
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  static AIRole _parseRole(String role) {
    switch (role.toLowerCase()) {
      case 'user':
        return AIRole.user;
      case 'assistant':
        return AIRole.assistant;
      case 'system':
        return AIRole.system;
      default:
        return AIRole.user;
    }
  }
}
