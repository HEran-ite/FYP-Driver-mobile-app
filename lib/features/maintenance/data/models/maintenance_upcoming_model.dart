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
    this.presetCategory,
    this.displayStatus,
    this.daysUntilDue,
    this.overdueDays,
    this.completedAt,
    this.vehiclePlate,
    this.vehicleLabel,
    this.notes,
    this.estimatedCostMin,
    this.estimatedCostMax,
  });

  final String id;
  final String title;
  final DateTime scheduledAt;
  final String? estimatedCost;
  final bool reminderEnabled;
  final String? garageName;
  final String? vehicleId;
  final String? presetCategory;
  final String? displayStatus;
  final int? daysUntilDue;
  final int? overdueDays;
  final DateTime? completedAt;
  final String? vehiclePlate;
  final String? vehicleLabel;
  final String? notes;
  final num? estimatedCostMin;
  final num? estimatedCostMax;

  factory MaintenanceUpcomingModel.fromJson(Map<String, dynamic>? json) {
    final m = json ?? const <String, dynamic>{};
    DateTime parseDate(dynamic v) {
      if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
      return DateTime.now();
    }

    DateTime? parseDateNullable(dynamic v) {
      if (v == null) return null;
      if (v is String) return DateTime.tryParse(v);
      return null;
    }

    int? parseInt(dynamic v) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      return null;
    }

    num? parseNum(dynamic v) {
      if (v is num) return v;
      if (v is String) return num.tryParse(v);
      return null;
    }

    final min = parseNum(m['estimatedCostMin']);
    final max = parseNum(m['estimatedCostMax']);
    String? costHint;
    if (min != null && max != null) {
      if (min == max) {
        costHint = min.toString();
      } else {
        costHint = '$min – $max';
      }
    }

    return MaintenanceUpcomingModel(
      id: m['id']?.toString() ?? '',
      title: m['serviceName']?.toString() ??
          m['title']?.toString() ??
          m['service']?.toString() ??
          'Maintenance',
      scheduledAt: parseDate(m['scheduledDate'] ?? m['scheduledAt'] ?? m['date']),
      estimatedCost: m['estimatedCost']?.toString() ?? m['costEstimate']?.toString() ?? costHint,
      reminderEnabled: m['reminderSet'] == true || m['reminderEnabled'] == true || m['reminder'] == true,
      garageName: m['garageName']?.toString() ?? m['centerName']?.toString(),
      vehicleId: m['vehicleId']?.toString() ?? m['vehicle_id']?.toString(),
      presetCategory: m['presetCategory']?.toString(),
      displayStatus: m['displayStatus']?.toString(),
      daysUntilDue: parseInt(m['daysUntilDue']),
      overdueDays: parseInt(m['overdueDays']),
      completedAt: parseDateNullable(m['completedAt']),
      vehiclePlate: m['vehiclePlate']?.toString(),
      vehicleLabel: m['vehicleLabel']?.toString(),
      notes: m['notes']?.toString(),
      estimatedCostMin: min,
      estimatedCostMax: max,
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
        presetCategory: presetCategory,
        displayStatus: displayStatus,
        daysUntilDue: daysUntilDue,
        overdueDays: overdueDays,
        completedAt: completedAt,
        vehiclePlate: vehiclePlate,
        vehicleLabel: vehicleLabel,
        notes: notes,
        estimatedCostMin: estimatedCostMin,
        estimatedCostMax: estimatedCostMax,
      );
}
