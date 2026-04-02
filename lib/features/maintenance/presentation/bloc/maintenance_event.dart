library;

import 'package:equatable/equatable.dart';

abstract class MaintenanceEvent extends Equatable {
  const MaintenanceEvent();
  @override
  List<Object?> get props => [];
}

class MaintenanceLoadRequested extends MaintenanceEvent {
  const MaintenanceLoadRequested();
}

class MaintenanceUpcomingCreateRequested extends MaintenanceEvent {
  const MaintenanceUpcomingCreateRequested({
    required this.title,
    required this.scheduledAt,
    this.estimatedCost,
    required this.vehicleId,
  });

  final String title;
  final DateTime scheduledAt;
  final String? estimatedCost;
  final String vehicleId;

  @override
  List<Object?> get props => [title, scheduledAt, estimatedCost, vehicleId];
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

class MaintenanceToggleReminderRequested extends MaintenanceEvent {
  const MaintenanceToggleReminderRequested(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}

