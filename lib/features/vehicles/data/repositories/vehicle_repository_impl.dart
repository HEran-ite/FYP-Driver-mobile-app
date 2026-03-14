library;

import '../../domain/entities/vehicle.dart';
import '../../domain/repositories/vehicle_repository.dart';
import '../datasources/vehicle_remote_datasource.dart';

class VehicleRepositoryImpl implements VehicleRepository {
  VehicleRepositoryImpl(this._remote);
  final VehicleRemoteDataSource _remote;

  @override
  Future<List<Vehicle>> list() async {
    final list = await _remote.list();
    return list.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Vehicle> getById(String id) async {
    final vehicleModel = await _remote.getById(id);
    return vehicleModel.toEntity();
  }

  @override
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
  }) async {
    final body = <String, dynamic>{
      'make': make,
      'model': model,
      'year': year,
      'plateNumber': plateNumber,
    };
    if (type != null && type.isNotEmpty) body['type'] = type;
    if (color != null && color.isNotEmpty) body['color'] = color;
    if (vin != null && vin.isNotEmpty) body['vin'] = vin;
    if (mileage != null) body['mileage'] = mileage;
    if (fuelType != null && fuelType.isNotEmpty) body['fuelType'] = fuelType;
    if (insuranceExpiresAt != null) body['insuranceExpiresAt'] = insuranceExpiresAt.toIso8601String();
    if (registrationExpiresAt != null) body['registrationExpiresAt'] = registrationExpiresAt.toIso8601String();
    final vehicleModel = await _remote.add(
      body,
      insuranceFilePath: insuranceFilePath,
      registrationFilePath: registrationFilePath,
    );
    return vehicleModel.toEntity();
  }

  @override
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
  }) async {
    final body = <String, dynamic>{};
    if (make != null) body['make'] = make;
    if (model != null) body['model'] = model;
    if (year != null) body['year'] = year;
    if (plateNumber != null) body['plateNumber'] = plateNumber;
    if (type != null) body['type'] = type;
    if (color != null) body['color'] = color;
    if (vin != null) body['vin'] = vin;
    if (mileage != null) body['mileage'] = mileage;
    if (fuelType != null) body['fuelType'] = fuelType;
    if (insuranceExpiresAt != null) body['insuranceExpiresAt'] = insuranceExpiresAt.toIso8601String();
    if (registrationExpiresAt != null) body['registrationExpiresAt'] = registrationExpiresAt.toIso8601String();
    final vehicleModel = await _remote.update(
      id,
      body,
      insuranceFilePath: insuranceFilePath,
      registrationFilePath: registrationFilePath,
    );
    return vehicleModel.toEntity();
  }

  @override
  Future<void> delete(String id) async {
    await _remote.delete(id);
  }
}
