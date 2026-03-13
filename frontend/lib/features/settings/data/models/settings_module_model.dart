import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

enum SettingsModuleId {
  account,
  paymentMethod,
  paymentHistory,
  myProjects,
  myJobOpportunities,
  notifications,
  privacy,
  appearance,
  security,
  localDiscovery,
  helpCenter,
}

class SettingsModule {
  final SettingsModuleId id;
  final String label;
  final String description;
  final PhosphorIconData icon;

  const SettingsModule({
    required this.id,
    required this.label,
    required this.description,
    required this.icon,
  });
}

