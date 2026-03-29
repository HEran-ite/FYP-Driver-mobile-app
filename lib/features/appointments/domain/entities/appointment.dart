library;

import 'package:equatable/equatable.dart';

enum AppointmentStatus {
  pending,
  approved,
  rejected,
  inService,
  completed,
  cancelled,
}

class Appointment extends Equatable {
  const Appointment({
    required this.id,
    required this.driverId,
    required this.garageId,
    required this.scheduledAt,
    required this.serviceDescription,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.garageName,
    this.vehicleName,
  });

  final String id;
  final String driverId;
  final String garageId;
  final DateTime scheduledAt;
  final String serviceDescription;
  final AppointmentStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Extra fields returned by the backend (enriched response).
  final String? garageName;

  /// Display name of the vehicle selected for this appointment.
  final String? vehicleName;

  @override
  List<Object?> get props =>
      [id, driverId, garageId, scheduledAt, serviceDescription, status, createdAt, updatedAt, garageName, vehicleName];
}
