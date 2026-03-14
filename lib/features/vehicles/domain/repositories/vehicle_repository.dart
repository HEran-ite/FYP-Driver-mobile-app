library;

import '../entities/vehicle.dart';

abstract class VehicleRepository {
  Future<List<Vehicle>> list();
  Future<Vehicle> getById(String id);
  Future<Vehicle> add({
    required String make,
    required String model,
    required int year,
    required String plateNumber,
    String? type,
    String? color,
    String? vin,
    int? mileage,
    String? fuelType,
    DateTime? insuranceExpiresAt,
    DateTime? registrationExpiresAt,
    String? insuranceFilePath,
    String? registrationFilePath,
  });
  Future<Vehicle> update({
    required String id,
    String? make,
    String? model,
    int? year,
    String? plateNumber,
    String? type,
    String? color,
    String? vin,
    int? mileage,
    String? fuelType,
    DateTime? insuranceExpiresAt,
    DateTime? registrationExpiresAt,
    String? insuranceFilePath,
    String? registrationFilePath,
  });
  Future<void> delete(String id);
}
