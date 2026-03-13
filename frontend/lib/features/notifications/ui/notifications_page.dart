import 'package:flutter/material.dart';
import 'package:magna_coders/app/theme/colors.dart';
import 'package:magna_coders/app/theme/typography.dart';
import 'package:magna_coders/features/notifications/domain/entities/notification_entity.dart';
import 'package:magna_coders/features/notifications/ui/controllers/notifications_controller.dart';
import 'package:magna_coders/features/notifications/ui/widgets/empty_notifications_state.dart';
import 'package:magna_coders/features/notifications/ui/widgets/notification_filter_chips.dart';
import 'package:magna_coders/features/notifications/ui/widgets/notification_list_item.dart';
import 'package:magna_coders/features/notifications/ui/widgets/notification_section_header.dart';
import 'package:magna_coders/features/notifications/ui/widgets/notifications_header.dart';
import 'package:magna_coders/shared/widgets/app_loader.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late final NotificationsController _controller;
  NotificationFilter _filter = NotificationFilter.all;

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
    final entries = _buildListEntries(state);

    return Scaffold(
      backgroundColor: AppColors.background,
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
            case NotificationsStatus.refreshing:
            case NotificationsStatus.loaded:
            case NotificationsStatus.idle:
              return Column(
                children: [
                  NotificationsHeader(
                    unreadCount: state.unreadCount,
                    onRefresh: _controller.refreshNotifications,
                    onMarkAllRead: state.unreadCount > 0
                        ? () => _controller.markAllAsRead()
                        : null,
                    onClearAll: _controller.clearAll,
                  ),
                  NotificationFilterChips(
                    selected: _filter,
                    onChanged: (value) {
                      setState(() {
                        _filter = value;
                      });
                    },
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _onRefresh,
                      child: entries.isEmpty
                          ? SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: SizedBox(
                                height: MediaQuery.of(context).size.height * 0.5,
                                child: EmptyNotificationsState(
                                  onRefresh: _controller.refreshNotifications,
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.only(top: 4, bottom: 12),
                              itemCount: entries.length,
                              itemBuilder: (context, index) {
                                final entry = entries[index];
                                switch (entry.type) {
                                  case _NotificationsEntryType.sectionHeader:
                                    return NotificationSectionHeader(
                                      title: entry.sectionTitle!,
                                    );
                                  case _NotificationsEntryType.item:
                                    final notification = entry.notification!;
                                    return NotificationListItem(
                                      notification: notification,
                                      onTap: () => _controller.markAsRead(
                                        notification,
                                        context,
                                      ),
                                    );
                                }
                              },
                            ),
                    ),
                  ),
                ],
              );
          }
        },
      ),
    );
  }

  List<_NotificationsListEntry> _buildListEntries(NotificationsState state) {
    final now = DateTime.now();
    final filtered = _applyFilter(state.notifications);
    if (filtered.isEmpty) return const [];

    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final Map<String, List<NotificationEntity>> grouped = {};
    for (final notification in filtered) {
      final section = _sectionFor(notification, now);
      grouped.putIfAbsent(section, () => []).add(notification);
    }

    final entries = <_NotificationsListEntry>[];
    for (final section in ['New', 'Today', 'Yesterday', 'Earlier']) {
      final items = grouped[section];
      if (items == null || items.isEmpty) continue;
      entries.add(
        _NotificationsListEntry.section(section),
      );
      for (final n in items) {
        entries.add(_NotificationsListEntry.item(n));
      }
    }

    return entries;
  }

  List<NotificationEntity> _applyFilter(List<NotificationEntity> all) {
    switch (_filter) {
      case NotificationFilter.all:
        return List<NotificationEntity>.from(all);
      case NotificationFilter.unread:
        return all.where((n) => !n.isRead).toList();
      case NotificationFilter.activity:
        return all.where((n) {
          switch (n.notificationType) {
            case NotificationType.jobPosted:
            case NotificationType.projectPosted:
            case NotificationType.postCreated:
              return true;
            default:
              return false;
          }
        }).toList();
      case NotificationFilter.engagement:
        return all.where((n) {
          switch (n.notificationType) {
            case NotificationType.postLiked:
            case NotificationType.projectLiked:
            case NotificationType.jobLiked:
            case NotificationType.postCommented:
            case NotificationType.projectCommented:
            case NotificationType.jobCommented:
              return true;
            default:
              return false;
          }
        }).toList();
      case NotificationFilter.social:
        return all
            .where((n) => n.notificationType == NotificationType.friendRequestReceived)
            .toList();
    }
  }

  String _sectionFor(NotificationEntity notification, DateTime now) {
    if (!notification.isRead) {
      return 'New';
    }

    final created = notification.createdAt;
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(created.year, created.month, created.day);

    if (date == today) {
      return 'Today';
    }
    if (date == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    }
    return 'Earlier';
  }
}

enum _NotificationsEntryType {
  sectionHeader,
  item,
}

class _NotificationsListEntry {
  final _NotificationsEntryType type;
  final String? sectionTitle;
  final NotificationEntity? notification;

  const _NotificationsListEntry._({
    required this.type,
    this.sectionTitle,
    this.notification,
  });

  factory _NotificationsListEntry.section(String title) {
    return _NotificationsListEntry._(
      type: _NotificationsEntryType.sectionHeader,
      sectionTitle: title,
    );
  }

  factory _NotificationsListEntry.item(NotificationEntity notification) {
    return _NotificationsListEntry._(
      type: _NotificationsEntryType.item,
      notification: notification,
    );
  }
}

