import 'dart:convert';

import '../../models/api_errors.dart';
import '../../models/task_model.dart';
import '../../models/user_model.dart';
import '../data_source/local_storage_data_source.dart';
import '../data_source/mock_data_source.dart';
import 'task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl(this._ds, this._cache);
  final TaskFlowDataSource _ds;
  final LocalStorageDataSource _cache;

  @override
  Future<List<TaskModel>> getTasks(String orgId, {String? projectId}) async {
    final key = 'tasks_${orgId}_${projectId ?? 'all'}';
    try {
      final list = await _ds.tasks(orgId: orgId, projectId: projectId);
      await _cache.cache(key, jsonEncode(list.map(_toCache).toList()));
      return list;
    } on ApiException catch (e) {
      if (e.type == ApiErrorType.offline) {
        final cached = await _cache.readCache(key);
        if (cached != null) {
          return (jsonDecode(cached) as List).map((m) => _fromCache(m as Map<String, dynamic>)).toList();
        }
      }
      rethrow;
    }
  }

  @override
  Future<TaskModel> getTask(String taskId) => _ds.task(taskId);

  @override
  Future<TaskModel> createTask(TaskModel task) {
    if (task.title.trim().isEmpty) {
      throw const ApiException.validation('Task title is required.');
    }
    return _ds.addTask(task);
  }

  @override
  Future<TaskModel> updateTask(TaskModel task) => _ds.updateTask(task);

  @override
  Future<void> deleteTask(String taskId) => _ds.removeTask(taskId);

  @override
  Future<TaskModel> assignTask(String taskId, String? userId) async {
    final task = await _ds.task(taskId);
    if (userId != null) {
      final belongs = await _ds.isMember(userId, task.orgId);
      if (!belongs) {
        throw const ApiException.validation('That user is not a member of this organization.');
      }
    }
    return _ds.updateTask(task.copyWith(assigneeId: userId, clearAssignee: userId == null));
  }

  @override
  Future<List<UserModel>> getOrgMembers(String orgId) => _ds.orgMembers(orgId);

  Map<String, dynamic> _toCache(TaskModel t) => {
    'id': t.id, 'projectId': t.projectId, 'orgId': t.orgId, 'title': t.title, 'description': t.description,
    'status': t.status.wire, 'priority': t.priority.wire, 'assigneeId': t.assigneeId, 'assigneeName': t.assigneeName,
    'dueDate': t.dueDate?.toIso8601String(), 'projectName': t.projectName, 'projectColor': t.projectColorValue,
  };

  TaskModel _fromCache(Map<String, dynamic> m) => TaskModel(
    id: m['id'] as String, projectId: (m['projectId'] as String?) ?? '', orgId: (m['orgId'] as String?) ?? '',
    title: m['title'] as String, description: (m['description'] as String?) ?? '',
    status: TaskStatusX.parse(m['status'] as String?), priority: TaskPriorityX.parse(m['priority'] as String?),
    assigneeId: m['assigneeId'] as String?, assigneeName: m['assigneeName'] as String?,
    dueDate: m['dueDate'] == null ? null : DateTime.tryParse(m['dueDate'] as String),
    projectName: (m['projectName'] as String?) ?? '', projectColorValue: (m['projectColor'] as num?)?.toInt() ?? 0xFF4A6CF7,
  );
}