import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle heading1(BuildContext c) => TextStyle(fontSize: 26, fontWeight: FontWeight.w700, height: 1.15, letterSpacing: -0.4, color: ColorManager.of(c).textPrimary);
  static TextStyle heading2(BuildContext c) => TextStyle(fontSize: 22, fontWeight: FontWeight.w700, height: 1.2, color: ColorManager.of(c).textPrimary);
  static TextStyle heading3(BuildContext c) => TextStyle(fontSize: 17, fontWeight: FontWeight.w600, height: 1.25, color: ColorManager.of(c).textPrimary);
  static TextStyle body(BuildContext c) => TextStyle(fontSize: 15, fontWeight: FontWeight.w400, height: 1.4, color: ColorManager.of(c).textPrimary);
  static TextStyle bodySecondary(BuildContext c) => TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.4, color: ColorManager.of(c).textSecondary);
  static TextStyle caption(BuildContext c) => TextStyle(fontSize: 12.5, fontWeight: FontWeight.w400, height: 1.3, color: ColorManager.of(c).textSecondary);
  static TextStyle label(BuildContext c) => TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: ColorManager.of(c).textSecondary);
  static TextStyle button(BuildContext c) => const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.2, color: Colors.white);
  static TextStyle link(BuildContext c) => TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: ColorManager.of(c).primary);
}
