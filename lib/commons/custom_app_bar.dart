import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Widget? leading;
  final Color? backgroundColor;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.onBackPressed,
    this.leading,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = ColorManager.of(context);
    return AppBar(
      backgroundColor: backgroundColor ?? colors.background,
      elevation: 0,
      centerTitle: true,
      leading: leading ??
          (showBackButton && Navigator.canPop(context)
              ? IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: colors.textPrimary, size: 20),
            onPressed: onBackPressed ?? () => Navigator.pop(context),
          )
              : null),
      title: Text(title, style: AppTextStyles.heading3(context)),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
