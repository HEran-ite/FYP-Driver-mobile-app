library;

import '../../domain/repositories/maintenance_repository.dart';

class DeleteUpcomingUseCase {
  DeleteUpcomingUseCase(this._repo);
  final MaintenanceRepository _repo;

  Future<void> call(String id) => _repo.deleteUpcoming(id);
}

