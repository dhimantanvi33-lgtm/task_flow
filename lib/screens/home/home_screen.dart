import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_flow/models/user_model.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/project_model.dart';
import '../../models/task_model.dart';
import '../../provider/auth_provider.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/project_card.dart';
import '../../widgets/task_card.dart';
import '../projects/project_list_screen.dart';
import '../tasks/task_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          _DashboardTab(),
          ProjectListScreen(embedded: true),
          TaskListScreen(embedded: true),
          _ProfileTab(),
        ],
      ),
      floatingActionButton: _index == 0
          ? FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pushNamed('/task-form'),
        backgroundColor: ColorManager.of(context).primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('New Task', style: AppTextStyles.button(context)),
      )
          : null,
      bottomNavigationBar: BottomNavBar(currentIndex: _index, onTap: (i) => setState(() => _index = i)),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final colors = ColorManager.of(context);
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final displayName = user?.name ?? 'there';
    final initials = user?.initials ?? '?';
    final roleLabel = user?.role.label ?? '';
    final org = auth.orgName ?? '';

    final projects = ProjectModel.samples;
    final tasks = TaskModel.samples;
    final today = tasks.where((t) => t.dueDate != null && t.dueDate!.day == DateTime.now().day).toList();

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_greeting, style: AppTextStyles.bodySecondary(context)),
                  const SizedBox(height: 4),
                  Text(displayName, style: AppTextStyles.heading1(context)),
                  const SizedBox(height: 6),
                  Row(children: [
                    Icon(Icons.business_outlined, size: 14, color: colors.textHint),
                    const SizedBox(width: 4),
                    Flexible(child: Text(roleLabel.isEmpty ? org : '$org · $roleLabel', style: AppTextStyles.caption(context), overflow: TextOverflow.ellipsis)),
                  ]),
                ]),
              ),
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(gradient: LinearGradient(colors: [colors.primary, colors.primaryLight]), shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
              ),
            ]),
            const SizedBox(height: 24),
            GridView.count(
              crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.5,
              children: [
                _StatCard(icon: Icons.folder_outlined, label: 'Projects', value: '${projects.length}', color: colors.primary),
                _StatCard(icon: Icons.today_outlined, label: 'Due Today', value: '${today.where((t) => t.status != TaskStatus.done).length}', color: AppColors.warning),
                _StatCard(icon: Icons.check_circle_outline, label: 'Completed', value: '${tasks.where((t) => t.status == TaskStatus.done).length}', color: AppColors.success),
                _StatCard(icon: Icons.error_outline, label: 'Overdue', value: '1', color: colors.error),
              ],
            ),
            const SizedBox(height: 28),
            Text('Your Projects', style: AppTextStyles.heading3(context)),
            const SizedBox(height: 12),
            SizedBox(
              height: 150,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: projects.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, i) => SizedBox(
                  width: 230,
                  child: ProjectCard(project: projects[i], onTap: () => Navigator.of(context).pushNamed('/project-detail', arguments: projects[i])),
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text("Today's Tasks", style: AppTextStyles.heading3(context)),
            const SizedBox(height: 12),
            ...today.map((t) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TaskCard(task: t, onToggle: () {}, onTap: () => Navigator.of(context).pushNamed('/task-detail', arguments: t)),
            )),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatCard({required this.icon, required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    final colors = ColorManager.of(context);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: colors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: colors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 34, height: 34, decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)), alignment: Alignment.center, child: Icon(icon, color: color, size: 18)),
        const Spacer(),
        Row(
          spacing: 3,
          children: [
            Text(value, style: AppTextStyles.heading2(context)),

            Text(label, style: AppTextStyles.caption(context)),
          ],
        ),

      ]),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();
  @override
  Widget build(BuildContext context) {
    final colors = ColorManager.of(context);
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: colors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: colors.border)),
            child: Row(children: [
              Container(width: 56, height: 56, decoration: BoxDecoration(gradient: LinearGradient(colors: [colors.primary, colors.primaryLight]), shape: BoxShape.circle), alignment: Alignment.center, child: Text(user?.initials ?? '?', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20))),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(user?.name ?? 'Guest', style: AppTextStyles.heading3(context)),
                Text(user?.email ?? '', style: AppTextStyles.caption(context)),
                const SizedBox(height: 4),
                Text('${auth.orgName ?? ''} · ${user?.role.label ?? ''}', style: AppTextStyles.caption(context).copyWith(color: colors.primary, fontWeight: FontWeight.w600)),
              ])),
            ]),
          ),
          const SizedBox(height: 20),
          _SettingRow(icon: Icons.dark_mode_outlined, label: 'Dark mode', trailing: Switch(value: Theme.of(context).brightness == Brightness.dark, onChanged: (_) {})),
          _SettingRow(icon: Icons.cloud_off_outlined, label: 'Simulate offline', trailing: Switch(value: false, onChanged: (_) {})),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
              }
            },
            icon: Icon(Icons.logout_rounded, color: colors.error),
            label: Text('Log out', style: TextStyle(color: colors.error)),
            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50), side: BorderSide(color: colors.border)),
          ),
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget trailing;
  const _SettingRow({required this.icon, required this.label, required this.trailing});
  @override
  Widget build(BuildContext context) {
    final colors = ColorManager.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(color: colors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: colors.border)),
      child: Row(children: [
        Icon(icon, size: 20, color: colors.textSecondary),
        const SizedBox(width: 14),
        Expanded(child: Text(label, style: AppTextStyles.body(context))),
        trailing,
      ]),
    );
  }
}