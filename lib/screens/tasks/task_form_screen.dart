import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/validators.dart';
import '../../data/repositories/project_repository.dart';
import '../../data/repositories/task_repository.dart';
import '../../models/api_errors.dart';
import '../../models/project_model.dart';
import '../../models/task_model.dart';
import '../../provider/auth_provider.dart';

class TaskFormScreen extends StatefulWidget {
  const TaskFormScreen({super.key});
  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();

  TaskModel? _editing;
  String? _lockedProjectId;
  String? _lockedProjectName;

  List<ProjectModel> _projects = [];
  ProjectModel? _project;
  TaskPriority _priority = TaskPriority.medium;
  DateTime? _due;

  bool _init = false;
  bool _loadingProjects = false;
  bool _saving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_init) return;
    _init = true;
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is TaskModel) {
      _editing = arg;
      _title.text = arg.title;
      _description.text = arg.description;
      _priority = arg.priority;
      _due = arg.dueDate;
      _lockedProjectId = arg.projectId;
      _lockedProjectName = arg.projectName;
    } else if (arg is ProjectModel) {
      _lockedProjectId = arg.id;
      _lockedProjectName = arg.name;
    } else {
      _loadProjects(); // plain create -> need the picker
    }
  }

  Future<void> _loadProjects() async {
    setState(() => _loadingProjects = true);
    try {
      final auth = context.read<AuthProvider>();
      final list = await context.read<ProjectRepository>().getProjects(auth.orgId!);
      if (!mounted) return;
      setState(() {
        _projects = list;
        _project = list.isNotEmpty ? list.first : null;
        _loadingProjects = false;
      });
    } on ApiException {
      if (mounted) setState(() => _loadingProjects = false);
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(context: context, initialDate: _due ?? now, firstDate: now.subtract(const Duration(days: 30)), lastDate: now.add(const Duration(days: 365)));
    if (d != null) setState(() => _due = d);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final projectId = _lockedProjectId ?? _project?.id;
    if (projectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Create a project first.')));
      return;
    }
    setState(() => _saving = true);
    final repo = context.read<TaskRepository>();
    final orgId = context.read<AuthProvider>().orgId!;
    try {
      if (_editing == null) {
        await repo.createTask(TaskModel(
          id: '', projectId: projectId, orgId: orgId,
          title: _title.text.trim(), description: _description.text.trim(),
          status: TaskStatus.todo, priority: _priority, dueDate: _due,
        ));
      } else {
        await repo.updateTask(_editing!.copyWith(
          title: _title.text.trim(), description: _description.text.trim(),
          priority: _priority, dueDate: _due,
        ));
      }
      if (mounted) Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = ColorManager.of(context);
    final locked = _lockedProjectId != null;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(title: Text(_editing == null ? 'New task' : 'Edit task')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              _Field(controller: _title, label: 'Title', icon: Icons.title_rounded, validator: (v) => Validators.required(v, 'Title')),
              const SizedBox(height: 16),
              _Field(controller: _description, label: 'Description', icon: Icons.notes_rounded, maxLines: 3),
              const SizedBox(height: 16),
              _Label('Project'),
              const SizedBox(height: 8),
              if (locked)
                _CardWrap(child: Row(children: [
                  Icon(Icons.folder_outlined, size: 18, color: colors.textHint),
                  const SizedBox(width: 12),
                  Text(_lockedProjectName ?? 'Project', style: AppTextStyles.body(context)),
                ]))
              else if (_loadingProjects)
                _CardWrap(child: Row(children: [SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: colors.primary)), const SizedBox(width: 12), Text('Loading projects…', style: AppTextStyles.bodySecondary(context))]))
              else if (_projects.isEmpty)
                  _CardWrap(child: Text('No projects yet — create one first.', style: AppTextStyles.bodySecondary(context)))
                else
                  _CardWrap(child: DropdownButtonHideUnderline(
                    child: DropdownButton<ProjectModel>(
                      isExpanded: true, value: _project, borderRadius: BorderRadius.circular(12),
                      style: AppTextStyles.body(context), dropdownColor: colors.card,
                      items: _projects.map((p) => DropdownMenuItem(value: p, child: Text(p.name))).toList(),
                      onChanged: (p) => setState(() => _project = p),
                    ),
                  )),
              const SizedBox(height: 16),
              _Label('Priority'),
              const SizedBox(height: 8),
              Wrap(spacing: 8, children: [
                for (final p in TaskPriority.values)
                  ChoiceChip(label: Text(p.label), selected: _priority == p, onSelected: (_) => setState(() => _priority = p)),
              ]),
              const SizedBox(height: 16),
              _Label('Due date'),
              const SizedBox(height: 8),
              _CardWrap(child: InkWell(
                onTap: _pickDate,
                child: Row(children: [
                  Icon(Icons.calendar_today_rounded, size: 18, color: colors.textHint),
                  const SizedBox(width: 12),
                  Text(AppDateUtils.full(_due), style: AppTextStyles.body(context)),
                  const Spacer(),
                  if (_due != null) IconButton(icon: Icon(Icons.close, size: 18, color: colors.textHint), onPressed: () => setState(() => _due = null)),
                ]),
              )),
              const SizedBox(height: 28),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(backgroundColor: colors.primary, foregroundColor: Colors.white, disabledBackgroundColor: colors.primary.withValues(alpha: 0.5), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  child: _saving
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white))
                      : Text(_editing == null ? 'Create task' : 'Save changes', style: AppTextStyles.button(context)),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Align(alignment: Alignment.centerLeft, child: Text(text, style: AppTextStyles.label(context)));
}

class _CardWrap extends StatelessWidget {
  final Widget child;
  const _CardWrap({required this.child});
  @override
  Widget build(BuildContext context) {
    final colors = ColorManager.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: colors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: colors.border)),
      child: child,
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int maxLines;
  final String? Function(String?)? validator;
  const _Field({required this.controller, required this.label, required this.icon, this.maxLines = 1, this.validator});
  @override
  Widget build(BuildContext context) {
    final colors = ColorManager.of(context);
    OutlineInputBorder b(Color c, [double w = 1]) => OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: c, width: w));
    return TextFormField(
      controller: controller, maxLines: maxLines, validator: validator, style: AppTextStyles.body(context), cursorColor: colors.primary,
      decoration: InputDecoration(
        labelText: label, labelStyle: AppTextStyles.bodySecondary(context),
        floatingLabelStyle: AppTextStyles.caption(context).copyWith(color: colors.primary),
        prefixIcon: Icon(icon, color: colors.textHint, size: 20),
        filled: true, fillColor: colors.card, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: b(colors.border), focusedBorder: b(colors.primary, 1.6), errorBorder: b(colors.error), focusedErrorBorder: b(colors.error, 1.6),
        errorStyle: AppTextStyles.caption(context).copyWith(color: colors.error),
      ),
    );
  }
}