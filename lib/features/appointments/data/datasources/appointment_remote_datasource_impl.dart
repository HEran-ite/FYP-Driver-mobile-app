library;

import 'package:dio/dio.dart';
import 'package:driver/features/appointments/data/datasources/appointment_remote_datasource.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../models/appointment_model.dart';

class AppointmentRemoteDataSourceImpl implements AppointmentRemoteDataSource {
  AppointmentRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<List<AppointmentModel>> list({String? status}) async {
    final res = await _dio.get<List<dynamic>>(
      ApiEndpoints.driverAppointments,
      queryParameters: status != null ? {'status': status} : null,
    );
    final list = res.data ?? [];
    return list
        .map((e) => AppointmentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<AppointmentModel> getById(String id) async {
    final res = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.driverAppointmentById(id),
    );
    return AppointmentModel.fromJson(res.data!);
  }

  @override
  Future<AppointmentModel> book({
    required String garageId,
    required String vehicleId,
    required String scheduledAt,
    required String serviceDescription,
    bool isOnsite = false,
    double? serviceLatitude,
    double? serviceLongitude,
  }) async {
    final data = <String, dynamic>{
      'garageId': garageId,
      'vehicleId': vehicleId,
      'scheduledAt': scheduledAt,
      'serviceDescription': serviceDescription,
    };
    if (isOnsite &&
        serviceLatitude != null &&
        serviceLongitude != null) {
      data['isOnsite'] = true;
      data['latitude'] = serviceLatitude;
      data['longitude'] = serviceLongitude;
    }
    final res = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.driverAppointments,
      data: data,
    );
    return AppointmentModel.fromJson(res.data!);
  }

  @override
  Future<AppointmentModel> reschedule({
    required String id,
    required String scheduledAt,
  }) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      ApiEndpoints.driverAppointmentReschedule(id),
      data: {'scheduledAt': scheduledAt},
    );
    return AppointmentModel.fromJson(res.data!);
  }

  @override
  Future<AppointmentModel> cancel(String id) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      ApiEndpoints.driverAppointmentCancel(id),
    );
    return AppointmentModel.fromJson(res.data!);
  }
}
