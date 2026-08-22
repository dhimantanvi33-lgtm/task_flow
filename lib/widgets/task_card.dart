import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/date_utils.dart';
import '../models/task_model.dart';
import 'priority_chip.dart';
import 'status_chip.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback? onTap;
  final VoidCallback? onToggle;
  const TaskCard({super.key, required this.task, this.onTap, this.onToggle});

  @override
  Widget build(BuildContext context) {
    final colors = ColorManager.of(context);
    final done = task.status == TaskStatus.done;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: colors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: colors.border)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (onToggle != null)
                  GestureDetector(
                    onTap: onToggle,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 22, height: 22,
                      margin: const EdgeInsets.only(right: 12, top: 1),
                      decoration: BoxDecoration(shape: BoxShape.circle, color: done ? colors.primary : Colors.transparent, border: Border.all(color: done ? colors.primary : colors.border, width: 2)),
                      child: done ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                    ),
                  ),
                Expanded(
                  child: Text(
                    task.title,
                    style: AppTextStyles.body(context).copyWith(fontWeight: FontWeight.w600, decoration: done ? TextDecoration.lineThrough : null, color: done ? colors.textHint : colors.textPrimary),
                  ),
                ),
                const SizedBox(width: 8),
                PriorityChip(priority: task.priority),
              ],
            ),
            const SizedBox(height: 10),
            Row(children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: Color(task.projectColorValue), shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text(task.projectName, style: AppTextStyles.caption(context)),
              const Spacer(),
              StatusChip(status: task.status),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Icon(Icons.schedule_rounded, size: 13, color: colors.textHint),
              const SizedBox(width: 4),
              Text(AppDateUtils.relativeDue(task.dueDate), style: AppTextStyles.caption(context)),
              const Spacer(),
              Icon(Icons.person_outline_rounded, size: 13, color: colors.textHint),
              const SizedBox(width: 4),
              Text(task.assigneeName ?? 'Unassigned', style: AppTextStyles.caption(context)),
            ]),
          ],
        ),
      ),
    );
  }
}
