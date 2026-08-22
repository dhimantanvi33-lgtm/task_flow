import '../../models/task_model.dart';
import '../../models/user_model.dart';

abstract class TaskRepository {
  Future<List<TaskModel>> getTasks(String orgId, {String? projectId});
  Future<TaskModel> getTask(String taskId);
  Future<TaskModel> createTask(TaskModel task);
  Future<TaskModel> updateTask(TaskModel task);
  Future<void> deleteTask(String taskId);
  Future<TaskModel> assignTask(String taskId, String? userId);
  Future<List<UserModel>> getOrgMembers(String orgId);
}