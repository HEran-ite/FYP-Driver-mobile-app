library;

import '../entities/appointment.dart';

abstract class AppointmentRepository {
  Future<List<Appointment>> list({AppointmentStatus? status});
  Future<Appointment> getById(String id);
  Future<Appointment> book({
    required String garageId,
    required String vehicleId,
    required DateTime scheduledAt,
    required String serviceDescription,
  });
  Future<Appointment> reschedule({required String id, required DateTime scheduledAt});
  Future<Appointment> cancel(String id);
}
