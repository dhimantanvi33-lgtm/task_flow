import 'package:flutter/foundation.dart';

import '../core/view_state.dart';
import '../data/repositories/project_repository.dart';
import '../models/api_errors.dart';
import '../models/project_model.dart';
import 'auth_provider.dart';

class ProjectProvider extends ChangeNotifier {
  ProjectProvider(this._repo, this._auth);
  final ProjectRepository _repo;
  final AuthProvider _auth;

  ViewState<List<ProjectModel>> state = const ViewState.initial();

  bool get isAdmin => _auth.isAdmin;

  static const _palette = ['#4A6CF7', '#22C55E', '#F59E0B', '#8B5CF6', '#EF4444', '#06B6D4'];

  Future<void> load() async {
    state = const ViewState.loading();
    notifyListeners();
    try {
      await _auth.ensureValidToken();
      final list = await _repo.getProjects(_auth.orgId!); // org filtering
      state = list.isEmpty ? const ViewState.empty() : ViewState.success(list);
    } on ApiException catch (e) {
      state = ViewState.error(e.message);
    }
    notifyListeners();
  }

  Future<void> refresh() => load();

  Future<String?> createProject(String name, String description) async {
    final color = _palette[_currentList().length % _palette.length];
    final model = ProjectModel(id: '', orgId: _auth.orgId!, name: name, description: description, colorHex: color);
    return _mutate(() => _repo.createProject(model));
  }

  Future<String?> updateProject(String id, String name, String description) async {
    final existing = _currentList().where((p) => p.id == id).toList();
    final colorHex = existing.isEmpty ? '#4A6CF7' : existing.first.colorHex;
    final model = ProjectModel(id: id, orgId: _auth.orgId!, name: name, description: description, colorHex: colorHex);
    return _mutate(() => _repo.updateProject(model));
  }

  Future<String?> deleteProject(String id) =>
      _mutate(() => _repo.deleteProject(id, isAdmin: _auth.isAdmin));

  Future<String?> _mutate(Future<void> Function() action) async {
    try {
      await _auth.ensureValidToken();
      await action();
      await load();
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }

  List<ProjectModel> _currentList() {
    final s = state;
    return s is ViewSuccess<List<ProjectModel>> ? s.data : const [];
  }
}