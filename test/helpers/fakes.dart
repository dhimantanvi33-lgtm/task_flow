import 'package:task_flow/data/data_source/local_storage_data_source.dart';
import 'package:task_flow/data/data_source/mock_data_source.dart';
import 'package:task_flow/data/repositories/auth_repository.dart';
import 'package:task_flow/models/api_errors.dart';
import 'package:task_flow/models/project_model.dart';
import 'package:task_flow/models/task_model.dart';
import 'package:task_flow/models/user_model.dart';

class FakeDataSource implements TaskFlowDataSource {
  FakeDataSource({List<ProjectModel>? projects, List<TaskModel>? tasks, List<UserModel>? members, Set<String>? memberIds})
      : _projects = [...?projects],
        _tasks = [...?tasks],
        _members = [...?members],
        _memberIds = memberIds ?? {};

  final List<ProjectModel> _projects;
  final List<TaskModel> _tasks;
  final List<UserModel> _members;
  final Set<String> _memberIds;

  @override
  Future<void> load() async {}

  @override
  Future<List<ProjectModel>> projects(String orgId) async =>
      _projects.where((p) => p.orgId == orgId).toList();

  @override
  Future<ProjectModel> project(String projectId) async {
    final m = _projects.where((p) => p.id == projectId);
    if (m.isEmpty) throw const ApiException.notFound('Project not found.');
    return m.first;
  }

  @override
  Future<ProjectModel> addProject(ProjectModel project) async {
    final p = project.id.isEmpty ? project.copyWith() : project;
    final withId = ProjectModel(id: p.id.isEmpty ? 'proj_new' : p.id, orgId: p.orgId, name: p.name, description: p.description, colorHex: p.colorHex);
    _projects.add(withId);
    return withId;
  }

  @override
  Future<ProjectModel> updateProject(ProjectModel project) async {
    final i = _projects.indexWhere((p) => p.id == project.id);
    if (i == -1) throw const ApiException.notFound('Project not found.');
    _projects[i] = _projects[i].copyWith(name: project.name, description: project.description);
    return _projects[i];
  }

  @override
  Future<void> removeProject(String projectId) async {
    if (!_projects.any((p) => p.id == projectId)) throw const ApiException.notFound('Project not found.');
    _projects.removeWhere((p) => p.id == projectId);
    _tasks.removeWhere((t) => t.projectId == projectId);
  }

  @override
  Future<List<TaskModel>> tasks({required String orgId, String? projectId}) async =>
      _tasks.where((t) => t.orgId == orgId && (projectId == null || t.projectId == projectId)).toList();

  @override
  Future<TaskModel> task(String taskId) async {
    final m = _tasks.where((t) => t.id == taskId);
    if (m.isEmpty) throw const ApiException.notFound('Task not found.');
    return m.first;
  }

  @override
  Future<TaskModel> addTask(TaskModel task) async {
    final withId = TaskModel(
      id: task.id.isEmpty ? 'task_new' : task.id, projectId: task.projectId, orgId: task.orgId,
      title: task.title, description: task.description, status: task.status, priority: task.priority,
      assigneeId: task.assigneeId, dueDate: task.dueDate,
    );
    _tasks.add(withId);
    return withId;
  }

  @override
  Future<TaskModel> updateTask(TaskModel task) async {
    final i = _tasks.indexWhere((t) => t.id == task.id);
    if (i == -1) throw const ApiException.notFound('Task not found.');
    _tasks[i] = task;
    return task;
  }

  @override
  Future<void> removeTask(String taskId) async => _tasks.removeWhere((t) => t.id == taskId);

  @override
  Future<bool> isMember(String userId, String orgId) async => _memberIds.contains(userId);

  @override
  Future<List<UserModel>> orgMembers(String orgId) async => _members;

  // ---- unused by the repos under test ----
  @override
  Future<({String orgId, MemberRole role})?> findCredential(String email, String password) => throw UnimplementedError();
  @override
  Future<Map<String, dynamic>> loginResponse() => throw UnimplementedError();
  @override
  Future<UserModel?> userByEmail(String email) => throw UnimplementedError();
  @override
  Future<UserModel?> userById(String id) => throw UnimplementedError();
  @override
  Future<String> orgName(String orgId) => throw UnimplementedError();
  @override
  Future<MemberRole?> roleOf(String userId, String orgId) => throw UnimplementedError();
}

class FakeCache extends LocalStorageDataSource {
  final Map<String, String> _store = {};
  @override
  Future<void> cache(String key, String json) async => _store[key] = json;
  @override
  Future<String?> readCache(String key) async => _store[key];
  @override
  Future<void> clearCache() async => _store.clear();
}

class FakeAuthRepository implements AuthRepository {
  @override
  Future<AuthSession> login({required String email, required String password}) => throw UnimplementedError();
  @override
  Future<AuthSession> register({required String name, required String email, required String password}) => throw UnimplementedError();
  @override
  Future<AuthTokens> refresh(String refreshToken) => throw UnimplementedError();
  @override
  Future<UserModel> resolveUser({required String userId, required String orgId}) => throw UnimplementedError();
  @override
  Future<String> orgName(String orgId) => throw UnimplementedError();
}