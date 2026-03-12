import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:magna_coders/app/theme/colors.dart';
import 'package:magna_coders/app/theme/typography.dart';
import 'package:magna_coders/features/messages/ui/controllers/messages_inbox_controller.dart';
import 'package:magna_coders/features/messages/ui/widgets/conversation_list_item.dart';
import 'package:magna_coders/features/messages/ui/widgets/empty_messages_state.dart';
import 'package:magna_coders/shared/widgets/app_loader.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../domain/entities/conversation_entity.dart';

enum ConversationFilter {
  all,
  direct,
  groups,
  archived,
  discover,
  unread,
}

class MessagesInboxPage extends StatefulWidget {
  const MessagesInboxPage({super.key});

  @override
  State<MessagesInboxPage> createState() => _MessagesInboxPageState();
}

class _MessagesInboxPageState extends State<MessagesInboxPage> {
  late final MessagesInboxController _controller;
  ConversationFilter _selectedFilter = ConversationFilter.all;

  @override
  void initState() {
    super.initState();
    _controller = MessagesInboxController()..addListener(_onStateChanged);
    _controller.loadConversations();
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
    return _controller.loadConversations(refresh: true);
  }

  void _onFilterSelected(ConversationFilter filter) {
    if (filter == ConversationFilter.discover) {
      context.push('/messages/discover-groups');
      return;
    }

    setState(() {
      _selectedFilter = filter;
    });
  }

  List<ConversationEntity> _filteredConversations(MessagesInboxState state) {
    final items = state.conversations;

    switch (_selectedFilter) {
      case ConversationFilter.all:
        return items.where((c) => !c.isArchived).toList();
      case ConversationFilter.direct:
        return items
            .where(
              (c) => !c.isArchived && c.conversationType == 'direct',
            )
            .toList();
      case ConversationFilter.groups:
        return items
            .where(
              (c) => !c.isArchived && c.conversationType == 'group',
            )
            .toList();
      case ConversationFilter.archived:
        return items.where((c) => c.isArchived).toList();
      case ConversationFilter.unread:
        return items
            .where(
              (c) => !c.isArchived && c.unreadCount > 0,
            )
            .toList();
      case ConversationFilter.discover:
        return items.where((c) => !c.isArchived).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = _controller.state;
    final conversations = _filteredConversations(state);

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/messages/new'),
        backgroundColor: AppColors.primary,
        child: PhosphorIcon(
          PhosphorIcons.plus(),
          color: Colors.white,
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Messages',
                          style: AppTypography.h3,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Inbox',
                          style: AppTypography.caption,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: PhosphorIcon(
                      PhosphorIcons.magnifyingGlass(),
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () {
                      // Reserved for future full-screen search.
                    },
                  ),
                  IconButton(
                    icon: PhosphorIcon(
                      PhosphorIcons.dotsThreeOutlineVertical(),
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () {
                      // Reserved for future menu actions.
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _ConversationFiltersBar(
              selected: _selectedFilter,
              onSelected: _onFilterSelected,
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Builder(
                builder: (context) {
                  switch (state.status) {
                    case InboxStatus.loading:
                      return const AppLoader();
                    case InboxStatus.error:
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                state.errorMessage ?? 'Something went wrong',
                                style: AppTypography.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: _controller.loadConversations,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      );
                    case InboxStatus.empty:
                      return EmptyMessagesState(onRefresh: _onRefresh);
                    case InboxStatus.loaded:
                    case InboxStatus.refreshing:
                    case InboxStatus.idle:
                      if (conversations.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              'No conversations for this filter yet.',
                              style: AppTypography.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: _onRefresh,
                        child: ListView.separated(
                          padding: const EdgeInsets.only(top: 4, bottom: 12),
                          itemCount: conversations.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 4),
                          itemBuilder: (context, index) {
                            final conversation = conversations[index];
                            return ConversationListItem(
                              conversation: conversation,
                              onTap: () {
                                context.push(
                                  '/messages/conversation/${conversation.id}',
                                  extra: {
                                    'builderName': conversation.name,
                                    'builderAvatarUrl': conversation.avatarUrl,
                                  },
                                );
                              },
                            );
                          },
                        ),
                      );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConversationFiltersBar extends StatelessWidget {
  final ConversationFilter selected;
  final ValueChanged<ConversationFilter> onSelected;

  const _ConversationFiltersBar({
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _FilterChip(
              label: 'All',
              isActive: selected == ConversationFilter.all,
              onTap: () => onSelected(ConversationFilter.all),
            ),
            _FilterChip(
              label: 'Direct',
              isActive: selected == ConversationFilter.direct,
              onTap: () => onSelected(ConversationFilter.direct),
            ),
            _FilterChip(
              label: 'Groups',
              isActive: selected == ConversationFilter.groups,
              onTap: () => onSelected(ConversationFilter.groups),
            ),
            _FilterChip(
              label: 'Archived',
              isActive: selected == ConversationFilter.archived,
              onTap: () => onSelected(ConversationFilter.archived),
            ),
            _FilterChip(
              label: 'Discover',
              isActive: selected == ConversationFilter.discover,
              onTap: () => onSelected(ConversationFilter.discover),
            ),
            _FilterChip(
              label: 'Unread',
              isActive: selected == ConversationFilter.unread,
              onTap: () => onSelected(ConversationFilter.unread),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor =
        isActive ? AppColors.surface.withOpacity(0.9) : Colors.transparent;
    final textColor =
        isActive ? AppColors.textPrimary : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isActive
                  ? AppColors.primary.withOpacity(0.6)
                  : AppColors.border,
            ),
          ),
          child: Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: textColor,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}


