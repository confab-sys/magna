// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
      id: json['id'] as String,
      content: json['content'] as String,
      senderId: json['sender_id'] as String,
      conversationId: json['conversation_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'sender_id': instance.senderId,
      'conversation_id': instance.conversationId,
      'created_at': instance.createdAt.toIso8601String(),
    };
