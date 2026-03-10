library;

import '../../domain/entities/service_center.dart';
import '../../domain/repositories/service_locator_repository.dart';

/// Use case for fetching nearby garages from the backend by coordinates.
/// Used by map and service locator flows to keep business logic in the domain layer.
class GetNearbyGaragesUseCase {
  GetNearbyGaragesUseCase(this._repository);
  final ServiceLocatorRepository _repository;

  Future<List<ServiceCenter>> call({
    double? latitude,
    double? longitude,
  }) =>
      _repository.getNearbyGarages(
        latitude: latitude,
        longitude: longitude,
      );
}
