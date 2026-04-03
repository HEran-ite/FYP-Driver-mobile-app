library;

import '../../domain/entities/maintenance_history.dart';
import '../../domain/repositories/maintenance_repository.dart';

class CreateHistoryUseCase {
  CreateHistoryUseCase(this._repo);
  final MaintenanceRepository _repo;

  Future<MaintenanceHistory> call({
    String? vehicleId,
    required String serviceName,
    String? garageName,
    required DateTime serviceDate,
    num? cost,
    String? notes,
  }) =>
      _repo.createHistory(
        vehicleId: vehicleId,
        serviceName: serviceName,
        garageName: garageName,
        serviceDate: serviceDate,
        cost: cost,
        notes: notes,
      );
}
