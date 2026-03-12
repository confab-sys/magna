import 'package:flutter/material.dart';
import 'package:magna_coders/app/theme/colors.dart';
import 'package:magna_coders/app/theme/typography.dart';
import 'package:magna_coders/features/notifications/ui/controllers/notifications_controller.dart';
import 'package:magna_coders/features/notifications/ui/widgets/empty_notifications_state.dart';
import 'package:magna_coders/features/notifications/ui/widgets/notification_list_item.dart';
import 'package:magna_coders/shared/widgets/app_loader.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late final NotificationsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = NotificationsController()..addListener(_onStateChanged);
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.removeListener(_onStateChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _onRefresh() {
    return _controller.refreshNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final state = _controller.state;
    final hasNotifications = state.notifications.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Notifications'),
            if (state.unreadCount > 0)
              Text(
                '${state.unreadCount} unread',
                style: AppTypography.caption,
              ),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.refreshNotifications(),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          switch (state.status) {
            case NotificationsStatus.loading:
              return const AppLoader();
            case NotificationsStatus.error:
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        state.errorMessage ?? 'Failed to load notifications',
                        style: AppTypography.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _controller.refreshNotifications,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            case NotificationsStatus.empty:
              return EmptyNotificationsState(onRefresh: _controller.refreshNotifications);
            case NotificationsStatus.refreshing:
            case NotificationsStatus.loaded:
            case NotificationsStatus.idle:
              if (!hasNotifications) {
                return EmptyNotificationsState(onRefresh: _controller.refreshNotifications);
              }

              return RefreshIndicator(
                onRefresh: _onRefresh,
                child: ListView.separated(
                  padding: const EdgeInsets.only(top: 4, bottom: 12),
                  itemCount: state.notifications.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final notification = state.notifications[index];
                    return NotificationListItem(
                      notification: notification,
                      onTap: () => _controller.markAsRead(notification),
                    );
                  },
                ),
              );
          }
        },
      ),
    );
  }
}

