import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum AppButtonType { primary, outlined, text }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final AppButtonType type;
  final IconData? icon;
  final double height;
  final Color? backgroundColor;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.type = AppButtonType.primary,
    this.icon,
    this.height = 52,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = ColorManager.of(context);
    final disabled = onPressed == null || isLoading;
    final isFilled = type == AppButtonType.primary;

    final Widget child = isLoading
        ? SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2.2,
        valueColor: AlwaysStoppedAnimation<Color>(
          isFilled ? Colors.white : colors.primary,
        ),
      ),
    )
        : Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: isFilled ? Colors.white : colors.primary),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: AppTextStyles.button(context).copyWith(
            color: isFilled ? Colors.white : colors.primary,
          ),
        ),
      ],
    );

    switch (type) {
      case AppButtonType.outlined:
        return SizedBox(
          width: double.infinity,
          height: height,
          child: OutlinedButton(
            onPressed: disabled ? null : onPressed,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: disabled ? colors.disabled : colors.primary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: child,
          ),
        );
      case AppButtonType.text:
        return TextButton(onPressed: disabled ? null : onPressed, child: child);
      case AppButtonType.primary:
        return SizedBox(
          width: double.infinity,
          height: height,
          child: ElevatedButton(
            onPressed: disabled ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor ?? colors.primary,
              disabledBackgroundColor: colors.disabled,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: child,
          ),
        );
    }
  }
}
