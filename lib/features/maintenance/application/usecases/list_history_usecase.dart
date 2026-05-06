library;

import '../../domain/entities/maintenance_history.dart';
import '../../domain/repositories/maintenance_repository.dart';

class ListHistoryUseCase {
  ListHistoryUseCase(this._repo);
  final MaintenanceRepository _repo;

  Future<List<MaintenanceHistory>> call() => _repo.listHistory();
}

