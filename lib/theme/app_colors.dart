import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ---------- shared across themes ----------
  static const Color primary = Color(0xFF4A6CF7);
  static const Color primaryLight = Color(0xFF7B93FA);
  static const Color primaryDark = Color(0xFF2C4BD6);
  static const Color secondary = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color success = Color(0xFF16A34A);

  // ---------- Light palette ----------
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF7F8FA);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E5EA);
  static const Color lightTextPrimary = Color(0xFF1A1C1E);
  static const Color lightTextSecondary = Color(0xFF5F6368);
  static const Color lightTextHint = Color(0xFF9AA0A6);
  static const Color lightDivider = Color(0xFFE8EAED);
  static const Color lightDisabled = Color(0xFFD1D5DB);

  // ---------- Dark palette ----------
  static const Color darkBackground = Color(0xFF121316);
  static const Color darkSurface = Color(0xFF1C1E22);
  static const Color darkCard = Color(0xFF23262B);
  static const Color darkBorder = Color(0xFF33363B);
  static const Color darkTextPrimary = Color(0xFFF3F4F6);
  static const Color darkTextSecondary = Color(0xFFB0B4BA);
  static const Color darkTextHint = Color(0xFF7B7F87);
  static const Color darkDivider = Color(0xFF2C2F34);
  static const Color darkDisabled = Color(0xFF4B4F56);
}

class ColorManager {
  final Brightness brightness;
  const ColorManager(this.brightness);

  factory ColorManager.of(BuildContext context) =>
      ColorManager(Theme.of(context).brightness);

  bool get isDark => brightness == Brightness.dark;

  Color get background => isDark ? AppColors.darkBackground : AppColors.lightBackground;
  Color get surface => isDark ? AppColors.darkSurface : AppColors.lightSurface;
  Color get card => isDark ? AppColors.darkCard : AppColors.lightCard;
  Color get border => isDark ? AppColors.darkBorder : AppColors.lightBorder;
  Color get divider => isDark ? AppColors.darkDivider : AppColors.lightDivider;
  Color get disabled => isDark ? AppColors.darkDisabled : AppColors.lightDisabled;

  Color get textPrimary => isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
  Color get textSecondary => isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
  Color get textHint => isDark ? AppColors.darkTextHint : AppColors.lightTextHint;

  Color get primary => AppColors.primary;
  Color get primaryLight => AppColors.primaryLight;
  Color get error => AppColors.error;
  Color get success => AppColors.success;
  Color get warning => AppColors.warning;
}
