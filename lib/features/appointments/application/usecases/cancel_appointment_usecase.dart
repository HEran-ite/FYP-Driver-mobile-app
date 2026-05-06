library;

import '../../domain/entities/appointment.dart';
import '../../domain/repositories/appointment_repository.dart';

class CancelAppointmentUseCase {
  CancelAppointmentUseCase(this._repository);
  final AppointmentRepository _repository;

  Future<Appointment> call(String id) => _repository.cancel(id);
}
