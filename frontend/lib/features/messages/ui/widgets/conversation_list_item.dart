import 'package:flutter/material.dart';
import 'package:magna_coders/app/theme/colors.dart';
import 'package:magna_coders/app/theme/typography.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../domain/entities/conversation_entity.dart';
import 'conversation_avatar.dart';
import 'unread_badge.dart';

class ConversationListItem extends StatelessWidget {
  final ConversationEntity conversation;
  final VoidCallback onTap;

  const ConversationListItem({
    super.key,
    required this.conversation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final lastActivity = conversation.lastMessageAt;
    final hasUnread = conversation.unreadCount > 0;
    final preview =
        conversation.lastMessagePreview?.trim().isNotEmpty == true
            ? conversation.lastMessagePreview!.trim()
            : 'Start the conversation';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ConversationAvatar(
                  name: conversation.name,
                  avatarUrl: conversation.avatarUrl,
                  isOnline: !conversation.isGroup,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        conversation.name ?? 'Conversation',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight:
                              hasUnread ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        preview,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (lastActivity != null)
                      Text(
                        timeago.format(lastActivity),
                        style: AppTypography.caption,
                      ),
                    const SizedBox(height: 6),
                    if (hasUnread) UnreadBadge(count: conversation.unreadCount),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

