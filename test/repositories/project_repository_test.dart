import 'package:flutter_test/flutter_test.dart';
import 'package:task_flow/data/repositories/project_repository_impl.dart';
import 'package:task_flow/models/project_model.dart';

import '../../helpers/fakes.dart';
import '../../models/api_errors.dart';

void main() {
  ProjectRepositoryImpl build({List<ProjectModel>? projects}) =>
      ProjectRepositoryImpl(FakeDataSource(projects: projects ?? const []), FakeCache());

  test('getProjects returns only the org\'s projects', () async {
    final repo = build(projects: const [
      ProjectModel(id: 'p1', orgId: 'org_a', name: 'A', description: '', colorHex: '#4A6CF7', totalTasks: 0, completedTasks: 0),
      ProjectModel(id: 'p2', orgId: 'org_b', name: 'B', description: '', colorHex: '#22C55E', totalTasks: 0, completedTasks: 0),
    ]);
    final list = await repo.getProjects('org_a');
    expect(list.length, 1);
    expect(list.single.id, 'p1');
  });

  test('createProject rejects an empty name (validation)', () async {
    final repo = build();
    expect(
          () => repo.createProject(const ProjectModel(id: '', orgId: 'org_a', name: '  ', description: '', colorHex: '#4A6CF7', totalTasks: 0, completedTasks: 0)),
      throwsA(isA<ApiException>().having((e) => e.type, 'type', ApiErrorType.validation)),
    );
  });

  test('deleteProject is blocked for non-admins (forbidden)', () async {
    final repo = build(projects: const [
      ProjectModel(id: 'p1', orgId: 'org_a', name: 'A', description: '', colorHex: '#4A6CF7', totalTasks: 0, completedTasks: 0),
    ]);
    expect(
          () => repo.deleteProject('p1', isAdmin: false),
      throwsA(isA<ApiException>().having((e) => e.type, 'type', ApiErrorType.forbidden)),
    );
    // still present
    expect((await repo.getProjects('org_a')).length, 1);
  });

  test('deleteProject succeeds for admins', () async {
    final repo = build(projects: const [
      ProjectModel(id: 'p1', orgId: 'org_a', name: 'A', description: '', colorHex: '#4A6CF7', totalTasks: 0, completedTasks: 0),
    ]);
    await repo.deleteProject('p1', isAdmin: true);
    expect((await repo.getProjects('org_a')).isEmpty, true);
  });
}