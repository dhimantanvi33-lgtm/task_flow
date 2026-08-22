import 'package:flutter_test/flutter_test.dart';
import 'package:task_flow/data/repositories/task_repository_impl.dart';
import 'package:task_flow/models/task_model.dart';

import '../../helpers/fakes.dart';
import '../../models/api_errors.dart';


void main() {
  TaskModel task(String id, {String assignee = ''}) => TaskModel(
    id: id, projectId: 'p1', orgId: 'org_a', title: 'T', status: TaskStatus.todo, priority: TaskPriority.medium,
    assigneeId: assignee.isEmpty ? null : assignee,
  );

  test('createTask rejects an empty title (validation)', () async {
    final repo = TaskRepositoryImpl(FakeDataSource(), FakeCache());
    expect(
          () => repo.createTask(TaskModel(id: '', projectId: 'p1', orgId: 'org_a', title: '   ', status: TaskStatus.todo, priority: TaskPriority.low)),
      throwsA(isA<ApiException>().having((e) => e.type, 'type', ApiErrorType.validation)),
    );
  });

  test('assignTask rejects a user outside the org (validation)', () async {
    final repo = TaskRepositoryImpl(
      FakeDataSource(tasks: [task('t1')], memberIds: {'usr_in'}),
      FakeCache(),
    );
    expect(
          () => repo.assignTask('t1', 'usr_out'),
      throwsA(isA<ApiException>().having((e) => e.type, 'type', ApiErrorType.validation)),
    );
  });

  test('assignTask sets the assignee for an org member', () async {
    final repo = TaskRepositoryImpl(
      FakeDataSource(tasks: [task('t1')], memberIds: {'usr_in'}),
      FakeCache(),
    );
    final updated = await repo.assignTask('t1', 'usr_in');
    expect(updated.assigneeId, 'usr_in');
  });
}