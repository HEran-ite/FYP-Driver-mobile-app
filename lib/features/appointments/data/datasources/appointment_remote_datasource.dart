library;

import '../models/appointment_model.dart';

abstract class AppointmentRemoteDataSource {
  Future<List<AppointmentModel>> list({String? status});
  Future<AppointmentModel> getById(String id);
  Future<AppointmentModel> book({
    required String garageId,
    required String vehicleId,
    required String scheduledAt,
    required String serviceDescription,
    required List<String> garageServiceIds,
    bool isOnsite = false,
    double? serviceLatitude,
    double? serviceLongitude,
  });
  Future<AppointmentModel> reschedule({
    required String id,
    required String scheduledAt,
  });
  Future<AppointmentModel> cancel(String id);
}
