import 'package:flutter/material.dart';
import 'package:magna_coders/app/theme/typography.dart';
import 'package:magna_coders/features/settings/ui/widgets/settings_radio_group.dart';
import 'package:magna_coders/features/settings/ui/widgets/settings_section_card.dart';
import 'package:magna_coders/features/settings/ui/widgets/settings_toggle_row.dart';

class PrivacySettingsView extends StatelessWidget {
  const PrivacySettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    String profileVisibility = 'public';
    bool showEmail = false;
    bool allowSearch = true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSectionCard(
          title: 'Profile visibility',
          subtitle: 'Control who can see your profile.',
          child: SettingsRadioGroup<String>(
            value: profileVisibility,
            onChanged: (_) {},
            options: [
              SettingsRadioOption(
                value: 'public',
                label: 'Public',
                description: 'Anyone on Magna can view your profile.',
              ),
              SettingsRadioOption(
                value: 'private',
                label: 'Private',
                description: 'Only you can see your profile.',
              ),
            ],
          ),
        ),
        SettingsSectionCard(
          title: 'Data visibility',
          child: Column(
            children: [
              SettingsToggleRow(
                title: 'Show email address',
                subtitle: 'Display your email on your public profile.',
                value: showEmail,
                onChanged: (_) {},
              ),
              SettingsToggleRow(
                title: 'Allow search engines',
                subtitle: 'Allow external search engines to index your profile.',
                value: allowSearch,
                onChanged: (_) {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}

