library;

import '../../domain/entities/appointment.dart';
import '../../domain/repositories/appointment_repository.dart';

class BookAppointmentUseCase {
  BookAppointmentUseCase(this._repository);
  final AppointmentRepository _repository;

  Future<Appointment> call({
    required String garageId,
    required String vehicleId,
    required DateTime scheduledAt,
    required String serviceDescription,
    required List<String> garageServiceIds,
    bool isOnsite = false,
    double? serviceLatitude,
    double? serviceLongitude,
  }) =>
      _repository.book(
        garageId: garageId,
        vehicleId: vehicleId,
        scheduledAt: scheduledAt,
        serviceDescription: serviceDescription,
        garageServiceIds: garageServiceIds,
        isOnsite: isOnsite,
        serviceLatitude: serviceLatitude,
        serviceLongitude: serviceLongitude,
      );
}
