import 'package:flutter/material.dart';
import 'package:magna_coders/app/theme/colors.dart';
import 'package:magna_coders/app/theme/typography.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class MagnaAiHeader extends StatelessWidget {
  final VoidCallback? onPanelToggle;
  final bool showPanelToggle;

  const MagnaAiHeader({
    super.key,
    this.onPanelToggle,
    this.showPanelToggle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: [
          if (showPanelToggle)
            IconButton(
              icon: Icon(PhosphorIcons.list(), color: AppColors.textPrimary),
              onPressed: onPanelToggle,
            ),
          const SizedBox(width: 8),
          Icon(PhosphorIcons.robot(), color: AppColors.primary, size: 24),
          const SizedBox(width: 8),
          Text(
            'Magna AI',
            style: AppTypography.h3.copyWith(fontSize: 18),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(PhosphorIcons.dotsThreeVertical(), color: AppColors.textSecondary),
            onPressed: () {}, // TODO: Menu actions
          ),
        ],
      ),
    );
  }
}
