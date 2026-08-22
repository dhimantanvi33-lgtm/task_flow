import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/project_model.dart';
import '../../models/task_model.dart';
import '../../widgets/task_card.dart';

class ProjectDetailScreen extends StatelessWidget {
  const ProjectDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = ColorManager.of(context);
    final project = (ModalRoute.of(context)?.settings.arguments as ProjectModel?) ?? ProjectModel.samples.first;
    final color = Color(project.colorValue);
    final tasks = TaskModel.samples.where((t) => t.projectName == project.name).toList();
    final todo = tasks.where((t) => t.status == TaskStatus.todo).length;
    final inProgress = tasks.where((t) => t.status == TaskStatus.inProgress).length;
    final done = tasks.where((t) => t.status == TaskStatus.done).length;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Project'),
        actions: [
          IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => Navigator.of(context).pushNamed('/project-form', arguments: project)),
          IconButton(icon: Icon(Icons.delete_outline, color: colors.error), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Row(children: [
            Container(width: 14, height: 14, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 10),
            Expanded(child: Text(project.name, style: AppTextStyles.heading1(context))),
          ]),
          if (project.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(project.description, style: AppTextStyles.bodySecondary(context)),
          ],
          const SizedBox(height: 20),
          Row(children: [
            _Summary(label: 'To Do', count: todo, color: colors.textSecondary),
            const SizedBox(width: 10),
            _Summary(label: 'In Progress', count: inProgress, color: colors.primary),
            const SizedBox(width: 10),
            _Summary(label: 'Done', count: done, color: AppColors.success),
          ]),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Tasks', style: AppTextStyles.heading3(context)),
            Text('${tasks.length} total', style: AppTextStyles.caption(context)),
          ]),
          const SizedBox(height: 12),
          ...tasks.map((t) => Padding(padding: const EdgeInsets.only(bottom: 10), child: TaskCard(task: t, onTap: () => Navigator.of(context).pushNamed('/task-detail', arguments: t)))),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed('/task-form'),
        backgroundColor: colors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _Summary({required this.label, required this.count, required this.color});
  @override
  Widget build(BuildContext context) {
    final colors = ColorManager.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(color: colors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: colors.border)),
        child: Column(children: [
          Text('$count', style: AppTextStyles.heading2(context).copyWith(color: color)),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.caption(context)),
        ]),
      ),
    );
  }
}
