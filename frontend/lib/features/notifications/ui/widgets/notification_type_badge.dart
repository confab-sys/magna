import 'package:flutter/material.dart';
import 'package:magna_coders/app/theme/colors.dart';
import 'package:magna_coders/app/theme/typography.dart';
import 'package:magna_coders/features/notifications/domain/entities/notification_entity.dart';

class NotificationTypeBadge extends StatelessWidget {
  final NotificationEntity notification;

  const NotificationTypeBadge({
    super.key,
    required this.notification,
  });

  @override
  Widget build(BuildContext context) {
    final label = _labelFor(notification.notificationType);
    if (label == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          fontSize: 10,
        ),
      ),
    );
  }

  String? _labelFor(NotificationType type) {
    switch (type) {
      case NotificationType.jobPosted:
      case NotificationType.jobLiked:
      case NotificationType.jobCommented:
        return 'JOB';
      case NotificationType.projectPosted:
      case NotificationType.projectLiked:
      case NotificationType.projectCommented:
        return 'PROJECT';
      case NotificationType.postCreated:
      case NotificationType.postLiked:
      case NotificationType.postCommented:
        return 'POST';
      case NotificationType.friendRequestReceived:
      case NotificationType.unknown:
        return null;
    }
  }
}

