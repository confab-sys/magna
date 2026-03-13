import 'package:flutter/material.dart';
import 'package:magna_coders/app/theme/typography.dart';
import 'package:magna_coders/features/settings/ui/widgets/settings_radio_group.dart';
import 'package:magna_coders/features/settings/ui/widgets/settings_section_card.dart';

class AppearanceSettingsView extends StatelessWidget {
  const AppearanceSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    String themeMode = 'system';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSectionCard(
          title: 'Theme',
          subtitle: 'Choose how Magna looks.',
          child: SettingsRadioGroup<String>(
            value: themeMode,
            onChanged: (_) {},
            options: [
              SettingsRadioOption(
                value: 'light',
                label: 'Light',
              ),
              SettingsRadioOption(
                value: 'dark',
                label: 'Dark',
              ),
              SettingsRadioOption(
                value: 'system',
                label: 'System',
              ),
            ],
          ),
        ),
        SettingsSectionCard(
          title: 'Accent color',
          subtitle: 'Coming soon – will let you personalize your Magna accent.',
          child: Wrap(
            spacing: 8,
            children: const [
              _AccentDot(color: Colors.redAccent),
              _AccentDot(color: Colors.orangeAccent),
              _AccentDot(color: Colors.greenAccent),
              _AccentDot(color: Colors.blueAccent),
              _AccentDot(color: Colors.purpleAccent),
            ],
          ),
        ),
      ],
    );
  }
}

class _AccentDot extends StatelessWidget {
  final Color color;

  const _AccentDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

