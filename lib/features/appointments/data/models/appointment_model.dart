library;

import '../../domain/entities/appointment.dart';

class AppointmentModel {
  const AppointmentModel({
    required this.id,
    required this.driverId,
    required this.garageId,
    required this.scheduledAt,
    required this.serviceDescription,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String driverId;
  final String garageId;
  final String scheduledAt;
  final String serviceDescription;
  final String status;
  final String createdAt;
  final String updatedAt;

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] as String,
      driverId: json['driverId'] as String,
      garageId: json['garageId'] as String,
      scheduledAt: json['scheduledAt'] as String,
      serviceDescription: json['serviceDescription'] as String? ?? '',
      status: json['status'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }

  Appointment toEntity() {
    return Appointment(
      id: id,
      driverId: driverId,
      garageId: garageId,
      scheduledAt: DateTime.parse(scheduledAt),
      serviceDescription: serviceDescription,
      status: _parseStatus(status),
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }

  static AppointmentStatus _parseStatus(String s) {
    switch (s.toUpperCase()) {
      case 'PENDING':
        return AppointmentStatus.pending;
      case 'APPROVED':
        return AppointmentStatus.approved;
      case 'REJECTED':
        return AppointmentStatus.rejected;
      case 'IN_SERVICE':
        return AppointmentStatus.inService;
      case 'COMPLETED':
        return AppointmentStatus.completed;
      case 'CANCELLED':
        return AppointmentStatus.cancelled;
      default:
        return AppointmentStatus.pending;
    }
  }
}
