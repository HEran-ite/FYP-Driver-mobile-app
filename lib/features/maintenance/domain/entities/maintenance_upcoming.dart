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
  });

  final String id;
  final String title;
  final DateTime scheduledAt;
  final String? estimatedCost;
  final bool reminderEnabled;
  final String? garageName;
  final String? vehicleId;

  @override
  List<Object?> get props => [id, title, scheduledAt, estimatedCost, reminderEnabled, garageName, vehicleId];
}

