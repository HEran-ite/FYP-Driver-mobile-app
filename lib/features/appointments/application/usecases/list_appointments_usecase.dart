library;

import '../../domain/entities/appointment.dart';
import '../../domain/repositories/appointment_repository.dart';

class ListAppointmentsUseCase {
  ListAppointmentsUseCase(this._repository);
  final AppointmentRepository _repository;

  Future<List<Appointment>> call({AppointmentStatus? status}) =>
      _repository.list(status: status);
}
