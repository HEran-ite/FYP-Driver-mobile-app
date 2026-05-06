library;

import 'package:equatable/equatable.dart';

abstract class VehiclesEvent extends Equatable {
  const VehiclesEvent();
  @override
  List<Object?> get props => [];
}

class VehiclesLoadRequested extends VehiclesEvent {
  const VehiclesLoadRequested();
}

class VehicleDetailRequested extends VehiclesEvent {
  const VehicleDetailRequested(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}

class VehicleDeleteRequested extends VehiclesEvent {
  const VehicleDeleteRequested(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}

class VehicleAddRequested extends VehiclesEvent {
  const VehicleAddRequested({
    required this.make,
    required this.model,
    required this.year,
    required this.plateNumber,
    this.type,
    this.color,
    this.vin,
    this.mileage,
    this.fuelType,
    this.insuranceExpiresAt,
    this.registrationExpiresAt,
    this.insuranceFilePath,
    this.registrationFilePath,
  });
  final String make;
  final String model;
  final int year;
  final String plateNumber;
  final String? type;
  final String? color;
  final String? vin;
  final int? mileage;
  final String? fuelType;
  final DateTime? insuranceExpiresAt;
  final DateTime? registrationExpiresAt;
  final String? insuranceFilePath;
  final String? registrationFilePath;
  @override
  List<Object?> get props => [make, model, year, plateNumber, type, color, vin, mileage, fuelType, insuranceExpiresAt, registrationExpiresAt, insuranceFilePath, registrationFilePath];
}

class VehicleUpdateRequested extends VehiclesEvent {
  const VehicleUpdateRequested({
    required this.id,
    this.make,
    this.model,
    this.year,
    this.plateNumber,
    this.type,
    this.color,
    this.vin,
    this.mileage,
    this.fuelType,
    this.insuranceExpiresAt,
    this.registrationExpiresAt,
    this.insuranceFilePath,
    this.registrationFilePath,
  });
  final String id;
  final String? make;
  final String? model;
  final int? year;
  final String? plateNumber;
  final String? type;
  final String? color;
  final String? vin;
  final int? mileage;
  final String? fuelType;
  final DateTime? insuranceExpiresAt;
  final DateTime? registrationExpiresAt;
  final String? insuranceFilePath;
  final String? registrationFilePath;
  @override
  List<Object?> get props => [id, make, model, year, plateNumber, type, color, vin, mileage, fuelType, insuranceExpiresAt, registrationExpiresAt, insuranceFilePath, registrationFilePath];
}
