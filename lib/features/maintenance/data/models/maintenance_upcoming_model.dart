library;

import '../../domain/entities/maintenance_upcoming.dart';

class MaintenanceUpcomingModel {
  const MaintenanceUpcomingModel({
    required this.id,
    required this.title,
    required this.scheduledAt,
    this.estimatedCost,
    this.reminderEnabled = false,
    this.garageName,
    this.vehicleId,
  });

  final String id;
  final String title;
  final DateTime scheduledAt;
  final String? estimatedCost;
  final bool reminderEnabled;
  final String? garageName;
  final String? vehicleId;

  factory MaintenanceUpcomingModel.fromJson(Map<String, dynamic>? json) {
    final m = json ?? const <String, dynamic>{};
    DateTime parseDate(dynamic v) {
      if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
      return DateTime.now();
    }

    return MaintenanceUpcomingModel(
      id: m['id']?.toString() ?? '',
      // Backend (driver-maintenance-yordi): serviceName, scheduledDate, reminderSet
      title: m['serviceName']?.toString() ??
          m['title']?.toString() ??
          m['service']?.toString() ??
          'Maintenance',
      scheduledAt: parseDate(m['scheduledDate'] ?? m['scheduledAt'] ?? m['date']),
      estimatedCost: m['estimatedCost']?.toString() ?? m['costEstimate']?.toString(),
      reminderEnabled: m['reminderSet'] == true || m['reminderEnabled'] == true || m['reminder'] == true,
      garageName: m['garageName']?.toString() ?? m['centerName']?.toString(),
      vehicleId: m['vehicleId']?.toString() ?? m['vehicle_id']?.toString(),
    );
  }

  MaintenanceUpcoming toEntity() => MaintenanceUpcoming(
        id: id,
        title: title,
        scheduledAt: scheduledAt,
        estimatedCost: estimatedCost,
        reminderEnabled: reminderEnabled,
        garageName: garageName,
        vehicleId: vehicleId,
      );
}

