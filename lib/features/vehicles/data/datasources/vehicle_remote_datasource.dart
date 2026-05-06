library;

import '../models/vehicle_model.dart';

abstract class VehicleRemoteDataSource {
  Future<List<VehicleModel>> list();
  Future<VehicleModel> getById(String id);
  Future<VehicleModel> add(
    Map<String, dynamic> body, {
    String? insuranceFilePath,
    String? registrationFilePath,
  });
  Future<VehicleModel> update(
    String id,
    Map<String, dynamic> body, {
    String? insuranceFilePath,
    String? registrationFilePath,
  });
  Future<void> delete(String id);
}
