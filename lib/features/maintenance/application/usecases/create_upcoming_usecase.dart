library;

import '../../domain/entities/maintenance_upcoming.dart';
import '../../domain/repositories/maintenance_repository.dart';

class CreateUpcomingUseCase {
  CreateUpcomingUseCase(this._repo);
  final MaintenanceRepository _repo;

  Future<MaintenanceUpcoming> call({
    required String vehicleId,
    required String presetCategory,
    String? customServiceName,
    required DateTime scheduledAt,
    num? estimatedCostMin,
    num? estimatedCostMax,
    String? notes,
  }) =>
      _repo.createUpcoming(
        vehicleId: vehicleId,
        presetCategory: presetCategory,
        customServiceName: customServiceName,
        scheduledAt: scheduledAt,
        estimatedCostMin: estimatedCostMin,
        estimatedCostMax: estimatedCostMax,
        notes: notes,
      );
}
