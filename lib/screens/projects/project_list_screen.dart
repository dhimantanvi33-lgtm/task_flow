import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/project_model.dart';
import '../../widgets/project_card.dart';

class ProjectListScreen extends StatelessWidget {
  final bool embedded;
  const ProjectListScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final colors = ColorManager.of(context);
    final projects = ProjectModel.samples;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        automaticallyImplyLeading: !embedded,
        title: const Text('Projects'),
        actions: [IconButton(icon: const Icon(Icons.add), onPressed: () => Navigator.of(context).pushNamed('/project-form'))],
      ),
      body: RefreshIndicator(
        color: colors.primary,
        onRefresh: () async {},
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          itemCount: projects.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) => ProjectCard(
            project: projects[i],
            onTap: () => Navigator.of(context).pushNamed('/project-detail', arguments: projects[i]),
            trailing: PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: colors.textHint),
              onSelected: (v) {
                if (v == 'edit') Navigator.of(context).pushNamed('/project-form', arguments: projects[i]);
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
