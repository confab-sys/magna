import 'package:flutter/material.dart';
import 'package:magna_coders/app/theme/typography.dart';
import 'package:magna_coders/features/settings/ui/widgets/settings_section_card.dart';
import 'package:magna_coders/features/settings/ui/widgets/settings_toggle_row.dart';
import 'package:magna_coders/app/theme/colors.dart';

class LocalDiscoverySettingsView extends StatelessWidget {
  const LocalDiscoverySettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    double radius = 50;
    bool enabled = false;

    return SettingsSectionCard(
      title: 'Local discovery',
      subtitle: 'Control how Magna uses your approximate location.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SettingsToggleRow(
            title: 'Enable location-based discovery',
            subtitle: 'Show relevant builders, jobs, and projects near you.',
            value: enabled,
            onChanged: (_) {},
          ),
          const SizedBox(height: 12),
          Text(
            'Discovery radius',
            style: AppTypography.bodyMedium,
          ),
          Slider(
            value: radius,
            min: 10,
            max: 200,
            divisions: 19,
            label: '${radius.round()} km',
            onChanged: (_) {},
          ),
          Text(
            'Map preview coming soon.',
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

