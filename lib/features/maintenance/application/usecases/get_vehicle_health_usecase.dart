library;

import '../../domain/entities/vehicle_health.dart';
import '../../domain/repositories/maintenance_repository.dart';

class GetVehicleHealthUseCase {
  GetVehicleHealthUseCase(this._repo);
  final MaintenanceRepository _repo;

  Future<VehicleHealth> call(String vehicleId) => _repo.getVehicleHealth(vehicleId);
}
