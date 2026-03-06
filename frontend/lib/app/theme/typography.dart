import 'package:flutter/material.dart';
import 'package:magna_coders/app/theme/colors.dart';

class AppTypography {
  static const _fontFamily = "-apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen', 'Ubuntu', 'Cantarell', 'Fira Sans', 'Droid Sans', 'Helvetica Neue', sans-serif";

  static const textTheme = TextTheme(
    displayLarge: TextStyle(fontSize: 48, fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontFamily: _fontFamily),
    displayMedium: TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontFamily: _fontFamily),
    headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontFamily: _fontFamily),
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textPrimary, fontFamily: _fontFamily),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textPrimary, fontFamily: _fontFamily),
    bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textSecondary, fontFamily: _fontFamily),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white, fontFamily: _fontFamily),
  );

  static TextStyle get h3 => textTheme.headlineSmall!;
  static TextStyle get bodyMedium => textTheme.bodyMedium!;
  static TextStyle get bodySmall => textTheme.bodySmall!;
  static TextStyle get caption => textTheme.bodySmall!.copyWith(fontSize: 11, color: AppColors.textSecondary);
}
