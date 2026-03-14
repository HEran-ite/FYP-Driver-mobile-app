library;

import '../../domain/entities/vehicle.dart';
import '../../domain/repositories/vehicle_repository.dart';

class GetVehicleUseCase {
  GetVehicleUseCase(this._repository);
  final VehicleRepository _repository;

  Future<Vehicle> call(String id) => _repository.getById(id);
}
