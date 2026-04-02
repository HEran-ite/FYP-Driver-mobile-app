library;

import '../../domain/entities/maintenance_upcoming.dart';
import '../../domain/repositories/maintenance_repository.dart';

class CreateUpcomingUseCase {
  CreateUpcomingUseCase(this._repo);
  final MaintenanceRepository _repo;

  Future<MaintenanceUpcoming> call({
    required String title,
    required DateTime scheduledAt,
    String? estimatedCost,
    required String vehicleId,
  }) =>
      _repo.createUpcoming(
        title: title,
        scheduledAt: scheduledAt,
        estimatedCost: estimatedCost,
        vehicleId: vehicleId,
      );
}

