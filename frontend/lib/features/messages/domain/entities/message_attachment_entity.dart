class MessageAttachmentEntity {
  final String id;
  final String type;
  final String url;
  final String? fileName;
  final String? mimeType;
  final int? sizeBytes;
  final String? thumbnailUrl;

  MessageAttachmentEntity({
    required this.id,
    required this.type,
    required this.url,
    required this.fileName,
    required this.mimeType,
    required this.sizeBytes,
    required this.thumbnailUrl,
  });
}

