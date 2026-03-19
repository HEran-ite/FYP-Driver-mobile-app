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
    this.garageName,
    this.vehicleName,
  });

  final String id;
  final String driverId;
  final String garageId;
  final String scheduledAt;
  final String serviceDescription;
  final String status;
  final String createdAt;
  final String updatedAt;

  final String? garageName;
  final String? vehicleName;

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    String? garageName = json['garageName']?.toString();

    String? vehicleName;
    final vehicle = json['vehicle'];
    if (vehicle is Map<String, dynamic>) {
      final make = vehicle['make']?.toString();
      final model = vehicle['model']?.toString();
      final year = vehicle['year'];
      final yearStr = year != null ? year.toString() : null;
      final parts = <String>[];
      if ((make ?? '').isNotEmpty) parts.add(make!.trim());
      if ((model ?? '').isNotEmpty) parts.add(model!.trim());
      if ((yearStr ?? '').isNotEmpty) parts.add(yearStr!.trim());
      if (parts.isNotEmpty) {
        vehicleName = parts.join(' ');
      } else {
        final plate = vehicle['plateNumber']?.toString();
        if ((plate ?? '').isNotEmpty) vehicleName = plate!.trim();
      }
    }

    return AppointmentModel(
      id: json['id'] as String,
      driverId: json['driverId'] as String,
      garageId: json['garageId'] as String,
      scheduledAt: json['scheduledAt'] as String,
      serviceDescription: json['serviceDescription'] as String? ?? '',
      status: json['status'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      garageName: garageName,
      vehicleName: vehicleName,
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
      garageName: garageName,
      vehicleName: vehicleName,
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
