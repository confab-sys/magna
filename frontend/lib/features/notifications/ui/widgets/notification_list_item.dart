import 'package:flutter/material.dart';
import 'package:magna_coders/app/theme/colors.dart';
import 'package:magna_coders/app/theme/typography.dart';
import 'package:magna_coders/features/notifications/domain/entities/notification_entity.dart';
import 'package:magna_coders/features/notifications/ui/widgets/notification_avatar.dart';
import 'package:magna_coders/features/notifications/ui/widgets/notification_type_badge.dart';
import 'package:magna_coders/features/notifications/ui/widgets/notification_unread_indicator.dart';

class NotificationListItem extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;

  const NotificationListItem({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isRead = notification.isRead;

    return InkWell(
      onTap: onTap,
      child: Container(
        color: isRead ? AppColors.background : AppColors.surface,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NotificationAvatar(notification: notification),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildPrimaryText(isRead),
                      ),
                      const SizedBox(width: 8),
                      if (!isRead) const NotificationUnreadIndicator(),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (notification.message.isNotEmpty)
                    Text(
                      notification.message,
                      style: AppTypography.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        _formatDate(notification.createdAt),
                        style: AppTypography.bodySmall.copyWith(
                          fontSize: 10,
                          color: AppColors.textSecondary.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(width: 8),
                      NotificationTypeBadge(notification: notification),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryText(bool isRead) {
    final actor = notification.actorName;
    final baseStyle = AppTypography.bodyMedium.copyWith(
      fontWeight: isRead ? FontWeight.w400 : FontWeight.w600,
      color: AppColors.textPrimary,
    );

    final title = notification.title;

    if (actor == null || actor.isEmpty) {
      return Text(
        title,
        style: baseStyle,
      );
    }

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: actor,
            style: baseStyle.copyWith(fontWeight: FontWeight.w600),
          ),
          const TextSpan(text: ' '),
          TextSpan(
            text: _stripActorFromTitle(title, actor),
            style: baseStyle,
          ),
        ],
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  String _stripActorFromTitle(String title, String actor) {
    if (title.toLowerCase().startsWith(actor.toLowerCase())) {
      return title.substring(actor.length).trimLeft();
    }
    return title;
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}

