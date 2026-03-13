import 'package:flutter/material.dart';
import 'package:magna_coders/app/theme/colors.dart';
import 'package:magna_coders/app/theme/typography.dart';

class UserGuideBottomBar extends StatelessWidget {
  final bool canGoBack;
  final bool canGoNext;
  final bool isLastStep;
  final bool canComplete;
  final int currentStep;
  final int totalSteps;
  final VoidCallback onBack;
  final VoidCallback onNextOrComplete;

  const UserGuideBottomBar({
    super.key,
    required this.canGoBack,
    required this.canGoNext,
    required this.isLastStep,
    required this.canComplete,
    required this.currentStep,
    required this.totalSteps,
    required this.onBack,
    required this.onNextOrComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: canGoBack ? onBack : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.border,
                      disabledBackgroundColor: AppColors.border.withOpacity(0.5),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Back',
                      style: AppTypography.bodyMedium.copyWith(
                        color: canGoBack ? AppColors.textPrimary : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: (isLastStep ? canComplete : canGoNext) ? onNextOrComplete : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      isLastStep ? 'Complete' : 'Next',
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Step ${currentStep + 1} of $totalSteps',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
