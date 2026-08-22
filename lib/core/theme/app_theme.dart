import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();
  static ThemeData get light => _build(ColorManager.light, Brightness.light);
  static ThemeData get dark => _build(ColorManager.dark, Brightness.dark);

  static ThemeData _build(ColorManager c, Brightness b) => ThemeData(
    useMaterial3: true,
    brightness: b,
    scaffoldBackgroundColor: c.background,
    colorScheme: c.scheme(b),
    appBarTheme: AppBarTheme(backgroundColor: c.background, foregroundColor: c.textPrimary, elevation: 0, centerTitle: false),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: c.primary),
    dividerColor: c.divider,
  );
}
