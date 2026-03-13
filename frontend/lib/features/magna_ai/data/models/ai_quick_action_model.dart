import 'package:flutter/material.dart';

class AIQuickAction {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final String prompt;

  const AIQuickAction({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.prompt,
  });
}
