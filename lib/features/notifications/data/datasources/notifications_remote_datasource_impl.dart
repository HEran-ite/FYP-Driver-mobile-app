library;

import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../models/driver_notification_model.dart';
import 'notifications_remote_datasource.dart';

class NotificationsRemoteDataSourceImpl
    implements NotificationsRemoteDataSource {
  NotificationsRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<List<DriverNotificationModel>> listNotifications() async {
    final res = await _dio.get<dynamic>(ApiEndpoints.driverNotifications);
    final data = res.data;
    final list = _asList(data);
    return list
        .map(
          (e) => DriverNotificationModel.fromJson(
            e is Map<String, dynamic> ? e : null,
          ),
        )
        .where((m) => m.id.isNotEmpty)
        .toList();
  }

  @override
  Future<void> markRead(String id) async {
    await _dio.patch(ApiEndpoints.driverNotificationRead(id));
  }

  @override
  Future<void> markAllRead() async {
    await _dio.patch(ApiEndpoints.driverNotificationsReadAll);
  }

  static List<dynamic> _asList(dynamic raw) {
    if (raw is List) return raw;
    if (raw is Map && raw['data'] is List) return raw['data'] as List;
    if (raw is Map && raw['items'] is List) return raw['items'] as List;
    return const [];
  }
}
