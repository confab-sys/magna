// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_attachment_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageAttachmentDto _$MessageAttachmentDtoFromJson(
        Map<String, dynamic> json) =>
    MessageAttachmentDto(
      id: json['id'] as String,
      fileName: json['fileName'] as String?,
      fileUrl: json['fileUrl'] as String,
      mimeType: json['mimeType'] as String?,
      fileSizeBytes: (json['fileSizeBytes'] as num?)?.toInt(),
      width: (json['width'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
      durationSeconds: (json['durationSeconds'] as num?)?.toInt(),
      thumbnailUrl: json['thumbnailUrl'] as String?,
    );

Map<String, dynamic> _$MessageAttachmentDtoToJson(
        MessageAttachmentDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fileName': instance.fileName,
      'fileUrl': instance.fileUrl,
      'mimeType': instance.mimeType,
      'fileSizeBytes': instance.fileSizeBytes,
      'width': instance.width,
      'height': instance.height,
      'durationSeconds': instance.durationSeconds,
      'thumbnailUrl': instance.thumbnailUrl,
    };
