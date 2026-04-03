library;

import '../../domain/entities/maintenance_catalog.dart';
import '../../domain/repositories/maintenance_repository.dart';

class GetMaintenanceCatalogUseCase {
  GetMaintenanceCatalogUseCase(this._repo);
  final MaintenanceRepository _repo;

  Future<MaintenanceCatalog> call() => _repo.getCatalog();
}
