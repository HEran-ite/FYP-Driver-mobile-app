library;

import 'package:dio/dio.dart';
import 'package:driver/features/services/data/datasources/service_locator_remote_datasource.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../models/service_center_model.dart';

class ServiceLocatorRemoteDataSourceImpl
    implements ServiceLocatorRemoteDataSource {
  ServiceLocatorRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<List<ServiceCenterModel>> getNearby({
    double? latitude,
    double? longitude,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (latitude != null) queryParams['lat'] = latitude;
      if (longitude != null) queryParams['lng'] = longitude;
      final res = await _dio.get<List<dynamic>>(
        ApiEndpoints.nearbyServices,
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );
      final list = res.data ?? [];
      final enriched = await _enrichWithRatingSummaries(list);
      return enriched
          .map(
            (e) => ServiceCenterModel.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404 || e.type == DioExceptionType.connectionError) {
        return [];
      }
      rethrow;
    }
  }

  Future<List<dynamic>> _enrichWithRatingSummaries(List<dynamic> garages) async {
    final baseMaps = garages
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    if (baseMaps.isEmpty) return const <dynamic>[];

    final enriched = await Future.wait(
      baseMaps.map((g) async {
        final id = g['id']?.toString().trim() ?? '';
        if (id.isEmpty) return g;
        final summary = await _fetchRatingSummary(id);
        if (summary == null) return g;
        return {
          ...g,
          'rating': summary.averageRating ?? 0.0,
          'reviewsCount': summary.totalRatings,
        };
      }),
    );
    return enriched;
  }

  Future<_GarageRatingSummary?> _fetchRatingSummary(String garageId) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.garageRatingSummary(garageId),
      );
      final data = res.data ?? const <String, dynamic>{};
      final avg = data['averageRating'];
      final total = data['totalRatings'];
      return _GarageRatingSummary(
        averageRating: avg is num ? avg.toDouble() : null,
        totalRatings: total is num ? total.toInt() : 0,
      );
    } on DioException {
      return null;
    } catch (_) {
      return null;
    }
  }
}

class _GarageRatingSummary {
  const _GarageRatingSummary({
    required this.averageRating,
    required this.totalRatings,
  });

  final double? averageRating;
  final int totalRatings;
}
