library;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../auth/data/datasources/auth_local_datasource.dart';

class AiApiClient {
  AiApiClient({
    required AuthLocalDataSource authLocal,
    Dio? dio,
  })  : _authLocal = authLocal,
        _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: _resolveBaseUrl(),
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 30),
                headers: const {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              ),
            ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Option B (Supabase Auth -> RAG):
          // Prefer explicit bearer token from `.env` (Supabase access token).
          final envToken = (dotenv.env['AI_AUTH_BEARER_TOKEN'] ?? '').trim();
          if (_looksLikeJwt(envToken)) {
            options.headers['Authorization'] = 'Bearer $envToken';
            return handler.next(options);
          }
          if (kDebugMode && envToken.isNotEmpty) {
            debugPrint(
              'AI_AUTH_BEARER_TOKEN is set but not a JWT; falling back to stored login token.',
            );
          }

          // Fallback: use app's stored auth token if present.
          final token = await _authLocal.getToken();
          final trimmed = token?.trim() ?? '';
          if (trimmed.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $trimmed';
          }
          return handler.next(options);
        },
      ),
    );
  }

  final AuthLocalDataSource _authLocal;
  final Dio _dio;

  static String _resolveBaseUrl() {
    final env = dotenv.env['AI_API_BASE_URL']?.trim() ?? '';
    if (env.isEmpty) {
      throw StateError(
        'Missing AI_API_BASE_URL in .env. Example: AI_API_BASE_URL=https://rag-system-iig7.onrender.com',
      );
    }
    return env.endsWith('/') ? env.substring(0, env.length - 1) : env;
  }

  Future<Map<String, dynamic>> createSession({
    String? vehicleId,
    String? title,
  }) async {
    final payload = <String, dynamic>{};
    if (vehicleId != null && vehicleId.trim().isNotEmpty) {
      payload['vehicle_id'] = vehicleId.trim();
    }
    if (title != null && title.trim().isNotEmpty) {
      payload['title'] = title.trim();
    }
    final res = await _dio.post<Map<String, dynamic>>('/sessions', data: payload);
    return res.data ?? <String, dynamic>{};
  }

  Future<List<Map<String, dynamic>>> listSessions() async {
    final res = await _dio.get<dynamic>('/sessions');
    final data = res.data;
    if (data is List) {
      return data.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    }
    if (data is Map && data['items'] is List) {
      final items = data['items'] as List<dynamic>;
      return items.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return const [];
  }

  Future<Map<String, dynamic>> getMessages(
    String sessionId, {
    String? before,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/sessions/$sessionId/messages',
      queryParameters: {
        if (before != null && before.trim().isNotEmpty) 'before': before.trim(),
      },
    );
    return res.data ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> sendMessage(
    String sessionId, {
    required String message,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/sessions/$sessionId/messages',
      data: {'message': message},
    );
    return res.data ?? <String, dynamic>{};
  }

  Future<void> deleteSession(String sessionId) async {
    await _dio.delete('/sessions/$sessionId');
  }

  bool _looksLikeJwt(String token) {
    if (token.isEmpty) return false;
    final parts = token.split('.');
    return parts.length == 3 &&
        parts[0].isNotEmpty &&
        parts[1].isNotEmpty &&
        parts[2].isNotEmpty;
  }
}
