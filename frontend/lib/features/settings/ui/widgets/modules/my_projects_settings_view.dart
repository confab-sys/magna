import 'package:flutter/material.dart';
import 'package:magna_coders/features/settings/ui/widgets/settings_empty_state.dart';
import 'package:magna_coders/features/settings/ui/widgets/settings_section_card.dart';

class MyProjectsSettingsView extends StatelessWidget {
  const MyProjectsSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsSectionCard(
      title: 'My projects',
      subtitle: 'Projects linked to your Magna account.',
      child: const SettingsEmptyState(
        title: 'No projects yet',
        message: 'Projects you create or link will be shown here.',
      ),
    );
  }
}

