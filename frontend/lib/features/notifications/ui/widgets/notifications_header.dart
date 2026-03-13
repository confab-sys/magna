import 'package:flutter/material.dart';
import 'package:magna_coders/app/theme/colors.dart';
import 'package:magna_coders/app/theme/typography.dart';

class NotificationsHeader extends StatelessWidget {
  final int unreadCount;
  final VoidCallback onRefresh;
  final VoidCallback? onMarkAllRead;
  final VoidCallback? onClearAll;

  const NotificationsHeader({
    super.key,
    required this.unreadCount,
    required this.onRefresh,
    this.onMarkAllRead,
    this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifications',
                  style: AppTypography.h3,
                ),
                if (unreadCount > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      '$unreadCount unread',
                      style: AppTypography.caption,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh, color: AppColors.textSecondary),
            tooltip: 'Refresh',
          ),
          if (onClearAll != null)
            IconButton(
              onPressed: onClearAll,
              icon: const Icon(Icons.clear_all, color: AppColors.textSecondary),
              tooltip: 'Clear notifications',
            ),
          if (onMarkAllRead != null && unreadCount > 0)
            TextButton(
              onPressed: onMarkAllRead,
              child: const Text('Mark all as read'),
            ),
        ],
      ),
    );
  }
}

