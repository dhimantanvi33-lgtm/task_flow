import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/project_model.dart';

class ProjectCard extends StatelessWidget {
  final ProjectModel project;
  final VoidCallback? onTap;
  final Widget? trailing;
  const ProjectCard({super.key, required this.project, this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    final colors = ColorManager.of(context);
    final color = Color(project.colorValue);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: colors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: colors.border)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 10),
              Expanded(child: Text(project.name, style: AppTextStyles.heading3(context), maxLines: 1, overflow: TextOverflow.ellipsis)),
              if (trailing != null) trailing!,
            ]),
            if (project.description.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(project.description, style: AppTextStyles.caption(context), maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(value: project.progress, minHeight: 6, backgroundColor: colors.divider, valueColor: AlwaysStoppedAnimation<Color>(color)),
            ),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('${project.completedTasks}/${project.totalTasks} tasks', style: AppTextStyles.caption(context)),
              Text('${(project.progress * 100).round()}%', style: AppTextStyles.caption(context).copyWith(color: color, fontWeight: FontWeight.w600)),
            ]),
          ],
        ),
      ),
    );
  }
}
