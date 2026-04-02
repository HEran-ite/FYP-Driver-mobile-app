library;

import '../models/maintenance_history_model.dart';
import '../models/maintenance_upcoming_model.dart';

abstract class MaintenanceRemoteDataSource {
  Future<List<MaintenanceUpcomingModel>> listUpcoming();
  Future<List<MaintenanceHistoryModel>> listHistory();

  Future<MaintenanceUpcomingModel> createUpcoming({
    required String title,
    required DateTime scheduledAt,
    String? estimatedCost,
    required String vehicleId,
  });

  Future<void> deleteUpcoming(String id);
  Future<void> deleteHistory(String id);

  Future<MaintenanceUpcomingModel> toggleReminder(String id);
}

