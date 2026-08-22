import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_flow/models/user_model.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/date_utils.dart';
import '../../core/view_state.dart';
import '../../data/repositories/task_repository.dart';
import '../../models/task_model.dart';
import '../../provider/auth_provider.dart';
import '../../provider/task_provider.dart';
import '../../widgets/priority_chip.dart';
import '../../widgets/status_chip.dart';

class TaskDetailScreen extends StatelessWidget {
  const TaskDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final initial = ModalRoute.of(context)?.settings.arguments as TaskModel?;
    if (initial == null) {
      return const Scaffold(body: Center(child: Text('Task not found')));
    }
    return ChangeNotifierProvider(
      create: (ctx) => TaskProvider(ctx.read<TaskRepository>(), ctx.read<AuthProvider>())..load(),
      child: _Body(taskId: initial.id, fallback: initial),
    );
  }
}

class _Body extends StatelessWidget {
  final String taskId;
  final TaskModel fallback;
  const _Body({required this.taskId, required this.fallback});

  @override
  Widget build(BuildContext context) {
    final colors = ColorManager.of(context);
    final provider = context.watch<TaskProvider>();

    final loading = provider.state is ViewInitial || provider.state is ViewLoading;
    final matches = provider.allTasks.where((t) => t.id == taskId).toList();

    if (loading && matches.isEmpty) {
      return Scaffold(appBar: AppBar(title: const Text('Task')), body: Center(child: CircularProgressIndicator(color: colors.primary)));
    }
    if (matches.isEmpty) {
      return Scaffold(appBar: AppBar(title: const Text('Task')), body: Center(child: Text('This task no longer exists.', style: AppTextStyles.bodySecondary(context))));
    }
    final task = matches.first;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Task'),
        actions: [
          IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => _edit(context)),
          IconButton(icon: Icon(Icons.delete_outline, color: colors.error), onPressed: () => _delete(context, task)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text(task.title, style: AppTextStyles.heading2(context)),
          const SizedBox(height: 10),
          Row(children: [StatusChip(status: task.status), const SizedBox(width: 8), PriorityChip(priority: task.priority)]),
          const SizedBox(height: 20),
          if (task.description.isNotEmpty) ...[
            Text('Description', style: AppTextStyles.label(context)),
            const SizedBox(height: 6),
            Text(task.description, style: AppTextStyles.body(context)),
            const SizedBox(height: 20),
          ],
          _Row(icon: Icons.folder_outlined, label: 'Project', child: Row(children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: Color(task.projectColorValue), shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(task.projectName, style: AppTextStyles.body(context)),
          ])),
          _Row(icon: Icons.schedule_rounded, label: 'Due', child: Text(AppDateUtils.full(task.dueDate), style: AppTextStyles.body(context))),
          _Row(
            icon: Icons.person_outline_rounded,
            label: 'Assignee',
            child: Text(task.assigneeName ?? 'Unassigned', style: AppTextStyles.body(context)),
            trailing: TextButton(onPressed: () => _openAssignee(context, provider, task), child: Text('Change', style: AppTextStyles.link(context))),
          ),
          const SizedBox(height: 20),
          Text('Status', style: AppTextStyles.label(context)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: [
            for (final s in TaskStatus.values)
              ChoiceChip(label: Text(s.label), selected: task.status == s, onSelected: (_) => _run(context, () => provider.updateStatus(task, s))),
          ]),
          const SizedBox(height: 16),
          Text('Priority', style: AppTextStyles.label(context)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: [
            for (final p in TaskPriority.values)
              ChoiceChip(label: Text(p.label), selected: task.priority == p, onSelected: (_) => _run(context, () => provider.updatePriority(task, p))),
          ]),
        ],
      ),
    );
  }

  Future<void> _run(BuildContext context, Future<String?> Function() action) async {
    final error = await action();
    if (error != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  Future<void> _edit(BuildContext context) async {
    final task = context.read<TaskProvider>().allTasks.where((t) => t.id == taskId).toList();
    final arg = task.isEmpty ? fallback : task.first;
    final changed = await Navigator.of(context).pushNamed('/task-form', arguments: arg);
    if (changed == true && context.mounted) context.read<TaskProvider>().load();
  }

  Future<void> _delete(BuildContext context, TaskModel task) async {
    final colors = ColorManager.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.card,
        title: Text('Delete task?', style: AppTextStyles.heading3(ctx)),
        content: Text('This removes "${task.title}".', style: AppTextStyles.bodySecondary(ctx)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel', style: AppTextStyles.link(ctx))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Delete', style: TextStyle(color: colors.error, fontWeight: FontWeight.w600))),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final error = await context.read<TaskProvider>().deleteTask(task.id);
    if (!context.mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    } else {
      Navigator.of(context).pop(true);
    }
  }

  void _openAssignee(BuildContext context, TaskProvider provider, TaskModel task) {
    final colors = ColorManager.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(padding: const EdgeInsets.all(16), child: Align(alignment: Alignment.centerLeft, child: Text('Assign to', style: AppTextStyles.heading3(ctx)))),
          ListTile(
            leading: const Icon(Icons.person_off_outlined),
            title: const Text('Unassign'),
            onTap: () { Navigator.pop(ctx); _run(context, () => provider.assign(task.id, null)); },
          ),
          for (final u in provider.members)
            ListTile(
              leading: CircleAvatar(backgroundColor: colors.primary, child: Text(u.initials, style: const TextStyle(color: Colors.white, fontSize: 13))),
              title: Text(u.name, style: AppTextStyles.body(ctx)),
              subtitle: Text(u.role.label, style: AppTextStyles.caption(ctx)),
              trailing: task.assigneeId == u.id ? Icon(Icons.check, color: colors.primary) : null,
              onTap: () { Navigator.pop(ctx); _run(context, () => provider.assign(task.id, u.id)); },
            ),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget child;
  final Widget? trailing;
  const _Row({required this.icon, required this.label, required this.child, this.trailing});
  @override
  Widget build(BuildContext context) {
    final colors = ColorManager.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: colors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: colors.border)),
      child: Row(children: [
        Icon(icon, size: 18, color: colors.textHint),
        const SizedBox(width: 12),
        SizedBox(width: 76, child: Text(label, style: AppTextStyles.caption(context))),
        Expanded(child: child),
        if (trailing != null) trailing!,
      ]),
    );
  }
}