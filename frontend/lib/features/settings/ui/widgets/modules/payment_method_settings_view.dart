import 'package:flutter/material.dart';
import 'package:magna_coders/features/settings/ui/widgets/settings_empty_state.dart';
import 'package:magna_coders/features/settings/ui/widgets/settings_section_card.dart';

class PaymentMethodSettingsView extends StatelessWidget {
  const PaymentMethodSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsSectionCard(
      title: 'Payment methods',
      subtitle: 'Manage the ways you pay and receive payouts.',
      child: const SettingsEmptyState(
        title: 'No payment methods yet',
        message: 'When you add a payment method, it will appear here.',
      ),
    );
  }
}

