import 'package:flutter/material.dart';

class AppColors {
  AppColors._();
  static const Color brand = Color(0xFF4A6CF7);
  static const Color brandLight = Color(0xFF6E8BFF);
  static const Color brandDark = Color(0xFF5B7BFF);
  static const Color warning = Color(0xFFF59E0B);
  static const Color success = Color(0xFF22C55E);
  static const Color danger = Color(0xFFEF4444);

  // Light
  static const Color lBackground = Color(0xFFF5F6FA);
  static const Color lCard = Color(0xFFFFFFFF);
  static const Color lBorder = Color(0xFFE6E8EF);
  static const Color lDivider = Color(0xFFEDEFF4);
  static const Color lTextPrimary = Color(0xFF14161C);
  static const Color lTextSecondary = Color(0xFF5B6472);
  static const Color lTextHint = Color(0xFF9AA1AE);

  // Dark
  static const Color dBackground = Color(0xFF0E1116);
  static const Color dCard = Color(0xFF171A21);
  static const Color dBorder = Color(0xFF272C36);
  static const Color dDivider = Color(0xFF222732);
  static const Color dTextPrimary = Color(0xFFE7E9EE);
  static const Color dTextSecondary = Color(0xFF9AA3AF);
  static const Color dTextHint = Color(0xFF6B7280);
}

class ColorManager {
  final Color background, card, border, divider, primary, primaryLight, error,
      textPrimary, textSecondary, textHint;

  const ColorManager({
    required this.background,
    required this.card,
    required this.border,
    required this.divider,
    required this.primary,
    required this.primaryLight,
    required this.error,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
  });

  static const light = ColorManager(
    background: AppColors.lBackground, card: AppColors.lCard, border: AppColors.lBorder,
    divider: AppColors.lDivider, primary: AppColors.brand, primaryLight: AppColors.brandLight,
    error: AppColors.danger, textPrimary: AppColors.lTextPrimary,
    textSecondary: AppColors.lTextSecondary, textHint: AppColors.lTextHint,
  );

  static const dark = ColorManager(
    background: AppColors.dBackground, card: AppColors.dCard, border: AppColors.dBorder,
    divider: AppColors.dDivider, primary: AppColors.brandDark, primaryLight: AppColors.brandLight,
    error: AppColors.danger, textPrimary: AppColors.dTextPrimary,
    textSecondary: AppColors.dTextSecondary, textHint: AppColors.dTextHint,
  );

  static ColorManager of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;

  ColorScheme scheme(Brightness b) =>
      ColorScheme.fromSeed(seedColor: AppColors.brand, brightness: b).copyWith(
        primary: primary, onPrimary: Colors.white, surface: card, onSurface: textPrimary, error: error,
      );
}
