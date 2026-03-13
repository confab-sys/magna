import 'package:flutter/material.dart';
import 'package:magna_coders/app/theme/colors.dart';
import 'package:magna_coders/app/theme/typography.dart';

enum NotificationFilter {
  all,
  unread,
  activity,
  engagement,
  social,
}

class NotificationFilterChips extends StatelessWidget {
  final NotificationFilter selected;
  final ValueChanged<NotificationFilter> onChanged;

  const NotificationFilterChips({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          _buildChip('All', NotificationFilter.all),
          _buildChip('Unread', NotificationFilter.unread),
          _buildChip('Activity', NotificationFilter.activity),
          _buildChip('Engagement', NotificationFilter.engagement),
          _buildChip('Social', NotificationFilter.social),
        ],
      ),
    );
  }

  Widget _buildChip(String label, NotificationFilter filter) {
    final isSelected = filter == selected;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: isSelected ? AppColors.background : AppColors.textSecondary,
          ),
        ),
        selected: isSelected,
        onSelected: (_) => onChanged(filter),
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.surface,
        shape: StadiumBorder(
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
      ),
    );
  }
}

