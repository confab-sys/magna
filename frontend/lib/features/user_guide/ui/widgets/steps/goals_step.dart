import 'package:flutter/material.dart';
import 'package:magna_coders/app/theme/colors.dart';
import 'package:magna_coders/app/theme/typography.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../data/models/user_guide_constants.dart';
import '../user_guide_step_shell.dart';

class GoalsStep extends StatelessWidget {
  final List<String> selectedGoals;
  final void Function(String goalId) onGoalToggled;

  const GoalsStep({
    super.key,
    required this.selectedGoals,
    required this.onGoalToggled,
  });

  @override
  Widget build(BuildContext context) {
    return UserGuideStepShell(
      title: 'What are you looking for?',
      subtitle: 'Choose up to 3 goals you care about right now.',
      child: Column(
        children: [
          for (final goal in UserGuideConstants.goals) ...[
            _GoalCard(
              goal: goal,
              isSelected: selectedGoals.contains(goal.id),
              onTap: () => onGoalToggled(goal.id),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final UserGuideGoal goal;
  final bool isSelected;
  final VoidCallback onTap;

  const _GoalCard({
    required this.goal,
    required this.isSelected,
    required this.onTap,
  });

  IconData _iconFor(String iconName) {
    switch (iconName) {
      case 'users':
        return PhosphorIcons.users();
      case 'handshake':
        return PhosphorIcons.handshake();
      case 'graduation_cap':
        return PhosphorIcons.graduationCap();
      case 'globe':
        return PhosphorIcons.globe();
      case 'dollar_sign':
        return PhosphorIcons.currencyDollar();
      case 'code':
        return PhosphorIcons.code();
      case 'palette':
        return PhosphorIcons.palette();
      default:
        return PhosphorIcons.star();
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
                _iconFor(goal.iconName),
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
                          goal.label,
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
                    goal.description,
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

