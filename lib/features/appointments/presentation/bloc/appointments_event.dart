library;

import 'package:equatable/equatable.dart';

import '../../domain/entities/appointment.dart';

abstract class AppointmentsEvent extends Equatable {
  const AppointmentsEvent();
  @override
  List<Object?> get props => [];
}

class AppointmentsLoadRequested extends AppointmentsEvent {
  const AppointmentsLoadRequested({this.status});
  final AppointmentStatus? status;
  @override
  List<Object?> get props => [status];
}

class AppointmentBookRequested extends AppointmentsEvent {
  const AppointmentBookRequested({
    required this.garageId,
    required this.vehicleId,
    required this.scheduledAt,
    required this.serviceDescription,
    this.isOnsite = false,
    this.serviceLatitude,
    this.serviceLongitude,
  });
  final String garageId;
  final String vehicleId;
  final DateTime scheduledAt;
  final String serviceDescription;

  /// When true, [serviceLatitude] / [serviceLongitude] are sent as the service location (driver).
  final bool isOnsite;
  final double? serviceLatitude;
  final double? serviceLongitude;

  @override
  List<Object?> get props => [
        garageId,
        vehicleId,
        scheduledAt,
        serviceDescription,
        isOnsite,
        serviceLatitude,
        serviceLongitude,
      ];
}

class AppointmentRescheduleRequested extends AppointmentsEvent {
  const AppointmentRescheduleRequested({
    required this.id,
    required this.scheduledAt,
  });
  final String id;
  final DateTime scheduledAt;
  @override
  List<Object?> get props => [id, scheduledAt];
}

class AppointmentCancelRequested extends AppointmentsEvent {
  const AppointmentCancelRequested(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}
