library;

import '../../domain/entities/vehicle.dart';
import '../../domain/repositories/vehicle_repository.dart';

class AddVehicleUseCase {
  AddVehicleUseCase(this._repository);
  final VehicleRepository _repository;

  Future<Vehicle> call({
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
  }) =>
      _repository.add(
        make: make,
        model: model,
        year: year,
        plateNumber: plateNumber,
        type: type,
        color: color,
        vin: vin,
        mileage: mileage,
        fuelType: fuelType,
        insuranceExpiresAt: insuranceExpiresAt,
        registrationExpiresAt: registrationExpiresAt,
        insuranceFilePath: insuranceFilePath,
        registrationFilePath: registrationFilePath,
      );
}
