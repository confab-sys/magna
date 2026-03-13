import 'package:flutter/material.dart';
import 'package:magna_coders/app/theme/typography.dart';
import 'package:magna_coders/features/settings/ui/widgets/settings_section_card.dart';

class HelpCenterSettingsView extends StatelessWidget {
  const HelpCenterSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSectionCard(
          title: 'Support options',
          child: Column(
            children: [
              ListTile(
                title: const Text('Chat support'),
                subtitle:
                    const Text('Talk to the Magna team when available.'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              ListTile(
                title: const Text('Email support'),
                subtitle: const Text('Get help via email.'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ],
          ),
        ),
        SettingsSectionCard(
          title: 'Frequently asked questions',
          child: Column(
            children: const [
              _FaqRow(text: 'How do I reset my password?'),
              _FaqRow(text: 'Can I change my username?'),
              _FaqRow(text: 'How do I delete my account?'),
            ],
          ),
        ),
      ],
    );
  }
}

class _FaqRow extends StatelessWidget {
  final String text;

  const _FaqRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        text,
        style: AppTypography.bodyMedium,
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }
}

