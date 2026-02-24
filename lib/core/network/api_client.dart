library;

import 'package:dio/dio.dart';

import '../constants/api_endpoints.dart';

/// Provides authenticated HTTP client for driver-garage-backend.
/// Injects [getToken] so token can be read from secure storage.
class ApiClient {
  ApiClient({required this.getToken}) {
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
    ));
  }

  final Future<String?> Function() getToken;
  late final Dio _dio;

  Dio get dio => _dio;
}
