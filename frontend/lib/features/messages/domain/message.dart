import 'package:json_annotation/json_annotation.dart';

part 'message.g.dart';

@JsonSerializable()
class Message {
  final String id;
  final String content;
  
  @JsonKey(name: 'sender_id')
  final String senderId;
  
  @JsonKey(name: 'conversation_id')
  final String conversationId;
  
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  Message({
    required this.id,
    required this.content,
    required this.senderId,
    required this.conversationId,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);
  Map<String, dynamic> toJson() => _$MessageToJson(this);
}
