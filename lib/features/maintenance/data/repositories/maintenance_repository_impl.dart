library;

import '../../domain/entities/maintenance_catalog.dart';
import '../../domain/entities/maintenance_history.dart';
import '../../domain/entities/maintenance_upcoming.dart';
import '../../domain/entities/vehicle_health.dart';
import '../../domain/repositories/maintenance_repository.dart';
import '../datasources/maintenance_remote_datasource.dart';
import '../models/maintenance_catalog_model.dart';

class MaintenanceRepositoryImpl implements MaintenanceRepository {
  MaintenanceRepositoryImpl(this._remote);
  final MaintenanceRemoteDataSource _remote;

  @override
  Future<MaintenanceCatalog> getCatalog() async {
    final m = await _remote.getCatalog();
    return _catalogFromModel(m);
  }

  @override
  Future<VehicleHealth> getVehicleHealth(String vehicleId) async {
    final m = await _remote.getVehicleHealth(vehicleId);
    return m.toEntity();
  }

  @override
  Future<List<MaintenanceUpcoming>> listUpcoming({
    String? vehicleId,
    bool includeCompleted = false,
  }) async {
    final models = await _remote.listUpcoming(
      vehicleId: vehicleId,
      includeCompleted: includeCompleted,
    );
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<MaintenanceHistory>> listHistory() async {
    final models = await _remote.listHistory();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<MaintenanceHistory> createHistory({
    String? vehicleId,
    required String serviceName,
    String? garageName,
    required DateTime serviceDate,
    num? cost,
    String? notes,
  }) async {
    final m = await _remote.createHistory(
      vehicleId: vehicleId,
      serviceName: serviceName,
      garageName: garageName,
      serviceDate: serviceDate,
      cost: cost,
      notes: notes,
    );
    return m.toEntity();
  }

  @override
  Future<MaintenanceHistory> updateHistory({
    required String id,
    String? vehicleId,
    required String serviceName,
    String? garageName,
    required DateTime serviceDate,
    num? cost,
    String? notes,
  }) async {
    final m = await _remote.updateHistory(
      id: id,
      vehicleId: vehicleId,
      serviceName: serviceName,
      garageName: garageName,
      serviceDate: serviceDate,
      cost: cost,
      notes: notes,
    );
    return m.toEntity();
  }

  @override
  Future<MaintenanceUpcoming> createUpcoming({
    required String vehicleId,
    required String presetCategory,
    String? customServiceName,
    required DateTime scheduledAt,
    num? estimatedCostMin,
    num? estimatedCostMax,
    String? notes,
  }) async {
    final m = await _remote.createUpcoming(
      vehicleId: vehicleId,
      presetCategory: presetCategory,
      customServiceName: customServiceName,
      scheduledAt: scheduledAt,
      estimatedCostMin: estimatedCostMin,
      estimatedCostMax: estimatedCostMax,
      notes: notes,
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

  @override
  Future<MaintenanceUpcoming> markReminderDone(String id) async {
    final m = await _remote.markReminderDone(id);
    return m.toEntity();
  }

  static MaintenanceCatalog _catalogFromModel(MaintenanceCatalogResponseModel m) {
    return MaintenanceCatalog(
      presets: m.presets
          .map(
            (p) => MaintenanceCatalogItem(
              id: p.id,
              label: p.label,
              description: p.description,
              healthComponent: p.healthComponent,
            ),
          )
          .toList(),
      rules: m.rules == null
          ? null
          : MaintenanceCatalogRules(
              soonDays: m.rules!.soonDays,
              healthReductionPercent: m.rules!.healthReductionPercent,
              displayStatusHelp: m.rules!.displayStatusHelp,
            ),
    );
  }
}

