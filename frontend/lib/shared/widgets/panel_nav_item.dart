import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:magna_coders/app/theme/colors.dart';
import 'package:magna_coders/app/theme/typography.dart';

class PanelNavItem extends StatelessWidget {
  final PhosphorIconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isActive;
  final Color? activeBackgroundColor;
  final Color? inactiveTextColor;

  const PanelNavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isActive = false,
    this.activeBackgroundColor,
    this.inactiveTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final activeBg = activeBackgroundColor ?? AppColors.primary.withOpacity(0.15);
    final textColor =
        isActive ? AppColors.textPrimary : (inactiveTextColor ?? AppColors.textSecondary);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        highlightColor: AppColors.primary.withOpacity(0.1),
        splashColor: AppColors.primary.withOpacity(0.05),
        child: Container(
          decoration: BoxDecoration(
            color: isActive ? activeBg : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isActive
                ? Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 1.5,
                  )
                : null,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              PhosphorIcon(
                icon,
                color: isActive ? AppColors.primary : textColor,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.bodySmall.copyWith(
                    color: textColor,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
