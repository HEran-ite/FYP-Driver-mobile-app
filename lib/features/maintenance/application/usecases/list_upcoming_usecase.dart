library;

import '../../domain/entities/maintenance_upcoming.dart';
import '../../domain/repositories/maintenance_repository.dart';

class ListUpcomingUseCase {
  ListUpcomingUseCase(this._repo);
  final MaintenanceRepository _repo;

  Future<List<MaintenanceUpcoming>> call({
    String? vehicleId,
    bool includeCompleted = false,
  }) =>
      _repo.listUpcoming(vehicleId: vehicleId, includeCompleted: includeCompleted);
}
