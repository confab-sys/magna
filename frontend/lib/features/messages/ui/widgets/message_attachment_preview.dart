import 'package:flutter/material.dart';
import 'package:magna_coders/app/theme/colors.dart';
import 'package:magna_coders/app/theme/typography.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../domain/entities/message_attachment_entity.dart';

class MessageAttachmentPreview extends StatelessWidget {
  final List<MessageAttachmentEntity> attachments;

  const MessageAttachmentPreview({super.key, required this.attachments});

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: attachments.map(_buildItem).toList(),
    );
  }

  Widget _buildItem(MessageAttachmentEntity attachment) {
    final icon = _iconForType(attachment.type);

    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              attachment.fileName ?? 'Attachment',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'image':
        return PhosphorIcons.image();
      case 'video':
        return PhosphorIcons.videoCamera();
      case 'audio':
        return PhosphorIcons.waveform();
      default:
        return PhosphorIcons.paperclip();
    }
  }
}

