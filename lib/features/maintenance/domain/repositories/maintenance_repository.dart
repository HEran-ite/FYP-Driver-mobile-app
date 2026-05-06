library;

import '../entities/maintenance_catalog.dart';
import '../entities/maintenance_history.dart';
import '../entities/maintenance_upcoming.dart';
import '../entities/vehicle_health.dart';

abstract class MaintenanceRepository {
  Future<MaintenanceCatalog> getCatalog();

  Future<VehicleHealth> getVehicleHealth(String vehicleId);

  Future<List<MaintenanceUpcoming>> listUpcoming({
    String? vehicleId,
    bool includeCompleted = false,
  });

  Future<List<MaintenanceHistory>> listHistory();

  Future<MaintenanceHistory> createHistory({
    String? vehicleId,
    required String serviceName,
    String? garageName,
    required DateTime serviceDate,
    num? cost,
    String? notes,
  });

  Future<MaintenanceHistory> updateHistory({
    required String id,
    String? vehicleId,
    required String serviceName,
    String? garageName,
    required DateTime serviceDate,
    num? cost,
    String? notes,
  });

  Future<MaintenanceUpcoming> createUpcoming({
    required String vehicleId,
    required String presetCategory,
    String? customServiceName,
    required DateTime scheduledAt,
    num? estimatedCostMin,
    num? estimatedCostMax,
    String? notes,
  });

  Future<void> deleteUpcoming(String id);
  Future<void> deleteHistory(String id);


  Future<MaintenanceUpcoming> toggleReminder(String id);

  Future<MaintenanceUpcoming> markReminderDone(String id);
}
