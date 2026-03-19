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
  }) =>
      _repository.book(
        garageId: garageId,
        vehicleId: vehicleId,
        scheduledAt: scheduledAt,
        serviceDescription: serviceDescription,
      );
}
