library;

import '../../domain/entities/appointment.dart';
import '../../domain/repositories/appointment_repository.dart';

class RescheduleAppointmentUseCase {
  RescheduleAppointmentUseCase(this._repository);
  final AppointmentRepository _repository;

  Future<Appointment> call({
    required String id,
    required DateTime scheduledAt,
  }) =>
      _repository.reschedule(id: id, scheduledAt: scheduledAt);
}
