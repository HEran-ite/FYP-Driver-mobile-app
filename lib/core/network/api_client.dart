library;

import 'package:dio/dio.dart';

import '../constants/api_endpoints.dart';

/// Provides authenticated HTTP client for driver-garage-backend.
/// Injects [getToken] so token can be read from secure storage.
class ApiClient {
  ApiClient({
    required this.getToken,
    required this.clearSession,
    required this.onSessionExpired,
  }) {
    _dio = Dio(BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    ));
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await getToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      // Dio's default [validateStatus] treats 401 as success, so [onError] never
      // runs. Turn 401 responses into errors so session handling runs.
      onResponse: (response, handler) {
        final code = response.statusCode;
        if (code != 401 && code != 403) {
          return handler.next(response);
        }
        if (_isPublicAuthPath(response.requestOptions)) {
          return handler.next(response);
        }
        return handler.reject(
          DioException(
            requestOptions: response.requestOptions,
            response: response,
            type: DioExceptionType.badResponse,
          ),
        );
      },
      onError: (err, handler) async {
        final code = err.response?.statusCode;
        if (code != 401 && code != 403) {
          return handler.next(err);
        }
        if (_isPublicAuthPath(err.requestOptions)) {
          return handler.next(err);
        }
        if (_handlingUnauthorized) return handler.next(err);
        _handlingUnauthorized = true;
        try {
          await clearSession();
          onSessionExpired();
        } catch (_) {
          // Still surface the error to the caller.
        } finally {
          _handlingUnauthorized = false;
        }
        return handler.next(err);
      },
    ));
  }

  static bool _isPublicAuthPath(RequestOptions o) {
    final path = o.path.isNotEmpty ? o.path : o.uri.path;
    return path == ApiEndpoints.driverAuthLogin ||
        path == ApiEndpoints.driverAuthSignup ||
        path.endsWith(ApiEndpoints.driverAuthLogin) ||
        path.endsWith(ApiEndpoints.driverAuthSignup);
  }

  final Future<String?> Function() getToken;
  final Future<void> Function() clearSession;
  final void Function() onSessionExpired;

  bool _handlingUnauthorized = false;
  late final Dio _dio;

  Dio get dio => _dio;
}
