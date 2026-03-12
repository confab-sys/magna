import 'package:flutter/material.dart';
import 'package:magna_coders/app/theme/colors.dart';

class NotificationUnreadDot extends StatelessWidget {
  const NotificationUnreadDot({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
    );
  }
}

