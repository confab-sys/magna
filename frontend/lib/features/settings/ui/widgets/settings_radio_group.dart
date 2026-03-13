import 'package:flutter/material.dart';
import 'package:magna_coders/app/theme/typography.dart';

class SettingsRadioOption<T> {
  final T value;
  final String label;
  final String? description;

  SettingsRadioOption({
    required this.value,
    required this.label,
    this.description,
  });
}

class SettingsRadioGroup<T> extends StatelessWidget {
  final T value;
  final List<SettingsRadioOption<T>> options;
  final ValueChanged<T> onChanged;

  const SettingsRadioGroup({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: options
          .map(
            (o) => RadioListTile<T>(
              value: o.value,
              groupValue: value,
              onChanged: (val) {
                if (val != null) onChanged(val);
              },
              title: Text(
                o.label,
                style: AppTypography.bodyMedium,
              ),
              subtitle: o.description != null
                  ? Text(
                      o.description!,
                      style: AppTypography.caption,
                    )
                  : null,
            ),
          )
          .toList(),
    );
  }
}

