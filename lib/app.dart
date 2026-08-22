import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_flow/provider/auth_provider.dart';
import 'package:task_flow/provider/connectivity_provider.dart';
import 'package:task_flow/screens/auth/splash_screen.dart';
import 'package:task_flow/screens/tasks/task_details_screen.dart';
import 'package:task_flow/service/auth_service.dart';
import 'core/theme/app_theme.dart';
import 'data/data_source/local_storage_data_source.dart';
import 'data/data_source/mock_data_source.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/project_repository.dart';
import 'data/repositories/project_repository_impl.dart';
import 'data/repositories/task_repository.dart';
import 'data/repositories/task_repository_impl.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/projects/project_detail_screen.dart';
import 'screens/projects/project_form_screen.dart';
import 'screens/projects/project_list_screen.dart';
import 'screens/tasks/task_form_screen.dart';
import 'screens/tasks/task_list_screen.dart';

class TaskFlowApp extends StatefulWidget {
  const TaskFlowApp({super.key});

  @override
  State<TaskFlowApp> createState() => _TaskFlowAppState();
}

class _TaskFlowAppState extends State<TaskFlowApp> {
  late final MockDataSource _ds = MockDataSource();
  late final LocalStorageDataSource _storage = LocalStorageDataSource();
  late final AuthRepository _authRepo = AuthRepositoryImpl(_ds);
  late final AuthService _authService = AuthService(_authRepo, _storage);
  late final ProjectRepository _projectRepo = ProjectRepositoryImpl(_ds);
  late final TaskRepository _taskRepo = TaskRepositoryImpl(_ds);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<TaskFlowDataSource>.value(value: _ds),
        Provider<LocalStorageDataSource>.value(value: _storage),
        Provider<AuthRepository>.value(value: _authRepo),
        Provider<AuthService>.value(value: _authService),
        Provider<ProjectRepository>.value(value: _projectRepo),
        Provider<TaskRepository>.value(value: _taskRepo),
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider(_authService)),
        ChangeNotifierProvider<ConnectivityProvider>(create: (_) => ConnectivityProvider()),
      ],
      child: MaterialApp(
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
      ),
    );
  }
}