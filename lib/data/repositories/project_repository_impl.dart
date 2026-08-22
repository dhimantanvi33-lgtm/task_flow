import '../../models/api_errors.dart';
import '../../models/project_model.dart';
import '../data_source/mock_data_source.dart';
import 'project_repository.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  ProjectRepositoryImpl(this._ds);
  final TaskFlowDataSource _ds;

  @override
  Future<List<ProjectModel>> getProjects(String orgId) => _ds.projects(orgId);

  @override
  Future<ProjectModel> getProject(String projectId) => _ds.project(projectId);

  @override
  Future<ProjectModel> createProject(ProjectModel project) {
    if (project.name.trim().isEmpty) {
      throw const ApiException.validation('Project name is required.');
    }
    return _ds.addProject(project);
  }

  @override
  Future<ProjectModel> updateProject(ProjectModel project) {
    if (project.name.trim().isEmpty) {
      throw const ApiException.validation('Project name is required.');
    }
    return _ds.updateProject(project);
  }

  @override
  Future<void> deleteProject(String projectId, {required bool isAdmin}) {
    if (!isAdmin) {
      throw const ApiException.forbidden('Only an admin can delete projects.');
    }
    return _ds.removeProject(projectId);
  }
}