import 'package:flutter_test/flutter_test.dart';
import 'package:task_flow/core/view_state.dart';
import 'package:task_flow/data/repositories/project_repository.dart';
import 'package:task_flow/models/project_model.dart';
import 'package:task_flow/models/user_model.dart';
import 'package:task_flow/provider/project_provider.dart';

import '../helpers/fakes.dart';
import '../models/api_errors.dart';
import '../service/auth_service.dart';
import 'auth_provider.dart';

class _OkRepo implements ProjectRepository {
  _OkRepo(this._list);
  final List<ProjectModel> _list;
  @override
  Future<List<ProjectModel>> getProjects(String orgId) async => _list;
  @override
  Future<ProjectModel> getProject(String id) => throw UnimplementedError();
  @override
  Future<ProjectModel> createProject(ProjectModel p) => throw UnimplementedError();
  @override
  Future<ProjectModel> updateProject(ProjectModel p) => throw UnimplementedError();
  @override
  Future<void> deleteProject(String id, {required bool isAdmin}) => throw UnimplementedError();
}

class _ErrRepo implements ProjectRepository {
  @override
  Future<List<ProjectModel>> getProjects(String orgId) async => throw const ApiException.network('boom');
  @override
  Future<ProjectModel> getProject(String id) => throw UnimplementedError();
  @override
  Future<ProjectModel> createProject(ProjectModel p) => throw UnimplementedError();
  @override
  Future<ProjectModel> updateProject(ProjectModel p) => throw UnimplementedError();
  @override
  Future<void> deleteProject(String id, {required bool isAdmin}) => throw UnimplementedError();
}

AuthProvider _auth() {
  final a = AuthProvider(AuthService(FakeAuthRepository(), FakeCache()));
  a.orgId = 'org_a';
  a.currentUser = const UserModel(id: 'u1', name: 'Ava', email: 'a@a.test', role: MemberRole.orgAdmin);
  return a;
}

void main() {
  test('load with data -> ViewSuccess', () async {
    final p = ProjectProvider(_OkRepo(const [
      ProjectModel(id: 'p1', orgId: 'org_a', name: 'A', description: '', colorHex: '#4A6CF7', totalTasks: 0, completedTasks: 0),
    ]), _auth());
    await p.load();
    expect(p.state, isA<ViewSuccess<List<ProjectModel>>>());
  });

  test('load with no data -> ViewEmpty', () async {
    final p = ProjectProvider(_OkRepo(const []), _auth());
    await p.load();
    expect(p.state, isA<ViewEmpty<List<ProjectModel>>>());
  });

  test('load failure -> ViewError with message', () async {
    final p = ProjectProvider(_ErrRepo(), _auth());
    await p.load();
    expect(p.state, isA<ViewError<List<ProjectModel>>>());
    expect((p.state as ViewError).message, 'boom');
  });
}