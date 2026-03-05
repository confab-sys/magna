import 'package:json_annotation/json_annotation.dart';

part 'conversation.g.dart';

@JsonSerializable()
class Conversation {
  final String id;
  final String? name;
  
  @JsonKey(name: 'is_group')
  final bool isGroup;
  
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  
  // Optional: last message, unread count, etc. if backend provides
  @JsonKey(name: 'last_message')
  final String? lastMessage;

  Conversation({
    required this.id,
    this.name,
    this.isGroup = false,
    required this.createdAt,
    this.lastMessage,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) => _$ConversationFromJson(json);
  Map<String, dynamic> toJson() => _$ConversationToJson(this);
}
