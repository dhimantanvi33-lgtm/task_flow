import 'package:flutter/foundation.dart';

import '../core/view_state.dart';
import '../data/repositories/task_repository.dart';
import '../models/api_errors.dart';
import '../models/task_model.dart';
import 'auth_provider.dart';

class TaskFilter {
  final TaskStatus? status;
  final TaskPriority? priority;
  final String? assigneeId;
  final DateTime? dueFrom;
  final DateTime? dueTo;

  const TaskFilter({this.status, this.priority, this.assigneeId, this.dueFrom, this.dueTo});

  bool get isEmpty => status == null && priority == null && assigneeId == null && dueFrom == null && dueTo == null;

  TaskFilter copyWith({
    TaskStatus? status,
    TaskPriority? priority,
    String? assigneeId,
    DateTime? dueFrom,
    DateTime? dueTo,
    bool clearStatus = false,
    bool clearPriority = false,
    bool clearAssignee = false,
    bool clearDates = false,
  }) =>
      TaskFilter(
        status: clearStatus ? null : (status ?? this.status),
        priority: clearPriority ? null : (priority ?? this.priority),
        assigneeId: clearAssignee ? null : (assigneeId ?? this.assigneeId),
        dueFrom: clearDates ? null : (dueFrom ?? this.dueFrom),
        dueTo: clearDates ? null : (dueTo ?? this.dueTo),
      );

  List<TaskModel> apply(List<TaskModel> tasks) => tasks.where((t) {
    if (status != null && t.status != status) return false;
    if (priority != null && t.priority != priority) return false;
    if (assigneeId != null && t.assigneeId != assigneeId) return false;
    if (dueFrom != null && (t.dueDate == null || t.dueDate!.isBefore(dueFrom!))) return false;
    if (dueTo != null && (t.dueDate == null || t.dueDate!.isAfter(dueTo!))) return false;
    return true;
  }).toList();
}

class TaskProvider extends ChangeNotifier {
  TaskProvider(this._repo, this._auth, {this.projectId});
  final TaskRepository _repo;
  final AuthProvider _auth;
  final String? projectId;

  ViewState<List<TaskModel>> state = const ViewState.initial();
  TaskFilter filter = const TaskFilter();
  List<TaskModel> _all = [];

  List<TaskModel> get allTasks => _all;

  Map<TaskStatus, int> get statusCounts => {
    for (final s in TaskStatus.values) s: _all.where((t) => t.status == s).length,
  };

  Future<void> load() async {
    state = const ViewState.loading();
    notifyListeners();
    try {
      await _auth.ensureValidToken();
      _all = await _repo.getTasks(_auth.orgId!, projectId: projectId);
      _apply();
    } on ApiException catch (e) {
      state = ViewState.error(e.message);
    }
    notifyListeners();
  }

  Future<void> refresh() => load();

  void setFilter(TaskFilter f) {
    filter = f;
    _apply();
    notifyListeners();
  }

  void clearFilter() {
    filter = const TaskFilter();
    _apply();
    notifyListeners();
  }

  void _apply() {
    final visible = filter.apply(_all);
    state = visible.isEmpty ? const ViewState.empty() : ViewState.success(visible);
  }

  Future<String?> createTask({
    required String projectId,
    required String title,
    String description = '',
    TaskPriority priority = TaskPriority.medium,
    DateTime? dueDate,
  }) =>
      _mutate(() => _repo.createTask(TaskModel(
        id: '',
        projectId: projectId,
        orgId: _auth.orgId!,
        title: title,
        description: description,
        status: TaskStatus.todo,
        priority: priority,
        dueDate: dueDate,
      )));

  Future<String?> updateStatus(TaskModel task, TaskStatus status) =>
      _mutate(() => _repo.updateTask(task.copyWith(status: status)));

  Future<String?> updatePriority(TaskModel task, TaskPriority priority) =>
      _mutate(() => _repo.updateTask(task.copyWith(priority: priority)));

  Future<String?> assign(String taskId, String? userId) =>
      _mutate(() => _repo.assignTask(taskId, userId));

  Future<String?> deleteTask(String taskId) => _mutate(() => _repo.deleteTask(taskId));

  Future<String?> _mutate(Future<Object?> Function() action) async {
    try {
      await _auth.ensureValidToken();
      await action();
      await load();
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }
}