library;

import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../models/maintenance_history_model.dart';
import '../models/maintenance_upcoming_model.dart';
import 'maintenance_remote_datasource.dart';

class MaintenanceRemoteDataSourceImpl implements MaintenanceRemoteDataSource {
  MaintenanceRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<List<MaintenanceUpcomingModel>> listUpcoming() async {
    final res = await _dio.get<dynamic>(ApiEndpoints.driverMaintenanceUpcoming);
    final data = res.data;
    final list = _asList(data);
    return list
        .map((e) => MaintenanceUpcomingModel.fromJson(e is Map<String, dynamic> ? e : null))
        .where((m) => m.id.isNotEmpty)
        .toList();
  }

  @override
  Future<List<MaintenanceHistoryModel>> listHistory() async {
    final res = await _dio.get<dynamic>(ApiEndpoints.driverMaintenanceHistory);
    final data = res.data;
    final list = _asList(data);
    return list
        .map((e) => MaintenanceHistoryModel.fromJson(e is Map<String, dynamic> ? e : null))
        .where((m) => m.id.isNotEmpty)
        .toList();
  }

  @override
  Future<MaintenanceUpcomingModel> createUpcoming({
    required String title,
    required DateTime scheduledAt,
    String? estimatedCost,
    required String vehicleId,
  }) async {
    final res = await _dio.post<dynamic>(
      ApiEndpoints.driverMaintenanceUpcoming,
      data: {
        // Backend (driver-maintenance-yordi): serviceName, scheduledDate, vehicleId
        'serviceName': title,
        'scheduledDate': scheduledAt.toIso8601String(),
        'vehicleId': vehicleId,
        if (estimatedCost != null && estimatedCost.trim().isNotEmpty) 'estimatedCost': estimatedCost.trim(),
      },
    );
    final data = res.data;
    if (data is Map<String, dynamic>) return MaintenanceUpcomingModel.fromJson(data);
    if (data is Map) return MaintenanceUpcomingModel.fromJson(Map<String, dynamic>.from(data));
    return MaintenanceUpcomingModel.fromJson(null);
  }

  @override
  Future<void> deleteUpcoming(String id) async {
    await _dio.delete(ApiEndpoints.driverMaintenanceUpcomingById(id));
  }

  @override
  Future<void> deleteHistory(String id) async {
    await _dio.delete(ApiEndpoints.driverMaintenanceHistoryById(id));
  }

  @override
  Future<MaintenanceUpcomingModel> toggleReminder(String id) async {
    final res = await _dio.patch<dynamic>(ApiEndpoints.driverMaintenanceUpcomingToggleReminder(id));
    final data = res.data;
    if (data is Map<String, dynamic>) return MaintenanceUpcomingModel.fromJson(data);
    if (data is Map) return MaintenanceUpcomingModel.fromJson(Map<String, dynamic>.from(data));
    return MaintenanceUpcomingModel.fromJson(null);
  }

  static List<dynamic> _asList(dynamic raw) {
    if (raw is List) return raw;
    if (raw is Map && raw['data'] is List) return raw['data'] as List;
    if (raw is Map && raw['items'] is List) return raw['items'] as List;
    return const [];
  }
}

