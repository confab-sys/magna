import 'package:flutter/material.dart';
import 'package:magna_coders/app/theme/colors.dart';
import 'package:magna_coders/app/theme/typography.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../data/models/user_guide_constants.dart';
import '../user_guide_step_shell.dart';

class RolesStep extends StatelessWidget {
  final List<String> selectedRoles;
  final void Function(String roleId) onRoleToggled;

  const RolesStep({
    super.key,
    required this.selectedRoles,
    required this.onRoleToggled,
  });

  @override
  Widget build(BuildContext context) {
    return UserGuideStepShell(
      title: 'What describes you best?',
      subtitle: 'Pick up to 2 roles that feel closest to where you are.',
      child: Column(
        children: [
          for (final role in UserGuideConstants.roles) ...[
            _RoleCard(
              role: role,
              isSelected: selectedRoles.contains(role.id),
              onTap: () => onRoleToggled(role.id),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final UserGuideRole role;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.role,
    required this.isSelected,
    required this.onTap,
  });

  IconData _iconFor(String iconName) {
    switch (iconName) {
      case 'lightbulb':
        return PhosphorIcons.lightbulb();
      case 'code':
        return PhosphorIcons.code();
      case 'palette':
        return PhosphorIcons.palette();
      case 'trending_up':
        return PhosphorIcons.trendUp();
      case 'sprout':
        return PhosphorIcons.leaf();
      case 'graduation_cap':
        return PhosphorIcons.graduationCap();
      case 'user_plus':
        return PhosphorIcons.userPlus();
      case 'line_chart':
        return PhosphorIcons.chartLineUp();
      case 'briefcase':
        return PhosphorIcons.briefcase();
      case 'headphones':
        return PhosphorIcons.headphones();
      default:
        return PhosphorIcons.user();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = isSelected ? AppColors.primary.withOpacity(0.08) : AppColors.background;
    final borderColor = isSelected ? AppColors.primary : AppColors.border;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface,
              ),
              child: PhosphorIcon(
                _iconFor(role.iconName),
                size: 20,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          role.label,
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.border,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? Container(
                                margin: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primary,
                                ),
                              )
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    role.description,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

