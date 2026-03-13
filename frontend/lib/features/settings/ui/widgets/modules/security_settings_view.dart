import 'package:flutter/material.dart';
import 'package:magna_coders/app/theme/colors.dart';
import 'package:magna_coders/app/theme/typography.dart';
import 'package:magna_coders/features/settings/ui/widgets/settings_section_card.dart';

class SecuritySettingsView extends StatelessWidget {
  const SecuritySettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSectionCard(
          title: 'Two-factor authentication',
          subtitle: 'Add an extra layer of security to your account.',
          child: Text(
            '2FA setup will be integrated here once backend support is available.',
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        SettingsSectionCard(
          title: 'Password',
          subtitle: 'Change your Magna password.',
          child: Text(
            'Password change is currently handled via the security/forgot-password flow.',
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

