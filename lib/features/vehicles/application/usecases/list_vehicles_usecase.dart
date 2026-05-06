library;

import '../../domain/entities/vehicle.dart';
import '../../domain/repositories/vehicle_repository.dart';

class ListVehiclesUseCase {
  ListVehiclesUseCase(this._repository);
  final VehicleRepository _repository;

  Future<List<Vehicle>> call() => _repository.list();
}
