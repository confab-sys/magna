// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConversationDto _$ConversationDtoFromJson(Map<String, dynamic> json) =>
    ConversationDto(
      id: json['id'] as String,
      conversationType: json['conversationType'] as String,
      name: json['name'] as String?,
      description: json['description'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      isGroup: json['isGroup'] as bool,
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      lastMessage: json['lastMessage'] == null
          ? null
          : ConversationLastMessageDto.fromJson(
              json['lastMessage'] as Map<String, dynamic>),
      unreadCount: (json['unreadCount'] as num).toInt(),
      isPinned: json['isPinned'] as bool,
      isArchived: json['isArchived'] as bool,
      notificationPreference: json['notificationPreference'] as String,
      members: (json['members'] as List<dynamic>)
          .map((e) => MemberDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ConversationDtoToJson(ConversationDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'conversationType': instance.conversationType,
      'name': instance.name,
      'description': instance.description,
      'avatarUrl': instance.avatarUrl,
      'isGroup': instance.isGroup,
      'createdBy': instance.createdBy,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'lastMessage': instance.lastMessage,
      'unreadCount': instance.unreadCount,
      'isPinned': instance.isPinned,
      'isArchived': instance.isArchived,
      'notificationPreference': instance.notificationPreference,
      'members': instance.members,
    };

ConversationLastMessageDto _$ConversationLastMessageDtoFromJson(
        Map<String, dynamic> json) =>
    ConversationLastMessageDto(
      id: json['id'] as String,
      preview: json['preview'] as String,
      messageType: json['messageType'] as String,
      senderId: json['senderId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$ConversationLastMessageDtoToJson(
        ConversationLastMessageDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'preview': instance.preview,
      'messageType': instance.messageType,
      'senderId': instance.senderId,
      'createdAt': instance.createdAt.toIso8601String(),
    };
