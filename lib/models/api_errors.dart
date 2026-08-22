enum ApiErrorType { network, timeout, notFound, validation, forbidden, unauthorized, offline, unknown }

class ApiException implements Exception {
  final ApiErrorType type;
  final String message;
  const ApiException(this.type, this.message);

  const ApiException.network([this.message = 'Something went wrong. Please try again.']) : type = ApiErrorType.network;
  const ApiException.timeout([this.message = 'The request timed out.']) : type = ApiErrorType.timeout;
  const ApiException.notFound([this.message = 'Not found.']) : type = ApiErrorType.notFound;
  const ApiException.validation(this.message) : type = ApiErrorType.validation;
  const ApiException.forbidden([this.message = 'You do not have permission to do this.']) : type = ApiErrorType.forbidden;
  const ApiException.unauthorized([this.message = 'Invalid email or password.']) : type = ApiErrorType.unauthorized;
  const ApiException.offline([this.message = 'You are offline.']) : type = ApiErrorType.offline;

  @override
  String toString() => 'ApiException($type, $message)';
}