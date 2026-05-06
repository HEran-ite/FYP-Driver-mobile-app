library;

import 'package:equatable/equatable.dart';

abstract class MaintenanceEvent extends Equatable {
  const MaintenanceEvent();
  @override
  List<Object?> get props => [];
}

class MaintenanceLoadRequested extends MaintenanceEvent {
  const MaintenanceLoadRequested({this.vehicleId});

  /// When set, only reminders for this vehicle are loaded (matches backend query).
  final String? vehicleId;

  @override
  List<Object?> get props => [vehicleId];
}

class MaintenanceUpcomingCreateRequested extends MaintenanceEvent {
  const MaintenanceUpcomingCreateRequested({
    required this.vehicleId,
    required this.presetCategory,
    this.customServiceName,
    required this.scheduledAt,
    this.estimatedCostMin,
    this.estimatedCostMax,
    this.notes,
  });

  final String vehicleId;
  final String presetCategory;
  final String? customServiceName;
  final DateTime scheduledAt;
  final num? estimatedCostMin;
  final num? estimatedCostMax;
  final String? notes;

  @override
  List<Object?> get props =>
      [vehicleId, presetCategory, customServiceName, scheduledAt, estimatedCostMin, estimatedCostMax, notes];
}

class MaintenanceUpcomingDeleteRequested extends MaintenanceEvent {
  const MaintenanceUpcomingDeleteRequested(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}

class MaintenanceHistoryDeleteRequested extends MaintenanceEvent {
  const MaintenanceHistoryDeleteRequested(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}

class MaintenanceHistoryCreateRequested extends MaintenanceEvent {
  const MaintenanceHistoryCreateRequested({
    this.vehicleId,
    required this.serviceName,
    this.garageName,
    required this.serviceDate,
    this.cost,
    this.notes,
  });

  final String? vehicleId;
  final String serviceName;
  final String? garageName;
  final DateTime serviceDate;
  final num? cost;
  final String? notes;

  @override
  List<Object?> get props => [vehicleId, serviceName, garageName, serviceDate, cost, notes];
}

class MaintenanceHistoryUpdateRequested extends MaintenanceEvent {
  const MaintenanceHistoryUpdateRequested({
    required this.id,
    this.vehicleId,
    required this.serviceName,
    this.garageName,
    required this.serviceDate,
    this.cost,
    this.notes,
  });

  final String id;
  final String? vehicleId;
  final String serviceName;
  final String? garageName;
  final DateTime serviceDate;
  final num? cost;
  final String? notes;

  @override
  List<Object?> get props => [id, vehicleId, serviceName, garageName, serviceDate, cost, notes];
}

class MaintenanceToggleReminderRequested extends MaintenanceEvent {
  const MaintenanceToggleReminderRequested(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}

class MaintenanceMarkDoneRequested extends MaintenanceEvent {
  const MaintenanceMarkDoneRequested(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}
