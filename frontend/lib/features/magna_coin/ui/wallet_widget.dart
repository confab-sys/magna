import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:magna_coders/app/theme/colors.dart';
import 'package:magna_coders/app/theme/typography.dart';

class WalletWidget extends StatelessWidget {
  final double balance;

  const WalletWidget({super.key, this.balance = 0.0});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Magna Coin',
                style: AppTypography.bodyMedium.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(PhosphorIcons.coins(), color: Colors.white),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${balance.toStringAsFixed(2)} MC',
            style: AppTypography.h3.copyWith(
              color: Colors.white,
              fontSize: 32,
            ),
          ),
        ],
      ),
    );
  }
}
