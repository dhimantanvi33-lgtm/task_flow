import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class EmptyWidget extends StatelessWidget {
  final String message;
  final IconData icon;
  final VoidCallback? onRefresh;
  const EmptyWidget({super.key, required this.message, this.icon = Icons.inbox_outlined, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final colors = ColorManager.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 44, color: colors.textHint),
          const SizedBox(height: 14),
          Text(message, textAlign: TextAlign.center, style: AppTextStyles.bodySecondary(context)),
          if (onRefresh != null) ...[
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onRefresh, child: const Text('Refresh')),
          ],
        ]),
      ),
    );
  }
}
