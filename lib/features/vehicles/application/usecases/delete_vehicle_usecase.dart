library;

import '../../domain/repositories/vehicle_repository.dart';

class DeleteVehicleUseCase {
  DeleteVehicleUseCase(this._repository);
  final VehicleRepository _repository;

  Future<void> call(String id) => _repository.delete(id);
}
