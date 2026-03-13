import 'package:flutter/material.dart';
import 'package:magna_coders/app/theme/colors.dart';
import 'package:magna_coders/app/theme/typography.dart';

import '../../../data/models/user_guide_constants.dart';
import '../user_guide_step_shell.dart';

class GenderStep extends StatelessWidget {
  final String? selectedGender;
  final ValueChanged<String> onGenderSelected;

  const GenderStep({
    super.key,
    required this.selectedGender,
    required this.onGenderSelected,
  });

  @override
  Widget build(BuildContext context) {
    final genderOptions = UserGuideConstants.genders;
    debugPrint('🔴 GenderStep.build - genderOptions.length: ${genderOptions.length}, selectedGender: $selectedGender');
    
    return UserGuideStepShell(
      title: 'How do you identify?',
      subtitle: 'This helps us personalize your experience.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.max,
        children: [
          for (int i = 0; i < genderOptions.length; i++) ...[
            _SelectionCard(
              label: genderOptions[i],
              isSelected: selectedGender == genderOptions[i],
              onTap: () => onGenderSelected(genderOptions[i]),
            ),
            if (i < genderOptions.length - 1) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _SelectionCard extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectionCard({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.background;
    final borderColor = isSelected ? AppColors.primary : AppColors.border;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodyMedium,
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? AppColors.primary : Colors.transparent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

