import '../models/api_errors.dart';

class MockErrorService {
  MockErrorService();

  static const notFoundTaskId = 'task-404';
  static const timeoutTaskId = 'task-timeout';
  static const validationTaskToken = 'task-validation-error';
  static const timeoutProjectId = 'project-timeout';
  static const notFoundProjectId = 'project-404';

  ApiException? _forced;
  void force(ApiException error) => _forced = error;
  void clear() => _forced = null;
  bool get isForcing => _forced != null;

  void maybeThrow() {
    final forced = _forced;
    if (forced != null) throw forced;
  }

  void checkProjectId(String id) {
    if (id == timeoutProjectId) {
      throw const ApiException.timeout('Simulated network timeout.');
    }
    if (id == notFoundProjectId) {
      throw const ApiException.notFound('Project not found (simulated).');
    }
  }

  void checkTaskId(String id) {
    if (id == notFoundTaskId) {
      throw const ApiException.notFound('Task not found (simulated).');
    }
    if (id == timeoutTaskId) {
      throw const ApiException.timeout('Simulated network timeout.');
    }
    if (id == validationTaskToken) {
      throw const ApiException.validation('Simulated validation error.');
    }
  }

  void checkTaskContent(String title) {
    if (title.trim() == validationTaskToken) {
      throw const ApiException.validation('Simulated validation error.');
    }
  }
}