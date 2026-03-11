import 'package:flutter/material.dart';
import 'package:magna_coders/app/theme/colors.dart';

class OnlineStatusDot extends StatelessWidget {
  final bool isOnline;
  final double size;

  const OnlineStatusDot({
    super.key,
    required this.isOnline,
    this.size = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.background,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Container(
        width: size - 3,
        height: size - 3,
        decoration: BoxDecoration(
          color: isOnline ? AppColors.success : AppColors.border,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

