library;

import '../../domain/entities/appointment.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../datasources/appointment_remote_datasource.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  AppointmentRepositoryImpl(this._remote);
  final AppointmentRemoteDataSource _remote;

  @override
  Future<List<Appointment>> list({AppointmentStatus? status}) async {
    final statusStr = status != null ? _statusToApi(status) : null;
    final list = await _remote.list(status: statusStr);
    return list.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Appointment> getById(String id) async {
    final model = await _remote.getById(id);
    return model.toEntity();
  }

  @override
  Future<Appointment> book({
    required String garageId,
    required String vehicleId,
    required DateTime scheduledAt,
    required String serviceDescription,
    required List<String> garageServiceIds,
    bool isOnsite = false,
    double? serviceLatitude,
    double? serviceLongitude,
  }) async {
    final model = await _remote.book(
      garageId: garageId,
      vehicleId: vehicleId,
      scheduledAt: scheduledAt.toIso8601String(),
      serviceDescription: serviceDescription,
      garageServiceIds: garageServiceIds,
      isOnsite: isOnsite,
      serviceLatitude: serviceLatitude,
      serviceLongitude: serviceLongitude,
    );
    return model.toEntity();
  }

  @override
  Future<Appointment> reschedule({
    required String id,
    required DateTime scheduledAt,
  }) async {
    final model = await _remote.reschedule(
      id: id,
      scheduledAt: scheduledAt.toIso8601String(),
    );
    return model.toEntity();
  }

  @override
  Future<Appointment> cancel(String id) async {
    final model = await _remote.cancel(id);
    return model.toEntity();
  }

  String _statusToApi(AppointmentStatus s) {
    switch (s) {
      case AppointmentStatus.pending:
        return 'PENDING';
      case AppointmentStatus.approved:
        return 'APPROVED';
      case AppointmentStatus.rejected:
        return 'REJECTED';
      case AppointmentStatus.inService:
        return 'IN_SERVICE';
      case AppointmentStatus.completed:
        return 'COMPLETED';
      case AppointmentStatus.cancelled:
        return 'CANCELLED';
    }
  }
}
