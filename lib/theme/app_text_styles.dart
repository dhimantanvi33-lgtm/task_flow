import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle _base({
    required double size,
    required FontWeight weight,
    required Color color,
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle heading1(BuildContext context) => _base(
    size: 32,
    weight: FontWeight.bold,
    color: ColorManager.of(context).textPrimary,
    height: 1.2,
  );

  static TextStyle heading2(BuildContext context) => _base(
    size: 26,
    weight: FontWeight.bold,
    color: ColorManager.of(context).textPrimary,
    height: 1.25,
  );

  static TextStyle heading3(BuildContext context) => _base(
    size: 20,
    weight: FontWeight.w600,
    color: ColorManager.of(context).textPrimary,
  );

  static TextStyle body(BuildContext context) => _base(
    size: 16,
    weight: FontWeight.normal,
    color: ColorManager.of(context).textPrimary,
    height: 1.4,
  );

  static TextStyle bodySecondary(BuildContext context) => _base(
    size: 14,
    weight: FontWeight.normal,
    color: ColorManager.of(context).textSecondary,
    height: 1.4,
  );

  static TextStyle caption(BuildContext context) => _base(
    size: 12,
    weight: FontWeight.normal,
    color: ColorManager.of(context).textHint,
  );

  static TextStyle button(BuildContext context) => _base(
    size: 16,
    weight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.3,
  );

  static TextStyle link(BuildContext context) => _base(
    size: 14,
    weight: FontWeight.w600,
    color: AppColors.primary,
  );

  static TextStyle errorText(BuildContext context) => _base(
    size: 13,
    weight: FontWeight.normal,
    color: AppColors.error,
  );
}
