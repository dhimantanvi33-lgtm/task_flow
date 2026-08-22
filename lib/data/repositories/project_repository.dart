import '../../models/project_model.dart';

abstract class ProjectRepository {
  Future<List<ProjectModel>> getProjects(String orgId);
  Future<ProjectModel> getProject(String projectId);
  Future<ProjectModel> createProject(ProjectModel project);
  Future<ProjectModel> updateProject(ProjectModel project);
  Future<void> deleteProject(String projectId, {required bool isAdmin});
}