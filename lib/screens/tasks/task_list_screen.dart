import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/view_state.dart';
import '../../core/widegts/offline_banner.dart';
import '../../data/repositories/task_repository.dart';
import '../../models/task_model.dart';
import '../../models/user_model.dart';
import '../../provider/auth_provider.dart';
import '../../provider/task_provider.dart';
import '../../widgets/state_view.dart';
import '../../widgets/task_card.dart';

class TaskListScreen extends StatelessWidget {
  final bool embedded;
  const TaskListScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => TaskProvider(ctx.read<TaskRepository>(), ctx.read<AuthProvider>())..load(),
      child: _Body(embedded: embedded),
    );
  }
}

class _Body extends StatelessWidget {
  final bool embedded;
  const _Body({required this.embedded});

  Future<void> _create(BuildContext context) async {
    final changed = await Navigator.of(context).pushNamed('/task-form');
    if (changed == true && context.mounted) context.read<TaskProvider>().load();
  }

  @override
  Widget build(BuildContext context) {
    final colors = ColorManager.of(context);
    final provider = context.watch<TaskProvider>();
    final active = !provider.filter.isEmpty;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        automaticallyImplyLeading: !embedded,
        title: const Text('Tasks'),
        actions: [
          IconButton(
            icon: Badge(isLabelVisible: active, child: const Icon(Icons.tune_rounded)),
            onPressed: () => _openFilters(context, provider),
          ),
        ],
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          _StatusPills(provider: provider),
          Expanded(
            child: RefreshIndicator(
              color: colors.primary,
              onRefresh: () => context.read<TaskProvider>().refresh(),
              child: StateView<List<TaskModel>>(
                state: provider.state,
                emptyMessage: active ? 'No tasks match these filters.' : 'No tasks yet.\nTap + to create one.',
                emptyIcon: Icons.checklist_rounded,
                onRetry: () => context.read<TaskProvider>().load(),
                onSuccess: (context, tasks) => ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  itemCount: tasks.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) => TaskCard(task: tasks[i], onTap: () => Navigator.of(context).pushNamed('/task-detail', arguments: tasks[i])),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _create(context),
        backgroundColor: colors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('New Task', style: AppTextStyles.button(context)),
      ),
    );
  }

  void _openFilters(BuildContext context, TaskProvider provider) {
    final colors = ColorManager.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _FilterSheet(
        initial: provider.filter,
        members: provider.members,
        onApply: (f) => provider.setFilter(f),
        onClear: () => provider.clearFilter(),
      ),
    );
  }
}

class _StatusPills extends StatelessWidget {
  final TaskProvider provider;
  const _StatusPills({required this.provider});

  @override
  Widget build(BuildContext context) {
    final current = provider.filter.status;
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _pill(context, 'All', current == null, () => provider.setFilter(provider.filter.copyWith(clearStatus: true))),
          for (final s in TaskStatus.values)
            _pill(context, s.label, current == s, () => provider.setFilter(provider.filter.copyWith(status: s))),
        ],
      ),
    );
  }

  Widget _pill(BuildContext context, String label, bool selected, VoidCallback onTap) {
    final colors = ColorManager.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: selected ? colors.primary : colors.card, borderRadius: BorderRadius.circular(999), border: Border.all(color: selected ? colors.primary : colors.border)),
          child: Text(label, style: AppTextStyles.caption(context).copyWith(color: selected ? Colors.white : colors.textSecondary, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  final TaskFilter initial;
  final List<UserModel> members;
  final ValueChanged<TaskFilter> onApply;
  final VoidCallback onClear;
  const _FilterSheet({required this.initial, required this.members, required this.onApply, required this.onClear});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late TaskStatus? _status = widget.initial.status;
  late TaskPriority? _priority = widget.initial.priority;
  late String? _assignee = widget.initial.assigneeId;
  late DateTime? _from = widget.initial.dueFrom;
  late DateTime? _to = widget.initial.dueTo;

  @override
  Widget build(BuildContext context) {
    final colors = ColorManager.of(context);
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Filter tasks', style: AppTextStyles.heading3(context)),
          const SizedBox(height: 16),
          Text('Status', style: AppTextStyles.label(context)),
          const SizedBox(height: 6),
          Wrap(spacing: 8, children: [
            for (final s in TaskStatus.values)
              ChoiceChip(label: Text(s.label), selected: _status == s, onSelected: (v) => setState(() => _status = v ? s : null)),
          ]),
          const SizedBox(height: 14),
          Text('Priority', style: AppTextStyles.label(context)),
          const SizedBox(height: 6),
          Wrap(spacing: 8, children: [
            for (final p in TaskPriority.values)
              ChoiceChip(label: Text(p.label), selected: _priority == p, onSelected: (v) => setState(() => _priority = v ? p : null)),
          ]),
          const SizedBox(height: 14),
          Text('Assignee', style: AppTextStyles.label(context)),
          const SizedBox(height: 6),
          Wrap(spacing: 8, children: [
            ChoiceChip(label: const Text('Anyone'), selected: _assignee == null, onSelected: (_) => setState(() => _assignee = null)),
            for (final u in widget.members)
              ChoiceChip(label: Text(u.name), selected: _assignee == u.id, onSelected: (v) => setState(() => _assignee = v ? u.id : null)),
          ]),
          const SizedBox(height: 14),
          Text('Due date range', style: AppTextStyles.label(context)),
          const SizedBox(height: 6),
          Row(children: [
            Expanded(child: _dateBtn(context, 'From', _from, (d) => setState(() => _from = d))),
            const SizedBox(width: 10),
            Expanded(child: _dateBtn(context, 'To', _to, (d) => setState(() => _to = d))),
          ]),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: OutlinedButton(
              onPressed: () { widget.onClear(); Navigator.pop(context); },
              child: const Text('Clear'),
            )),
            const SizedBox(width: 12),
            Expanded(child: ElevatedButton(
              onPressed: () {
                widget.onApply(TaskFilter(status: _status, priority: _priority, assigneeId: _assignee, dueFrom: _from, dueTo: _to));
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: colors.primary, foregroundColor: Colors.white),
              child: const Text('Apply'),
            )),
          ]),
        ],
      ),
    );
  }

  Widget _dateBtn(BuildContext context, String label, DateTime? value, ValueChanged<DateTime?> onPick) {
    final colors = ColorManager.of(context);
    return OutlinedButton(
      onPressed: () async {
        final now = DateTime.now();
        final d = await showDatePicker(context: context, initialDate: value ?? now, firstDate: now.subtract(const Duration(days: 365)), lastDate: now.add(const Duration(days: 365)));
        onPick(d);
      },
      style: OutlinedButton.styleFrom(side: BorderSide(color: colors.border)),
      child: Text(value == null ? label : '${value.month}/${value.day}', style: AppTextStyles.caption(context)),
    );
  }
}