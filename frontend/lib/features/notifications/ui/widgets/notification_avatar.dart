import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:magna_coders/app/theme/colors.dart';
import 'package:magna_coders/features/notifications/domain/entities/notification_entity.dart';

class NotificationAvatar extends StatelessWidget {
  final NotificationEntity notification;

  const NotificationAvatar({
    super.key,
    required this.notification,
  });

  @override
  Widget build(BuildContext context) {
    final hasAvatar = notification.actorAvatarUrl != null &&
        notification.actorAvatarUrl!.isNotEmpty;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.surface,
          child: Icon(
            _iconFor(notification.notificationType),
            color: AppColors.secondary,
            size: 20,
          ),
        ),
        if (hasAvatar)
          Positioned(
            right: -2,
            bottom: -2,
            child: CircleAvatar(
              radius: 11,
              backgroundColor: AppColors.background,
              child: CircleAvatar(
                radius: 9,
                backgroundImage: NetworkImage(notification.actorAvatarUrl!),
              ),
            ),
          ),
      ],
    );
  }

  IconData _iconFor(NotificationType type) {
    switch (type) {
      case NotificationType.jobPosted:
        return PhosphorIcons.briefcase();
      case NotificationType.projectPosted:
        return PhosphorIcons.folderSimple();
      case NotificationType.postCreated:
        return PhosphorIcons.articleMedium();
      case NotificationType.postLiked:
      case NotificationType.projectLiked:
      case NotificationType.jobLiked:
        return PhosphorIcons.heart();
      case NotificationType.postCommented:
      case NotificationType.projectCommented:
      case NotificationType.jobCommented:
        return PhosphorIcons.chatCircleDots();
      case NotificationType.friendRequestReceived:
        return PhosphorIcons.userPlus();
      case NotificationType.unknown:
        return PhosphorIcons.bell();
    }
  }
}

