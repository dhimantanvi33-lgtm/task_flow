import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;

import '../../models/api_errors.dart';
import '../../models/comment_model.dart';
import '../../models/organization_model.dart';
import '../../models/project_model.dart';
import '../../models/task_model.dart';
import '../../models/user_model.dart';
import '../../service/connectivity_service.dart';
import '../../service/mock_error_service.dart';

abstract class TaskFlowDataSource {
  Future<void> load();

  // Auth
  Future<({String orgId, MemberRole role})?> findCredential(String email, String password);
  Future<Map<String, dynamic>> loginResponse();
  Future<UserModel?> userByEmail(String email);
  Future<UserModel?> userById(String id);

  // Orgs & members
  Future<String> orgName(String orgId);
  Future<List<UserModel>> orgMembers(String orgId);
  Future<bool> isMember(String userId, String orgId);
  Future<MemberRole?> roleOf(String userId, String orgId);

  // Projects
  Future<List<ProjectModel>> projects(String orgId);
  Future<ProjectModel> project(String projectId);
  Future<ProjectModel> addProject(ProjectModel project);
  Future<ProjectModel> updateProject(ProjectModel project);
  Future<void> removeProject(String projectId);

  // Tasks
  Future<List<TaskModel>> tasks({required String orgId, String? projectId});
  Future<TaskModel> task(String taskId);
  Future<TaskModel> addTask(TaskModel task);
  Future<TaskModel> updateTask(TaskModel task);
  Future<void> removeTask(String taskId);
}
class MockDataSource implements TaskFlowDataSource {
  MockDataSource(this._connectivity, this._errors, {this.artificialDelay = true});

  final ConnectivityService _connectivity;
  final MockErrorService _errors;

  final bool artificialDelay;

  static const _assetPath = 'assets/mock/taskflow_mock_data.json';
  final _rng = Random();
  bool _loaded = false;

  final List<OrganizationModel> _orgs = [];
  final List<UserModel> _users = [];
  final List<_Membership> _members = [];
  final List<ProjectModel> _projects = []; // raw (no counts)
  final List<TaskModel> _tasks = []; // raw (no joins)
  final List<CommentModel> _comments = [];
  Map<String, dynamic> _authMock = {};

  @override
  Future<void> load() async {
    if (_loaded) return;
    final raw = await rootBundle.loadString(_assetPath);
    final json = jsonDecode(raw) as Map<String, dynamic>;

    _orgs
      ..clear()
      ..addAll((json['organizations'] as List).map((e) => OrganizationModel.fromJson(e as Map<String, dynamic>)));
    _users
      ..clear()
      ..addAll((json['users'] as List).map((e) => UserModel.fromJson(e as Map<String, dynamic>)));
    _members
      ..clear()
      ..addAll((json['org_members'] as List).map((e) => _Membership.fromJson(e as Map<String, dynamic>)));
    _projects
      ..clear()
      ..addAll((json['projects'] as List).map((e) => ProjectModel.fromJson(e as Map<String, dynamic>)));
    _tasks
      ..clear()
      ..addAll((json['tasks'] as List).map((e) => TaskModel.fromJson(e as Map<String, dynamic>)));
    _comments
      ..clear()
      ..addAll((json['comments'] as List).map((e) => CommentModel.fromJson(e as Map<String, dynamic>)));

    _authMock = Map<String, dynamic>.from(json['auth_mock'] as Map);

    _loaded = true;
  }

  // ---------------- Auth ----------------
  @override
  Future<({String orgId, MemberRole role})?> findCredential(String email, String password) async {
    await _gate();
    final creds = (_authMock['test_credentials'] as List).cast<Map<String, dynamic>>();
    for (final c in creds) {
      if ((c['email'] as String).toLowerCase() == email.trim().toLowerCase() && c['password'] == password) {
        return (orgId: c['org_id'] as String, role: MemberRoleX.parse(c['role'] as String?));
      }
    }
    return null;
  }

  @override
  Future<Map<String, dynamic>> loginResponse() async {
    await _ensure();
    return Map<String, dynamic>.from(_authMock['mock_login_response'] as Map);
  }

  @override
  Future<UserModel?> userByEmail(String email) async {
    await _ensure();
    final match = _users.where((u) => u.email.toLowerCase() == email.trim().toLowerCase());
    return match.isEmpty ? null : match.first;
  }

  @override
  Future<UserModel?> userById(String id) async {
    await _ensure();
    final match = _users.where((u) => u.id == id);
    return match.isEmpty ? null : match.first;
  }

  // ---------------- Orgs & members ----------------
  @override
  Future<String> orgName(String orgId) async {
    await _ensure();
    final match = _orgs.where((o) => o.id == orgId);
    return match.isEmpty ? 'Unknown' : match.first.name;
  }

  @override
  Future<List<UserModel>> orgMembers(String orgId) async {
    await _gate();
    final result = <UserModel>[];
    for (final m in _members.where((m) => m.orgId == orgId)) {
      final u = _users.where((u) => u.id == m.userId);
      if (u.isNotEmpty) result.add(u.first.copyWith(role: m.role));
    }
    return result;
  }

  @override
  Future<bool> isMember(String userId, String orgId) async {
    await _ensure();
    return _members.any((m) => m.userId == userId && m.orgId == orgId);
  }

  @override
  Future<MemberRole?> roleOf(String userId, String orgId) async {
    await _ensure();
    final match = _members.where((m) => m.userId == userId && m.orgId == orgId);
    return match.isEmpty ? null : match.first.role;
  }

