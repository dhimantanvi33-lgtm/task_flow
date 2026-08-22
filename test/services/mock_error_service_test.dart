import 'package:flutter_test/flutter_test.dart';
import 'package:task_flow/models/api_errors.dart';
import 'package:task_flow/service/mock_error_service.dart';

void main() {
  late MockErrorService service;
  setUp(() => service = MockErrorService());

  Matcher throwsApi(ApiErrorType type) =>
      throwsA(isA<ApiException>().having((e) => e.type, 'type', type));

  test('task-404 -> notFound', () {
    expect(() => service.checkTaskId('task-404'), throwsApi(ApiErrorType.notFound));
  });

  test('task-timeout -> timeout', () {
    expect(() => service.checkTaskId('task-timeout'), throwsApi(ApiErrorType.timeout));
  });

  test('project-timeout -> timeout', () {
    expect(() => service.checkProjectId('project-timeout'), throwsApi(ApiErrorType.timeout));
  });

  test('project-404 -> notFound', () {
    expect(() => service.checkProjectId('project-404'), throwsApi(ApiErrorType.notFound));
  });

  test('task-validation-error (id and title) -> validation', () {
    expect(() => service.checkTaskId('task-validation-error'), throwsApi(ApiErrorType.validation));
    expect(() => service.checkTaskContent('task-validation-error'), throwsApi(ApiErrorType.validation));
  });

  test('normal ids/titles do not throw', () {
    expect(() => service.checkTaskId('task_nb_1'), returnsNormally);
    expect(() => service.checkProjectId('proj_nb_1'), returnsNormally);
    expect(() => service.checkTaskContent('Write docs'), returnsNormally);
  });

  test('maybeThrow raises the forced error until cleared', () {
    expect(() => service.maybeThrow(), returnsNormally);

    service.force(const ApiException.timeout('forced'));
    expect(() => service.maybeThrow(), throwsApi(ApiErrorType.timeout));

    service.clear();
    expect(() => service.maybeThrow(), returnsNormally);
  });
}