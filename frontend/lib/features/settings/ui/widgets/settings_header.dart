import 'package:flutter/material.dart';
import 'package:magna_coders/app/theme/colors.dart';
import 'package:magna_coders/app/theme/typography.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class SettingsHeader extends StatelessWidget {
  final bool showMobileMenu;
  final VoidCallback? onMobileMenuPressed;

  const SettingsHeader({
    super.key,
    required this.showMobileMenu,
    this.onMobileMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Settings',
                  style: AppTypography.h3,
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage your account, privacy, appearance, and preferences.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (showMobileMenu)
            IconButton(
              icon: PhosphorIcon(
                PhosphorIcons.slidersHorizontal(),
                color: AppColors.textSecondary,
              ),
              onPressed: onMobileMenuPressed,
            ),
        ],
      ),
    );
  }
}

