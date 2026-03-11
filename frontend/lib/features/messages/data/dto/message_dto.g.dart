// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageDto _$MessageDtoFromJson(Map<String, dynamic> json) => MessageDto(
      id: json['id'] as String,
      conversationId: json['conversationId'] as String,
      senderId: json['senderId'] as String,
      content: json['content'] as String?,
      messageType: json['messageType'] as String,
      status: json['status'] as String,
      replyToMessageId: json['replyToMessageId'] as String?,
      editedAt: json['editedAt'] == null
          ? null
          : DateTime.parse(json['editedAt'] as String),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
      deliveredAt: json['deliveredAt'] == null
          ? null
          : DateTime.parse(json['deliveredAt'] as String),
      readAt: json['readAt'] == null
          ? null
          : DateTime.parse(json['readAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
      attachments: (json['attachments'] as List<dynamic>)
          .map((e) => MessageAttachmentDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      sender: json['sender'] == null
          ? null
          : MessageSenderDto.fromJson(json['sender'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MessageDtoToJson(MessageDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'conversationId': instance.conversationId,
      'senderId': instance.senderId,
      'content': instance.content,
      'messageType': instance.messageType,
      'status': instance.status,
      'replyToMessageId': instance.replyToMessageId,
      'editedAt': instance.editedAt?.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
      'deliveredAt': instance.deliveredAt?.toIso8601String(),
      'readAt': instance.readAt?.toIso8601String(),
      'metadata': instance.metadata,
      'attachments': instance.attachments,
      'createdAt': instance.createdAt.toIso8601String(),
      'sender': instance.sender,
    };

MessageSenderDto _$MessageSenderDtoFromJson(Map<String, dynamic> json) =>
    MessageSenderDto(
      id: json['id'] as String,
      username: json['username'] as String,
      avatarUrl: json['avatarUrl'] as String?,
    );

Map<String, dynamic> _$MessageSenderDtoToJson(MessageSenderDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'avatarUrl': instance.avatarUrl,
    };
