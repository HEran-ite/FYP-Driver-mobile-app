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
      return list
          .map((e) => ServiceCenterModel.fromJson(
              Map<String, dynamic>.from(e as Map)))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404 || e.type == DioExceptionType.connectionError) {
        return [];
      }
      rethrow;
    }
  }
}
