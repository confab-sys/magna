import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../models/settings_module_model.dart';

class SettingsModules {
  static final all = <SettingsModule>[
    SettingsModule(
      id: SettingsModuleId.account,
      label: 'Account',
      description: 'Profile, identity, and connected accounts',
      icon: PhosphorIcons.user(),
    ),
    SettingsModule(
      id: SettingsModuleId.paymentMethod,
      label: 'Payment Method',
      description: 'Manage how you pay and get paid',
      icon: PhosphorIcons.creditCard(),
    ),
    SettingsModule(
      id: SettingsModuleId.paymentHistory,
      label: 'Payment History',
      description: 'View receipts and transaction history',
      icon: PhosphorIcons.receipt(),
    ),
    SettingsModule(
      id: SettingsModuleId.myProjects,
      label: 'My Projects',
      description: 'Manage projects linked to your account',
      icon: PhosphorIcons.briefcase(),
    ),
    SettingsModule(
      id: SettingsModuleId.myJobOpportunities,
      label: 'My Job Opportunities',
      description: 'Review and manage your posted jobs',
      icon: PhosphorIcons.suitcaseSimple(),
    ),
    SettingsModule(
      id: SettingsModuleId.notifications,
      label: 'Notifications',
      description: 'Control how Magna contacts you',
      icon: PhosphorIcons.bell(),
    ),
    SettingsModule(
      id: SettingsModuleId.privacy,
      label: 'Privacy',
      description: 'Profile visibility and data preferences',
      icon: PhosphorIcons.lockSimple(),
    ),
    SettingsModule(
      id: SettingsModuleId.appearance,
      label: 'Appearance',
      description: 'Theme and accent color',
      icon: PhosphorIcons.paintBrushBroad(),
    ),
    SettingsModule(
      id: SettingsModuleId.security,
      label: 'Security',
      description: 'Passwords, 2FA, and account safety',
      icon: PhosphorIcons.shieldCheck(),
    ),
    SettingsModule(
      id: SettingsModuleId.localDiscovery,
      label: 'Local Discovery',
      description: 'Location-based networking and radius',
      icon: PhosphorIcons.mapPin(),
    ),
    SettingsModule(
      id: SettingsModuleId.helpCenter,
      label: 'Help Center',
      description: 'Support, FAQs, and contact options',
      icon: PhosphorIcons.chatCircleDots(),
    ),
  ];
}

