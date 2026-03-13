enum AIRole { user, assistant, system }

class AIMessageEntity {
  final String id;
  final String conversationId;
  final AIRole role;
  final String content;
  final DateTime createdAt;

  const AIMessageEntity({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    required this.createdAt,
  });
}
