import 'package:flutter/material.dart';
import 'package:magna_coders/app/theme/typography.dart';
import 'package:magna_coders/app/theme/colors.dart';

class EmptyNotificationsState extends StatelessWidget {
  final VoidCallback onRefresh;

  const EmptyNotificationsState({
    super.key,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'No notifications',
              style: AppTypography.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'You\'re all caught up. When something happens, you\'ll see it here.',
              style: AppTypography.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onRefresh,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.border),
              ),
              child: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}

