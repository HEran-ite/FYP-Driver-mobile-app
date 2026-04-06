library;

import 'package:equatable/equatable.dart';

class MaintenanceUpcoming extends Equatable {
  const MaintenanceUpcoming({
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
  /// Human-readable cost hint (derived from min/max when present).
  final String? estimatedCost;
  final bool reminderEnabled;
  final String? garageName;
  final String? vehicleId;
  final String? presetCategory;
  /// Backend: GOOD | SOON | URGENT | DONE (when enriched).
  final String? displayStatus;
  final int? daysUntilDue;
  final int? overdueDays;
  final DateTime? completedAt;
  final String? vehiclePlate;
  final String? vehicleLabel;
  final String? notes;
  final num? estimatedCostMin;
  final num? estimatedCostMax;

  bool get canMarkDoneFromUi {
    if (completedAt != null) return false;
    final now = DateTime.now();
    return !scheduledAt.isAfter(now);
  }

  /// Shown on the Upcoming tab (excludes completed / done rows returned with `includeCompleted`).
  bool get isActiveReminder {
    if (completedAt != null) return false;
    final ds = displayStatus?.toUpperCase();
    if (ds == 'DONE' || ds == 'CANCELLED' || ds == 'DELETED') return false;
    return true;
  }

  /// Prefer fields from [patch] when set; keep enriched list fields when API omits them.
  MaintenanceUpcoming mergeWith(MaintenanceUpcoming patch) {
    return MaintenanceUpcoming(
      id: patch.id,
      title: patch.title.isNotEmpty ? patch.title : title,
      scheduledAt: patch.scheduledAt,
      estimatedCost: patch.estimatedCost ?? estimatedCost,
      reminderEnabled: patch.reminderEnabled,
      garageName: patch.garageName ?? garageName,
      vehicleId: patch.vehicleId ?? vehicleId,
      presetCategory: patch.presetCategory ?? presetCategory,
      displayStatus: patch.displayStatus ?? displayStatus,
      daysUntilDue: patch.daysUntilDue ?? daysUntilDue,
      overdueDays: patch.overdueDays ?? overdueDays,
      completedAt: patch.completedAt ?? completedAt,
      vehiclePlate: patch.vehiclePlate ?? vehiclePlate,
      vehicleLabel: patch.vehicleLabel ?? vehicleLabel,
      notes: patch.notes ?? notes,
      estimatedCostMin: patch.estimatedCostMin ?? estimatedCostMin,
      estimatedCostMax: patch.estimatedCostMax ?? estimatedCostMax,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        scheduledAt,
        estimatedCost,
        reminderEnabled,
        garageName,
        vehicleId,
        presetCategory,
        displayStatus,
        daysUntilDue,
        overdueDays,
        completedAt,
        vehiclePlate,
        vehicleLabel,
        notes,
        estimatedCostMin,
        estimatedCostMax,
      ];
}
