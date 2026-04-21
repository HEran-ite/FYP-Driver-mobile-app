library;

import 'dart:convert';
import 'dart:io' show Platform;

import 'package:dio/dio.dart';
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
          final uid = await _getUserId();
          if (uid != null && uid.isNotEmpty) {
            options.headers['X-User-Id'] = uid;
          }
          // TODO: move to Authorization: Bearer <jwt> when backend enforces it.
          return handler.next(options);
        },
      ),
    );
  }

  final AuthLocalDataSource _authLocal;
  final Dio _dio;

  static String _resolveBaseUrl() {
    final env =
        dotenv.env['AI_API_BASE_URL']?.trim() ??
        dotenv.env['FASTAPI_BASE_URL']?.trim() ??
        '';
    if (env.isNotEmpty) return env;
    if (Platform.isAndroid) return 'http://10.0.2.2:8000';
    return 'http://localhost:8000';
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

  Future<String?> _getUserId() async {
    final raw = await _authLocal.getUserJson();
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final map = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      final id =
          map['id']?.toString().trim() ??
          map['_id']?.toString().trim() ??
          map['userId']?.toString().trim();
      if (id == null || id.isEmpty) return null;
      return id;
    } catch (_) {
      return null;
    }
  }
}
