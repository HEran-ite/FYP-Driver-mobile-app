library;

import '../../domain/entities/maintenance_history.dart';
import '../../domain/entities/maintenance_upcoming.dart';
import '../../domain/repositories/maintenance_repository.dart';
import '../datasources/maintenance_remote_datasource.dart';

class MaintenanceRepositoryImpl implements MaintenanceRepository {
  MaintenanceRepositoryImpl(this._remote);
  final MaintenanceRemoteDataSource _remote;

  @override
  Future<List<MaintenanceUpcoming>> listUpcoming() async {
    final models = await _remote.listUpcoming();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<MaintenanceHistory>> listHistory() async {
    final models = await _remote.listHistory();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<MaintenanceUpcoming> createUpcoming({
    required String title,
    required DateTime scheduledAt,
    String? estimatedCost,
    required String vehicleId,
  }) async {
    final m = await _remote.createUpcoming(
      title: title,
      scheduledAt: scheduledAt,
      estimatedCost: estimatedCost,
      vehicleId: vehicleId,
    );
    return m.toEntity();
  }

  @override
  Future<void> deleteUpcoming(String id) => _remote.deleteUpcoming(id);

  @override
  Future<void> deleteHistory(String id) => _remote.deleteHistory(id);

  @override
  Future<MaintenanceUpcoming> toggleReminder(String id) async {
    final m = await _remote.toggleReminder(id);
    return m.toEntity();
  }
}

