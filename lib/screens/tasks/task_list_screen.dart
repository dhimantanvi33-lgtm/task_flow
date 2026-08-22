import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/task_model.dart';
import '../../widgets/task_card.dart';

class TaskListScreen extends StatefulWidget {
  final bool embedded;
  const TaskListScreen({super.key, this.embedded = false});
  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  TaskStatus? _status;

  @override
  Widget build(BuildContext context) {
    final colors = ColorManager.of(context);
    final all = TaskModel.samples;
    final tasks = _status == null ? all : all.where((t) => t.status == _status).toList();

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        automaticallyImplyLeading: !widget.embedded,
        title: const Text('Tasks'),
        actions: [IconButton(icon: const Icon(Icons.tune_rounded), onPressed: _openFilters)],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _FilterPill(label: 'All', selected: _status == null, onTap: () => setState(() => _status = null)),
                _FilterPill(label: 'To Do', selected: _status == TaskStatus.todo, onTap: () => setState(() => _status = TaskStatus.todo)),
                _FilterPill(label: 'In Progress', selected: _status == TaskStatus.inProgress, onTap: () => setState(() => _status = TaskStatus.inProgress)),
                _FilterPill(label: 'Done', selected: _status == TaskStatus.done, onTap: () => setState(() => _status = TaskStatus.done)),
              ],
            ),
          ),
          Expanded(
            child: tasks.isEmpty
                ? Center(child: Text('No tasks match this filter', style: AppTextStyles.bodySecondary(context)))
                : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: tasks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) => TaskCard(task: tasks[i], onTap: () => Navigator.of(context).pushNamed('/task-detail', arguments: tasks[i])),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pushNamed('/task-form'),
        backgroundColor: colors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('New Task', style: AppTextStyles.button(context)),
      ),
    );
  }

  void _openFilters() {
    final colors = ColorManager.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Filter tasks', style: AppTextStyles.heading3(ctx)),
          const SizedBox(height: 8),
          Text('Full filters (priority, assignee, due-date range) plug in here once the provider is wired.', style: AppTextStyles.bodySecondary(ctx)),
          const SizedBox(height: 16),
          Wrap(spacing: 8, children: [
            for (final s in TaskStatus.values)
              ChoiceChip(label: Text(s.label), selected: _status == s, onSelected: (_) { setState(() => _status = s); Navigator.pop(ctx); }),
            ActionChip(label: const Text('Clear'), onPressed: () { setState(() => _status = null); Navigator.pop(ctx); }),
          ]),
        ]),
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterPill({required this.label, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final colors = ColorManager.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: selected ? colors.primary : colors.card,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: selected ? colors.primary : colors.border),
          ),
          child: Text(label, style: AppTextStyles.caption(context).copyWith(color: selected ? Colors.white : colors.textSecondary, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}
