
import 'package:flutter_test/flutter_test.dart';
import 'package:task_flow/models/task_model.dart';
import 'package:task_flow/provider/task_provider.dart';

void main() {
  TaskModel t({
    String id = 't',
    TaskStatus status = TaskStatus.todo,
    TaskPriority priority = TaskPriority.medium,
    String? assignee,
    DateTime? due,
  }) =>
      TaskModel(id: id, title: id, status: status, priority: priority, projectName: 'P', projectColorValue: 0xFF4A6CF7, assigneeId: assignee, dueDate: due);

  final tasks = [
    t(id: 'a', status: TaskStatus.todo, priority: TaskPriority.high, assignee: 'u1', due: DateTime(2026, 8, 20)),
    t(id: 'b', status: TaskStatus.inProgress, priority: TaskPriority.low, assignee: 'u2', due: DateTime(2026, 8, 25)),
    t(id: 'c', status: TaskStatus.done, priority: TaskPriority.high, assignee: 'u1', due: DateTime(2026, 9, 1)),
  ];

  test('empty filter returns everything', () {
    expect(const TaskFilter().apply(tasks).length, 3);
  });

  test('filters by status', () {
    final r = const TaskFilter(status: TaskStatus.inProgress).apply(tasks);
    expect(r.map((e) => e.id), ['b']);
  });

  test('filters by priority', () {
    final r = const TaskFilter(priority: TaskPriority.high).apply(tasks);
    expect(r.map((e) => e.id), ['a', 'c']);
  });

  test('filters by assignee', () {
    final r = const TaskFilter(assigneeId: 'u1').apply(tasks);
    expect(r.map((e) => e.id), ['a', 'c']);
  });

  test('filters by due-date range (inclusive of bounds)', () {
    final r = TaskFilter(dueFrom: DateTime(2026, 8, 21), dueTo: DateTime(2026, 8, 26)).apply(tasks);
    expect(r.map((e) => e.id), ['b']);
  });

  test('combines multiple criteria', () {
    final r = const TaskFilter(status: TaskStatus.done, priority: TaskPriority.high).apply(tasks);
    expect(r.map((e) => e.id), ['c']);
  });
}