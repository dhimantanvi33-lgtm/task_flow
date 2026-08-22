import 'package:flutter/material.dart';
import 'package:task_flow/screens/auth/splash_screen.dart';
import 'package:task_flow/screens/tasks/task_details_screen.dart';
import 'core/theme/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/projects/project_detail_screen.dart';
import 'screens/projects/project_form_screen.dart';
import 'screens/projects/project_list_screen.dart';
import 'screens/tasks/task_form_screen.dart';
import 'screens/tasks/task_list_screen.dart';

class TaskFlowApp extends StatelessWidget {
  const TaskFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(),
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/home': (_) => const HomeScreen(),
        '/projects': (_) => const ProjectListScreen(),
        '/project-detail': (_) => const ProjectDetailScreen(),
        '/project-form': (_) => const ProjectFormScreen(),
        '/tasks': (_) => const TaskListScreen(),
        '/task-detail': (_) => const TaskDetailScreen(),
        '/task-form': (_) => const TaskFormScreen(),
      },
    );
  }
}
