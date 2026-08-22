import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/view_state.dart';
import '../../core/widegts/offline_banner.dart';
import '../../data/repositories/project_repository.dart';
import '../../models/project_model.dart';
import '../../provider/auth_provider.dart';
import '../../provider/project_provider.dart';
import '../../widgets/project_card.dart';
import '../../widgets/state_view.dart';
import 'project_form_screen.dart';

class ProjectListScreen extends StatelessWidget {
  final bool embedded;
  const ProjectListScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => ProjectProvider(ctx.read<ProjectRepository>(), ctx.read<AuthProvider>())..load(),
      child: _Body(embedded: embedded),
    );
  }
}

class _Body extends StatelessWidget {
  final bool embedded;
  const _Body({required this.embedded});

  Future<void> _openForm(BuildContext context, {ProjectModel? project}) async {
    final result = await Navigator.of(context).pushNamed('/project-form', arguments: project) as ProjectFormResult?;
    if (result == null || !context.mounted) return;
    final provider = context.read<ProjectProvider>();
    final error = result.id == null
        ? await provider.createProject(result.name, result.description)
        : await provider.updateProject(result.id!, result.name, result.description);
    if (error != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  Future<void> _delete(BuildContext context, ProjectModel project) async {
    final ok = await _confirm(context, title: 'Delete project?', message: 'This removes "${project.name}" and its tasks.');
    if (!ok || !context.mounted) return;
    final error = await context.read<ProjectProvider>().deleteProject(project.id);
    if (error != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  Future<void> _openDetail(BuildContext context, ProjectModel project) async {
    final changed = await Navigator.of(context).pushNamed('/project-detail', arguments: project);
    if (changed == true && context.mounted) context.read<ProjectProvider>().load();
  }

  @override
  Widget build(BuildContext context) {
    final colors = ColorManager.of(context);
    final provider = context.watch<ProjectProvider>();

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        automaticallyImplyLeading: !embedded,
        title: const Text('Projects'),
        actions: [IconButton(icon: const Icon(Icons.add), onPressed: () => _openForm(context))],
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: RefreshIndicator(
              color: colors.primary,
              onRefresh: () => context.read<ProjectProvider>().refresh(),
              child: StateView<List<ProjectModel>>(
                state: provider.state,
                emptyMessage: 'No projects yet.\nTap + to create one.',
                emptyIcon: Icons.folder_open_outlined,
                onRetry: () => context.read<ProjectProvider>().load(),
                onSuccess: (context, projects) => ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  itemCount: projects.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final p = projects[i];
                    return ProjectCard(
                      project: p,
                      onTap: () => _openDetail(context, p),
                      trailing: PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert, color: colors.textHint),
                        onSelected: (v) => v == 'edit' ? _openForm(context, project: p) : _delete(context, p),
                        itemBuilder: (_) => [
                          const PopupMenuItem(value: 'edit', child: Text('Edit')),
                          // Delete only offered to admins; the repository blocks it either way.
                          if (provider.isAdmin) const PopupMenuItem(value: 'delete', child: Text('Delete')),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<bool> _confirm(BuildContext context, {required String title, required String message}) async {
  final colors = ColorManager.of(context);
  final r = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: colors.card,
      title: Text(title, style: AppTextStyles.heading3(ctx)),
      content: Text(message, style: AppTextStyles.bodySecondary(ctx)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel', style: AppTextStyles.link(ctx))),
        TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Delete', style: TextStyle(color: colors.error, fontWeight: FontWeight.w600))),
      ],
    ),
  );
  return r ?? false;
}