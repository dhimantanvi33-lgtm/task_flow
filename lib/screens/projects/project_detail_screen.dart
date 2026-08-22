import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_flow/screens/projects/project_form_screen.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/repositories/project_repository.dart';
import '../../data/repositories/task_repository.dart';
import '../../models/api_errors.dart';
import '../../models/project_model.dart';
import '../../models/task_model.dart';
import '../../provider/auth_provider.dart';
import '../../provider/task_provider.dart';
import '../../widgets/state_view.dart';
import '../../widgets/task_card.dart';

class ProjectDetailScreen extends StatelessWidget {
  const ProjectDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final project = (ModalRoute.of(context)?.settings.arguments as ProjectModel?);
    if (project == null) {
      return const Scaffold(body: Center(child: Text('Project not found')));
    }
    return ChangeNotifierProvider(
      create: (ctx) => TaskProvider(ctx.read<TaskRepository>(), ctx.read<AuthProvider>(), projectId: project.id)..load(),
      child: _Body(project: project),
    );
  }
}

class _Body extends StatelessWidget {
  final ProjectModel project;
  const _Body({required this.project});

  Future<void> _edit(BuildContext context) async {
    final result = await Navigator.of(context).pushNamed('/project-form', arguments: project) as ProjectFormResult?;
    if (result == null || result.id == null || !context.mounted) return;
    try {
      final repo = context.read<ProjectRepository>();
      await repo.updateProject(project.copyWith(name: result.name, description: result.description));
      if (context.mounted) Navigator.of(context).pop(true); // signal list to reload
    } on ApiException catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _delete(BuildContext context) async {
    final colors = ColorManager.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.card,
        title: Text('Delete project?', style: AppTextStyles.heading3(ctx)),
        content: Text('This removes "${project.name}" and its tasks.', style: AppTextStyles.bodySecondary(ctx)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel', style: AppTextStyles.link(ctx))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Delete', style: TextStyle(color: colors.error, fontWeight: FontWeight.w600))),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    try {
      final repo = context.read<ProjectRepository>();
      final isAdmin = context.read<AuthProvider>().isAdmin;
      await repo.deleteProject(project.id, isAdmin: isAdmin);
      if (context.mounted) Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = ColorManager.of(context);
    final provider = context.watch<TaskProvider>();
    final isAdmin = context.watch<AuthProvider>().isAdmin;
    final counts = provider.statusCounts;
    final color = Color(project.colorValue);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Project'),
        actions: [
          IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => _edit(context)),
          if (isAdmin) IconButton(icon: Icon(Icons.delete_outline, color: colors.error), onPressed: () => _delete(context)),
        ],
      ),
      body: RefreshIndicator(
        color: colors.primary,
        onRefresh: () => context.read<TaskProvider>().refresh(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
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
              _Summary(label: 'To Do', count: counts[TaskStatus.todo] ?? 0, color: colors.textSecondary),
              const SizedBox(width: 10),
              _Summary(label: 'In Progress', count: counts[TaskStatus.inProgress] ?? 0, color: colors.primary),
              const SizedBox(width: 10),
              _Summary(label: 'Done', count: counts[TaskStatus.done] ?? 0, color: AppColors.success),
            ]),
            const SizedBox(height: 24),
            Text('Tasks', style: AppTextStyles.heading3(context)),
            const SizedBox(height: 12),
            SizedBox(
              // Give StateView a sensible height inside the scroll view.
              height: 420,
              child: StateView<List<TaskModel>>(
                state: provider.state,
                emptyMessage: 'No tasks in this project yet.',
                emptyIcon: Icons.checklist_rounded,
                onRetry: () => context.read<TaskProvider>().load(),
                onSuccess: (context, tasks) => ListView.separated(
                  itemCount: tasks.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) => TaskCard(task: tasks[i], onTap: () => Navigator.of(context).pushNamed('/task-detail', arguments: tasks[i])),
                ),
              ),
            ),
          ],
        ),
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