import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:magna_coders/app/theme/colors.dart';
import 'package:magna_coders/app/theme/typography.dart';
import 'package:magna_coders/features/notifications/data/notifications_repository.dart';
import 'package:magna_coders/features/notifications/domain/notification.dart';
import 'package:magna_coders/shared/widgets/app_loader.dart';
import 'package:magna_coders/shared/widgets/empty_state.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final _repository = NotificationsRepository();
  bool _loading = true;
  List<NotificationItem> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _loading = true);
    final notifications = await _repository.getNotifications();
    if (mounted) {
      setState(() {
        _notifications = notifications;
        _loading = false;
      });
    }
  }

  Future<void> _markAsRead(NotificationItem notification) async {
    if (notification.isRead) return;
    
    // Optimistic update
    setState(() {
      final index = _notifications.indexWhere((n) => n.id == notification.id);
      if (index != -1) {
        // Create new item with isRead = true
        // But since NotificationItem fields are final and no copyWith, 
        // we might need to rely on reload or just ignore for now if copyWith not implemented
        // Let's just call API and refresh.
      }
    });

    final success = await _repository.markAsRead(notification.id);
    if (success) {
      _loadNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: false,
      ),
      body: _loading
          ? const AppLoader()
          : _notifications.isEmpty
              ? EmptyState(
                  title: 'No notifications',
                  message: 'You have no new notifications.',
                  action: ElevatedButton(
                    onPressed: _loadNotifications,
                    child: const Text('Retry'),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: ListView.separated(
                    itemCount: _notifications.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      return _NotificationTile(
                        notification: notification,
                        onTap: () => _markAsRead(notification),
                      );
                    },
                  ),
                ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationItem notification;
  final VoidCallback onTap;

  const _NotificationTile({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: notification.isRead ? AppColors.background : AppColors.surface,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppColors.secondary.withOpacity(0.1),
          child: Icon(PhosphorIcons.bell(), color: AppColors.secondary),
        ),
        title: Text(
          notification.title,
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.message,
              style: AppTypography.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              _formatDate(notification.createdAt),
              style: AppTypography.bodySmall.copyWith(
                fontSize: 10,
                color: AppColors.textSecondary.withOpacity(0.7),
              ),
            ),
          ],
        ),
        trailing: !notification.isRead
            ? Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              )
            : null,
        onTap: onTap,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}
