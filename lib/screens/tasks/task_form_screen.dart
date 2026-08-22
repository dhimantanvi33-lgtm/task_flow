import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/validators.dart';
import '../../models/project_model.dart';
import '../../models/task_model.dart';

class TaskFormScreen extends StatefulWidget {
  const TaskFormScreen({super.key});
  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  ProjectModel _project = ProjectModel.samples.first;
  TaskPriority _priority = TaskPriority.medium;
  DateTime? _due;
  TaskModel? _editing;
  bool _init = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_init) return;
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is TaskModel) {
      _editing = arg;
      _title.text = arg.title;
      _description.text = arg.description;
      _priority = arg.priority;
      _due = arg.dueDate;
      _project = ProjectModel.samples.firstWhere((p) => p.name == arg.projectName, orElse: () => ProjectModel.samples.first);
    }
    _init = true;
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(context: context, initialDate: _due ?? now, firstDate: now.subtract(const Duration(days: 30)), lastDate: now.add(const Duration(days: 365)));
    if (picked != null) setState(() => _due = picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(); // UI-only
  }

  @override
  Widget build(BuildContext context) {
    final colors = ColorManager.of(context);
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
              _CardWrap(child: DropdownButtonHideUnderline(
                child: DropdownButton<ProjectModel>(
                  isExpanded: true, value: _project, borderRadius: BorderRadius.circular(12), style: AppTextStyles.body(context),
                  dropdownColor: colors.card,
                  items: ProjectModel.samples.map((p) => DropdownMenuItem(value: p, child: Text(p.name))).toList(),
                  onChanged: (p) => setState(() => _project = p!),
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
              _CardWrap(
                child: InkWell(
                  onTap: _pickDate,
                  child: Row(children: [
                    Icon(Icons.calendar_today_rounded, size: 18, color: colors.textHint),
                    const SizedBox(width: 12),
                    Text(AppDateUtils.full(_due), style: AppTextStyles.body(context)),
                    const Spacer(),
                    if (_due != null) IconButton(icon: Icon(Icons.close, size: 18, color: colors.textHint), onPressed: () => setState(() => _due = null)),
                  ]),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(backgroundColor: colors.primary, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  child: Text(_editing == null ? 'Create task' : 'Save changes', style: AppTextStyles.button(context)),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
