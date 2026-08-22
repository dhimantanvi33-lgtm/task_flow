import '../../models/api_errors.dart';
import '../../models/task_model.dart';
import '../../models/user_model.dart';
import '../data_source/mock_data_source.dart';
import 'task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl(this._ds);
  final TaskFlowDataSource _ds;

  @override
  Future<List<TaskModel>> getTasks(String orgId, {String? projectId}) =>
      _ds.tasks(orgId: orgId, projectId: projectId);

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
}