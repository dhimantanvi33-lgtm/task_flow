import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/task_model.dart';

class PriorityChip extends StatelessWidget {
  final TaskPriority priority;
  const PriorityChip({super.key, required this.priority});

  Color _color() => switch (priority) {
    TaskPriority.high => AppColors.danger,
    TaskPriority.medium => AppColors.warning,
    TaskPriority.low => AppColors.success,
  };

  @override
  Widget build(BuildContext context) {
    final c = _color();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: c.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.flag_rounded, size: 12, color: c),
        const SizedBox(width: 4),
        Text(priority.label, style: AppTextStyles.caption(context).copyWith(color: c, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}
