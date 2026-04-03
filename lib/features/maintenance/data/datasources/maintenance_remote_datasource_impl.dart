library;

import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../models/maintenance_catalog_model.dart';
import '../models/maintenance_history_model.dart';
import '../models/maintenance_upcoming_model.dart';
import '../models/vehicle_health_model.dart';
import 'maintenance_remote_datasource.dart';

class MaintenanceRemoteDataSourceImpl implements MaintenanceRemoteDataSource {
  MaintenanceRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<MaintenanceCatalogResponseModel> getCatalog() async {
    final res = await _dio.get<dynamic>(ApiEndpoints.driverMaintenanceCatalog);
    final data = res.data;
    if (data is Map<String, dynamic>) return MaintenanceCatalogResponseModel.fromJson(data);
    if (data is Map) return MaintenanceCatalogResponseModel.fromJson(Map<String, dynamic>.from(data));
    return const MaintenanceCatalogResponseModel(presets: []);
  }

  @override
  Future<VehicleHealthModel> getVehicleHealth(String vehicleId) async {
    final id = vehicleId.trim();
    if (id.isEmpty) {
      return VehicleHealthModelParser.fromJson(const <String, dynamic>{});
    }
    final res = await _dio.get<dynamic>(ApiEndpoints.driverMaintenanceVehicleHealth(id));
    var data = res.data;
    if (data is String && data.trim().isNotEmpty) {
      try {
        data = jsonDecode(data);
      } catch (_) {}
    }
    return VehicleHealthModelParser.fromJson(data);
  }

  @override
  Future<List<MaintenanceUpcomingModel>> listUpcoming({
    String? vehicleId,
    bool includeCompleted = false,
  }) async {
    final q = <String, dynamic>{};
    if (vehicleId != null && vehicleId.trim().isNotEmpty) {
      q['vehicleId'] = vehicleId.trim();
    }
    if (includeCompleted) {
      q['includeCompleted'] = 'true';
    }
    final res = await _dio.get<dynamic>(
      ApiEndpoints.driverMaintenanceUpcoming,
      queryParameters: q.isEmpty ? null : q,
    );
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
  Future<MaintenanceHistoryModel> createHistory({
    String? vehicleId,
    required String serviceName,
    String? garageName,
    required DateTime serviceDate,
    num? cost,
    String? notes,
  }) async {
    final body = <String, dynamic>{
      'serviceName': serviceName.trim(),
      'serviceDate': serviceDate.toIso8601String(),
      if (vehicleId != null && vehicleId.trim().isNotEmpty) 'vehicleId': vehicleId.trim(),
      if (garageName != null && garageName.trim().isNotEmpty) 'garageName': garageName.trim(),
      if (cost != null) 'cost': cost,
      if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
    };
    final res = await _dio.post<dynamic>(ApiEndpoints.driverMaintenanceHistory, data: body);
    final data = res.data;
    if (data is Map<String, dynamic>) return MaintenanceHistoryModel.fromJson(data);
    if (data is Map) return MaintenanceHistoryModel.fromJson(Map<String, dynamic>.from(data));
    return MaintenanceHistoryModel.fromJson(null);
  }

  @override
  Future<MaintenanceHistoryModel> updateHistory({
    required String id,
    String? vehicleId,
    required String serviceName,
    String? garageName,
    required DateTime serviceDate,
    num? cost,
    String? notes,
  }) async {
    final g = garageName?.trim();
    final n = notes?.trim();
    final v = vehicleId?.trim();
    final body = <String, dynamic>{
      'serviceName': serviceName.trim(),
      'serviceDate': serviceDate.toIso8601String(),
      'garageName': (g == null || g.isEmpty) ? null : g,
      'cost': cost,
      'notes': (n == null || n.isEmpty) ? null : n,
      'vehicleId': (v == null || v.isEmpty) ? null : v,
    };
    final res = await _dio.patch<dynamic>(
      ApiEndpoints.driverMaintenanceHistoryById(id),
      data: body,
    );
    final data = res.data;
    if (data is Map<String, dynamic>) return MaintenanceHistoryModel.fromJson(data);
    if (data is Map) return MaintenanceHistoryModel.fromJson(Map<String, dynamic>.from(data));
    return MaintenanceHistoryModel.fromJson(null);
  }

  @override
  Future<MaintenanceUpcomingModel> createUpcoming({
    required String vehicleId,
    required String presetCategory,
    String? customServiceName,
    required DateTime scheduledAt,
    num? estimatedCostMin,
    num? estimatedCostMax,
    String? notes,
  }) async {
    final body = <String, dynamic>{
      'vehicleId': vehicleId,
      'presetCategory': presetCategory,
      'scheduledDate': scheduledAt.toIso8601String(),
      if (customServiceName != null && customServiceName.trim().isNotEmpty) 'customServiceName': customServiceName.trim(),
      if (estimatedCostMin != null) 'estimatedCostMin': estimatedCostMin,
      if (estimatedCostMax != null) 'estimatedCostMax': estimatedCostMax,
      if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
    };
    final res = await _dio.post<dynamic>(
      ApiEndpoints.driverMaintenanceUpcoming,
      data: body,
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

  @override
  Future<MaintenanceUpcomingModel> markReminderDone(String id) async {
    final res = await _dio.patch<dynamic>(ApiEndpoints.driverMaintenanceUpcomingMarkDone(id));
    final data = res.data;
    if (data is Map<String, dynamic>) return MaintenanceUpcomingModel.fromJson(data);
    if (data is Map) return MaintenanceUpcomingModel.fromJson(Map<String, dynamic>.from(data));
    return MaintenanceUpcomingModel.fromJson(null);
  }

  static List<dynamic> _asList(dynamic raw) {
    if (raw is List) return raw;
    if (raw is Map) {
      for (final key in ['data', 'items', 'records', 'history', 'results']) {
        final v = raw[key];
        if (v is List) return v;
      }
      final inner = raw['data'];
      if (inner is Map) {
        for (final key in ['items', 'records', 'history', 'list', 'results']) {
          final v = inner[key];
          if (v is List) return v;
        }
      }
    }
    return const [];
  }
}
