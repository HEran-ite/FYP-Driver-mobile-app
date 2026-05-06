library;

import '../../domain/entities/maintenance_upcoming.dart';
import '../../domain/repositories/maintenance_repository.dart';

class MarkReminderDoneUseCase {
  MarkReminderDoneUseCase(this._repo);
  final MaintenanceRepository _repo;

  Future<MaintenanceUpcoming> call(String id) => _repo.markReminderDone(id);
}
