import 'package:flutter/material.dart';
import 'package:magna_coders/app/theme/colors.dart';
import 'package:magna_coders/app/theme/typography.dart';
import 'package:magna_coders/shared/widgets/primary_button.dart';

class UserGuideFooter extends StatelessWidget {
  final bool canGoBack;
  final bool canGoNext;
  final bool isLastStep;
  final bool canComplete;
  final VoidCallback onBack;
  final VoidCallback onNextOrComplete;

  const UserGuideFooter({
    super.key,
    required this.canGoBack,
    required this.canGoNext,
    required this.isLastStep,
    required this.canComplete,
    required this.onBack,
    required this.onNextOrComplete,
  });

  @override
  Widget build(BuildContext context) {
    final label = isLastStep ? 'Complete' : 'Next';
    final enabled = isLastStep ? canComplete : canGoNext;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          color: AppColors.background,
          border: Border(
            top: BorderSide(color: AppColors.border.withOpacity(0.7)),
          ),
        ),
        child: Row(
          children: [
            TextButton(
              onPressed: canGoBack ? onBack : null,
              child: Text(
                'Back',
                style: AppTypography.bodyMedium.copyWith(
                  color: canGoBack ? AppColors.textSecondary : AppColors.textSecondary.withOpacity(0.4),
                ),
              ),
            ),
            const Spacer(),
            PrimaryButton(
              label: label,
              onPressed: enabled ? onNextOrComplete : null,
              loading: false,
            ),
          ],
        ),
      ),
    );
  }
}

