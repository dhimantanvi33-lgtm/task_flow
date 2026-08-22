import 'dart:convert';

import '../../models/api_errors.dart';
import '../../models/project_model.dart';
import '../data_source/local_storage_data_source.dart';
import '../data_source/mock_data_source.dart';
import 'project_repository.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  ProjectRepositoryImpl(this._ds, this._cache);
  final TaskFlowDataSource _ds;
  final LocalStorageDataSource _cache;

  @override
  Future<List<ProjectModel>> getProjects(String orgId) async {
    try {
      final list = await _ds.projects(orgId);
      await _cache.cache('projects_$orgId', jsonEncode(list.map(_toCache).toList()));
      return list;
    } on ApiException catch (e) {
      if (e.type == ApiErrorType.offline) {
        final cached = await _cache.readCache('projects_$orgId');
        if (cached != null) {
          return (jsonDecode(cached) as List).map((m) => _fromCache(m as Map<String, dynamic>)).toList();
        }
      }
      rethrow;
    }
  }

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

  Map<String, dynamic> _toCache(ProjectModel p) => {
    'id': p.id, 'orgId': p.orgId, 'name': p.name, 'description': p.description,
    'colorHex': p.colorHex, 'total': p.totalTasks, 'done': p.completedTasks,
  };

  ProjectModel _fromCache(Map<String, dynamic> m) => ProjectModel(
    id: m['id'] as String, orgId: m['orgId'] as String, name: m['name'] as String,
    description: (m['description'] as String?) ?? '', colorHex: (m['colorHex'] as String?) ?? '#4A6CF7',
    totalTasks: (m['total'] as num).toInt(), completedTasks: (m['done'] as num).toInt(),
  );
}