import 'package:json_annotation/json_annotation.dart';

part 'message_attachment_dto.g.dart';

@JsonSerializable()
class MessageAttachmentDto {
  final String id;
  final String? fileName;
  final String fileUrl;
  final String? mimeType;
  final int? fileSizeBytes;
  final int? width;
  final int? height;
  final int? durationSeconds;
  final String? thumbnailUrl;

  MessageAttachmentDto({
    required this.id,
    required this.fileName,
    required this.fileUrl,
    required this.mimeType,
    required this.fileSizeBytes,
    required this.width,
    required this.height,
    required this.durationSeconds,
    required this.thumbnailUrl,
  });

  factory MessageAttachmentDto.fromJson(Map<String, dynamic> json) =>
      _$MessageAttachmentDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MessageAttachmentDtoToJson(this);
}

