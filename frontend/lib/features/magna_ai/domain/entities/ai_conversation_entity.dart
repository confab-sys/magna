import 'ai_message_entity.dart';

class AIConversationEntity {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final AIMessageEntity? lastMessage;

  const AIConversationEntity({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.lastMessage,
  });
}
