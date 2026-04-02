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
    this.services = const [],
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

  /// Service names returned by the API (`services` field).
  final List<String> services;

  final AppointmentStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Extra fields returned by the backend (enriched response).
  final String? garageName;

  /// Display name of the vehicle selected for this appointment.
  final String? vehicleName;

  /// Prefer structured [services]; fall back to [serviceDescription].
  String get serviceSummary =>
      services.isNotEmpty ? services.join(', ') : serviceDescription;

  @override
  List<Object?> get props => [
        id,
        driverId,
        garageId,
        scheduledAt,
        serviceDescription,
        services,
        status,
        createdAt,
        updatedAt,
        garageName,
        vehicleName,
      ];
}
