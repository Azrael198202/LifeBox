import 'dart:convert';

enum ApiErrorKey {
  invalidRequest,
  unauthorized,
  forbidden,
  notFound,
  conflict,
  validationError,
  serverError,
  unknown,
}

class ApiException implements Exception {
  final int statusCode;
  final ApiErrorKey errorKey;
  final dynamic raw;

  const ApiException({
    required this.statusCode,
    required this.errorKey,
    this.raw,
  });

  @override
  String toString() => errorKey.name;

  factory ApiException.fromHttp({
    required int statusCode,
    required String body,
  }) {
    return ApiException(
      statusCode: statusCode,
      errorKey: _mapStatusToKey(statusCode),
      raw: body,
    );
  }

  static ApiErrorKey _mapStatusToKey(int code) {
    switch (code) {
      case 400:
        return ApiErrorKey.invalidRequest;
      case 401:
        return ApiErrorKey.unauthorized;
      case 403:
        return ApiErrorKey.forbidden;
      case 404:
        return ApiErrorKey.notFound;
      case 409:
        return ApiErrorKey.conflict;
      case 422:
        return ApiErrorKey.validationError;
      default:
        if (code >= 500) {
          return ApiErrorKey.serverError;
        }
        return ApiErrorKey.unknown;
    }
  }
}
