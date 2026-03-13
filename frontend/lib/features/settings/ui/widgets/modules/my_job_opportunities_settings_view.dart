import 'package:flutter/material.dart';
import 'package:magna_coders/features/settings/ui/widgets/settings_empty_state.dart';
import 'package:magna_coders/features/settings/ui/widgets/settings_section_card.dart';

class MyJobOpportunitiesSettingsView extends StatelessWidget {
  const MyJobOpportunitiesSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsSectionCard(
      title: 'My job opportunities',
      subtitle: 'Jobs you have posted or manage.',
      child: const SettingsEmptyState(
        title: 'No jobs yet',
        message: 'Post a new opportunity to see it here.',
      ),
    );
  }
}

