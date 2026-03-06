import 'package:flutter/material.dart';
import 'package:magna_coders/app/theme/spacing.dart';
import 'package:magna_coders/app/theme/typography.dart';

class JobFormSection extends StatelessWidget {
  final String title;
  final Widget child;
  final bool isRequired;

  const JobFormSection({
    super.key,
    required this.title,
    required this.child,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: AppTypography.h3,
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        child,
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}
