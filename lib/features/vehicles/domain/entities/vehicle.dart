library;

import 'package:equatable/equatable.dart';

enum VehicleStatus {
  active,
  pending,
}

class Vehicle extends Equatable {
  const Vehicle({
    required this.id,
    required this.driverId,
    required this.plateNumber,
    required this.make,
    required this.model,
    required this.year,
    this.type,
    this.color,
    this.vin,
    this.mileage,
    this.fuelType,
    this.imageUrl,
    this.insuranceDocumentUrl,
    this.insuranceExpiresAt,
    this.registrationDocumentUrl,
    this.registrationExpiresAt,
    this.createdAt,
    this.updatedAt,
    this.status,
  });

  final String id;
  final String driverId;
  final String plateNumber;
  final String make;
  final String model;
  final int year;
  final String? type;
  final String? color;
  final String? vin;
  final int? mileage;
  final String? fuelType;
  final String? imageUrl;
  final String? insuranceDocumentUrl;
  final DateTime? insuranceExpiresAt;
  final String? registrationDocumentUrl;
  final DateTime? registrationExpiresAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final VehicleStatus? status;

  String get displayName => '$make $model${year > 0 ? ' $year' : ''}'.trim();

  @override
  List<Object?> get props => [
        id,
        driverId,
        plateNumber,
        make,
        model,
        year,
        type,
        color,
        vin,
        mileage,
        fuelType,
        imageUrl,
        insuranceDocumentUrl,
        insuranceExpiresAt,
        registrationDocumentUrl,
        registrationExpiresAt,
        createdAt,
        updatedAt,
        status,
      ];
}
