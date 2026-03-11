import 'package:flutter/material.dart';
import 'package:magna_coders/app/theme/colors.dart';
import 'package:magna_coders/app/theme/typography.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../domain/entities/message_entity.dart';

class MessageBubble extends StatelessWidget {
  final MessageEntity message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isMe = message.isOwnMessage;
    final isDeleted = message.deletedAt != null;
    final isEdited = message.editedAt != null && !isDeleted;

    Color bubbleColor;
    Color textColor;
    BoxBorder? border;

    if (isDeleted) {
      bubbleColor = AppColors.surface;
      textColor = AppColors.textSecondary;
      border = Border.all(color: AppColors.border);
    } else if (isMe) {
      bubbleColor = AppColors.primary;
      textColor = Colors.white;
    } else {
      bubbleColor = AppColors.surface;
      textColor = AppColors.textPrimary;
      border = Border.all(color: AppColors.border);
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(16),
          ),
          border: border,
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  message.sender.username,
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            Text(
              isDeleted ? 'This message was deleted' : message.content,
              style: AppTypography.bodyMedium.copyWith(
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  timeago.format(message.createdAt),
                  style: AppTypography.caption.copyWith(
                    color: textColor.withOpacity(0.8),
                  ),
                ),
                if (isEdited) ...[
                  const SizedBox(width: 4),
                  Text(
                    'edited',
                    style: AppTypography.caption.copyWith(
                      color: textColor.withOpacity(0.8),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

