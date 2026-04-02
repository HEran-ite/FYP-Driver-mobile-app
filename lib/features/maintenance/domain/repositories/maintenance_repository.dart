library;

import '../entities/maintenance_history.dart';
import '../entities/maintenance_upcoming.dart';

abstract class MaintenanceRepository {
  Future<List<MaintenanceUpcoming>> listUpcoming();
  Future<List<MaintenanceHistory>> listHistory();

  Future<MaintenanceUpcoming> createUpcoming({
    required String title,
    required DateTime scheduledAt,
    String? estimatedCost,
    required String vehicleId,
  });

  Future<void> deleteUpcoming(String id);
  Future<void> deleteHistory(String id);

  Future<MaintenanceUpcoming> toggleReminder(String id);
}

