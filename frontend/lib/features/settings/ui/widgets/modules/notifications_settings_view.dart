import 'package:flutter/material.dart';
import 'package:magna_coders/features/settings/ui/widgets/settings_section_card.dart';
import 'package:magna_coders/features/settings/ui/widgets/settings_toggle_row.dart';

class NotificationsSettingsView extends StatelessWidget {
  const NotificationsSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    bool email = true;
    bool push = true;
    bool weekly = false;
    bool applicants = true;
    bool marketing = false;

    return SettingsSectionCard(
      title: 'Notifications',
      subtitle: 'Choose how Magna keeps you informed.',
      child: Column(
        children: [
          SettingsToggleRow(
            title: 'Email notifications',
            subtitle: 'Get important updates in your inbox.',
            value: email,
            onChanged: (_) {},
          ),
          SettingsToggleRow(
            title: 'Push notifications',
            subtitle: 'Receive alerts on your devices.',
            value: push,
            onChanged: (_) {},
          ),
          SettingsToggleRow(
            title: 'Weekly digest',
            subtitle: 'A curated weekly summary of your activity.',
            value: weekly,
            onChanged: (_) {},
          ),
          SettingsToggleRow(
            title: 'New applicants',
            subtitle: 'Alerts when new people apply to your jobs.',
            value: applicants,
            onChanged: (_) {},
          ),
          SettingsToggleRow(
            title: 'Marketing emails',
            subtitle: 'Occasional product and community updates.',
            value: marketing,
            onChanged: (_) {},
          ),
        ],
      ),
    );
  }
}

