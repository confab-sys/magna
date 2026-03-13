import 'package:flutter/material.dart';
import 'package:magna_coders/features/settings/ui/widgets/settings_empty_state.dart';
import 'package:magna_coders/features/settings/ui/widgets/settings_section_card.dart';

class PaymentHistorySettingsView extends StatelessWidget {
  const PaymentHistorySettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsSectionCard(
      title: 'Payment history',
      subtitle: 'View your recent Magna transactions.',
      child: const SettingsEmptyState(
        title: 'No payments found',
        message: 'Your Magna payment history will appear here.',
      ),
    );
  }
}