  // ---------------- Projects ----------------
  @override
  Future<List<ProjectModel>> projects(String orgId) async {
    await _gate();
    return _projects.where((p) => p.orgId == orgId).map(_hydrateProject).toList();
  }

  @override
  Future<ProjectModel> project(String projectId) async {
    _errors.checkProjectId(projectId);
    await _gate();
    return _hydrateProject(_findProject(projectId));
  }

  @override
  Future<ProjectModel> addProject(ProjectModel project) async {
    await _gate(write: true);
    final id = project.id.isEmpty ? _newId('proj') : project.id;
    _projects.add(ProjectModel(
      id: id,
      orgId: project.orgId,
      name: project.name,
      description: project.description,
      colorHex: project.colorHex,
      createdAt: project.createdAt ?? DateTime.now(),
    ));
    return _hydrateProject(_findProject(id));
  }

  @override
  Future<ProjectModel> updateProject(ProjectModel project) async {
    await _gate(write: true);
    final i = _projects.indexWhere((p) => p.id == project.id);
    if (i == -1) throw const ApiException.notFound('Project not found.');
    _projects[i] = _projects[i].copyWith(
      name: project.name,
      description: project.description,
      colorHex: project.colorHex,
    );
    return _hydrateProject(_projects[i]);
  }

  @override
  Future<void> removeProject(String projectId) async {
    await _gate(write: true);
    _findProject(projectId); // throws if missing
    _projects.removeWhere((p) => p.id == projectId);
    _tasks.removeWhere((t) => t.projectId == projectId); // cascade
  }

  // ---------------- Tasks ----------------
  @override
  Future<List<TaskModel>> tasks({required String orgId, String? projectId}) async {
    await _gate();
    return _tasks
        .where((t) => t.orgId == orgId && (projectId == null || t.projectId == projectId))
        .map(_hydrateTask)
        .toList();
  }

  @override
  Future<TaskModel> task(String taskId) async {
    _errors.checkTaskId(taskId);
    await _gate();
    return _hydrateTask(_findTask(taskId));
  }

  @override
  Future<TaskModel> addTask(TaskModel task) async {
    _errors.checkTaskContent(task.title);
    await _gate(write: true);
    final id = task.id.isEmpty ? _newId('task') : task.id;
    _tasks.add(TaskModel(
      id: id,
      projectId: task.projectId,
      orgId: task.orgId,
      title: task.title,
      description: task.description,
      status: task.status,
      priority: task.priority,
      assigneeId: task.assigneeId,
      dueDate: task.dueDate,
      createdAt: task.createdAt ?? DateTime.now(),
    ));
    return _hydrateTask(_findTask(id));
  }

  @override
  Future<TaskModel> updateTask(TaskModel task) async {
    await _gate(write: true);
    final i = _tasks.indexWhere((t) => t.id == task.id);
    if (i == -1) throw const ApiException.notFound('Task not found.');
    _tasks[i] = _tasks[i].copyWith(
      title: task.title,
      description: task.description,
      status: task.status,
      priority: task.priority,
      dueDate: task.dueDate,
      assigneeId: task.assigneeId,
      clearAssignee: task.assigneeId == null,
    );
    return _hydrateTask(_tasks[i]);
  }

  @override
  Future<void> removeTask(String taskId) async {
    await _gate(write: true);
    _findTask(taskId);
    _tasks.removeWhere((t) => t.id == taskId);
  }

  // ---------------- helpers ----------------
  ProjectModel _findProject(String id) {
    final match = _projects.where((p) => p.id == id);
    if (match.isEmpty) throw const ApiException.notFound('Project not found.');
    return match.first;
  }

  TaskModel _findTask(String id) {
    final match = _tasks.where((t) => t.id == id);
    if (match.isEmpty) throw const ApiException.notFound('Task not found.');
    return match.first;
  }

  ProjectModel _hydrateProject(ProjectModel p) {
    final ts = _tasks.where((t) => t.projectId == p.id);
    return p.copyWith(
      totalTasks: ts.length,
      completedTasks: ts.where((t) => t.status == TaskStatus.done).length,
    );
  }

  TaskModel _hydrateTask(TaskModel t) {
    final proj = _projects.where((p) => p.id == t.projectId);
    final assignee = t.assigneeId == null ? null : _users.where((u) => u.id == t.assigneeId);
    return t.copyWith(
      projectName: proj.isEmpty ? '' : proj.first.name,
      projectColorValue: proj.isEmpty ? 0xFF4A6CF7 : proj.first.colorValue,
      assigneeName: (assignee == null || assignee.isEmpty) ? null : assignee.first.name,
      clearAssignee: t.assigneeId == null,
    );
  }

  String _newId(String prefix) => '${prefix}_${DateTime.now().microsecondsSinceEpoch}';

  Future<void> _ensure() async {
    if (!_loaded) await load();
  }

  Future<void> _gate({bool write = false}) async {
    await _ensure();
    if (_connectivity.isOffline) {
      throw const ApiException.offline();
    }
    _errors.maybeThrow();
    if (artificialDelay) {
      await Future.delayed(Duration(milliseconds: 300 + _rng.nextInt(500)));
    }
  }
}

class _Membership {
  final String orgId;
  final String userId;
  final MemberRole role;
  const _Membership(this.orgId, this.userId, this.role);

  factory _Membership.fromJson(Map<String, dynamic> j) =>
      _Membership(j['org_id'] as String, j['user_id'] as String, MemberRoleX.parse(j['role'] as String?));
}