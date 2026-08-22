import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/validators.dart';
import '../../models/project_model.dart';

class ProjectFormResult {
  final String? id; // null => create
  final String name;
  final String description;
  const ProjectFormResult({this.id, required this.name, required this.description});
}

class ProjectFormScreen extends StatefulWidget {
  const ProjectFormScreen({super.key});
  @override
  State<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends State<ProjectFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _description = TextEditingController();
  ProjectModel? _editing;
  bool _init = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_init) return;
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is ProjectModel) {
      _editing = arg;
      _name.text = arg.name;
      _description.text = arg.description;
    }
    _init = true;
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(ProjectFormResult(
      id: _editing?.id,
      name: _name.text.trim(),
      description: _description.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final colors = ColorManager.of(context);
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(title: Text(_editing == null ? 'New project' : 'Edit project')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              _Field(controller: _name, label: 'Project name', icon: Icons.folder_outlined, validator: (v) => Validators.required(v, 'Project name')),
              const SizedBox(height: 16),
              _Field(controller: _description, label: 'Description', icon: Icons.notes_rounded, maxLines: 4),
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(backgroundColor: colors.primary, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  child: Text(_editing == null ? 'Create project' : 'Save changes', style: AppTextStyles.button(context)),
                ),
              ),
            ]),
          ),
        ),
      ),
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