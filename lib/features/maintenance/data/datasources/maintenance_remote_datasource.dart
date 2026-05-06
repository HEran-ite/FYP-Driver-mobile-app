library;

import '../models/maintenance_catalog_model.dart';
import '../models/maintenance_history_model.dart';
import '../models/maintenance_upcoming_model.dart';
import '../models/vehicle_health_model.dart';

abstract class MaintenanceRemoteDataSource {
  Future<MaintenanceCatalogResponseModel> getCatalog();

  Future<VehicleHealthModel> getVehicleHealth(String vehicleId);

  Future<List<MaintenanceUpcomingModel>> listUpcoming({
    String? vehicleId,
    bool includeCompleted = false,
  });

  Future<List<MaintenanceHistoryModel>> listHistory();

  Future<MaintenanceHistoryModel> createHistory({
    String? vehicleId,
    required String serviceName,
    String? garageName,
    required DateTime serviceDate,
    num? cost,
    String? notes,
  });

  Future<MaintenanceHistoryModel> updateHistory({
    required String id,
    String? vehicleId,
    required String serviceName,
    String? garageName,
    required DateTime serviceDate,
    num? cost,
    String? notes,
  });

  Future<MaintenanceUpcomingModel> createUpcoming({
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

  Future<MaintenanceUpcomingModel> toggleReminder(String id);

  Future<MaintenanceUpcomingModel> markReminderDone(String id);
}
