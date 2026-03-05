// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Conversation _$ConversationFromJson(Map<String, dynamic> json) => Conversation(
      id: json['id'] as String,
      name: json['name'] as String?,
      isGroup: json['is_group'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastMessage: json['last_message'] as String?,
    );

Map<String, dynamic> _$ConversationToJson(Conversation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'is_group': instance.isGroup,
      'created_at': instance.createdAt.toIso8601String(),
      'last_message': instance.lastMessage,
    };
