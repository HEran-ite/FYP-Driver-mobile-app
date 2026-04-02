library;

import '../../domain/repositories/maintenance_repository.dart';

class DeleteHistoryUseCase {
  DeleteHistoryUseCase(this._repo);
  final MaintenanceRepository _repo;

  Future<void> call(String id) => _repo.deleteHistory(id);
}

