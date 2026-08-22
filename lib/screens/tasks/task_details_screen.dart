import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/date_utils.dart';
import '../../models/task_model.dart';
import '../../models/user_model.dart';
import '../../widgets/priority_chip.dart';
import '../../widgets/status_chip.dart';

class TaskDetailScreen extends StatefulWidget {
  const TaskDetailScreen({super.key});
  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  TaskModel? _task;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _task ??= (ModalRoute.of(context)?.settings.arguments as TaskModel?) ?? TaskModel.samples.first;
  }

  @override
  Widget build(BuildContext context) {
    final colors = ColorManager.of(context);
    final task = _task!;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Task'),
        actions: [
          IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => Navigator.of(context).pushNamed('/task-form', arguments: task)),
          IconButton(icon: Icon(Icons.delete_outline, color: colors.error), onPressed: () {}),
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
            trailing: TextButton(onPressed: _openAssignee, child: Text('Change', style: AppTextStyles.link(context))),
          ),
          const SizedBox(height: 20),
          Text('Status', style: AppTextStyles.label(context)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: [
            for (final s in TaskStatus.values)
              ChoiceChip(label: Text(s.label), selected: task.status == s, onSelected: (_) => setState(() => _task = task.copyWith(status: s))),
          ]),
          const SizedBox(height: 16),
          Text('Priority', style: AppTextStyles.label(context)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: [
            for (final p in TaskPriority.values)
              ChoiceChip(label: Text(p.label), selected: task.priority == p, onSelected: (_) => setState(() => _task = task.copyWith(priority: p))),
          ]),
        ],
      ),
    );
  }

  void _openAssignee() {
    final colors = ColorManager.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(padding: const EdgeInsets.all(16), child: Align(alignment: Alignment.centerLeft, child: Text('Assign to', style: AppTextStyles.heading3(ctx)))),
          ListTile(leading: const Icon(Icons.person_off_outlined), title: const Text('Unassign'), onTap: () { setState(() => _task = _task!.copyWith(clearAssignee: true)); Navigator.pop(ctx); }),
          for (final u in UserModel.orgMembers)
            ListTile(
              leading: CircleAvatar(backgroundColor: colors.primary, child: Text(u.initials, style: const TextStyle(color: Colors.white, fontSize: 13))),
              title: Text(u.name, style: AppTextStyles.body(ctx)),
              subtitle: Text(u.role.label, style: AppTextStyles.caption(ctx)),
              onTap: () { setState(() => _task = _task!.copyWith(assigneeName: u.name)); Navigator.pop(ctx); },
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
