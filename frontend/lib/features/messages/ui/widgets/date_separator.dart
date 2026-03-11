import 'package:flutter/material.dart';
import 'package:magna_coders/app/theme/colors.dart';
import 'package:magna_coders/app/theme/typography.dart';
import 'package:intl/intl.dart';

class DateSeparator extends StatelessWidget {
  final DateTime date;

  const DateSeparator({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat.yMMMMd();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Expanded(
            child: Divider(color: AppColors.border),
          ),
          const SizedBox(width: 8),
          Text(
            formatter.format(date),
            style: AppTypography.caption,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Divider(color: AppColors.border),
          ),
        ],
      ),
    );
  }
}

