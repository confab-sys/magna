import 'package:json_annotation/json_annotation.dart';

import 'message_attachment_dto.dart';

part 'message_dto.g.dart';

@JsonSerializable()
class MessageDto {
  final String id;
  final String conversationId;
  final String senderId;
  final String? content;
  final String messageType;
  final String status;
  final String? replyToMessageId;
  final DateTime? editedAt;
  final DateTime? deletedAt;
  final DateTime? deliveredAt;
  final DateTime? readAt;
  final Map<String, dynamic>? metadata;
  final List<MessageAttachmentDto> attachments;
  final DateTime createdAt;
  final MessageSenderDto? sender;

  MessageDto({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.messageType,
    required this.status,
    required this.replyToMessageId,
    required this.editedAt,
    required this.deletedAt,
    required this.deliveredAt,
    required this.readAt,
    required this.metadata,
    required this.attachments,
    required this.createdAt,
    required this.sender,
  });

  factory MessageDto.fromJson(Map<String, dynamic> json) =>
      _$MessageDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MessageDtoToJson(this);
}

@JsonSerializable()
class MessageSenderDto {
  final String id;
  final String username;
  final String? avatarUrl;

  MessageSenderDto({
    required this.id,
    required this.username,
    required this.avatarUrl,
  });

  factory MessageSenderDto.fromJson(Map<String, dynamic> json) =>
      _$MessageSenderDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MessageSenderDtoToJson(this);
}

