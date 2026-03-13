import 'package:flutter/material.dart';
import 'package:magna_coders/app/theme/colors.dart';
import 'package:magna_coders/app/theme/typography.dart';

import '../../data/constants/settings_modules.dart';
import '../../data/models/settings_module_model.dart';

class SettingsNavigation extends StatelessWidget {
  final SettingsModuleId active;
  final ValueChanged<SettingsModuleId> onSelected;

  const SettingsNavigation({
    super.key,
    required this.active,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final modules = SettingsModules.all;

    return Container(
      width: 260,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: modules.length,
        separatorBuilder: (_, __) => Divider(
          color: AppColors.border.withOpacity(0.4),
          height: 1,
        ),
        itemBuilder: (context, index) {
          final module = modules[index];
          final isActive = module.id == active;
          return _NavRow(
            module: module,
            isActive: isActive,
            onTap: () => onSelected(module.id),
          );
        },
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  final SettingsModule module;
  final bool isActive;
  final VoidCallback onTap;

  const _NavRow({
    required this.module,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor =
        isActive ? AppColors.primary.withOpacity(0.08) : Colors.transparent;
    final dotColor = isActive ? AppColors.primary : AppColors.border;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        color: bgColor,
        child: Row(
          children: [
            Icon(
              module.icon,
              size: 18,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    module.label,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    module.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dotColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

