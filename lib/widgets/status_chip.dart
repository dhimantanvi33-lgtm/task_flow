import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/task_model.dart';

class StatusChip extends StatelessWidget {
  final TaskStatus status;
  const StatusChip({super.key, required this.status});

  Color _color() => switch (status) {
    TaskStatus.todo => AppColors.lTextSecondary,
    TaskStatus.inProgress => AppColors.brand,
    TaskStatus.done => AppColors.success,
  };

  @override
  Widget build(BuildContext context) {
    final c = _color();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: c.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
      child: Text(status.label, style: AppTextStyles.caption(context).copyWith(color: c, fontWeight: FontWeight.w600)),
    );
  }
}
