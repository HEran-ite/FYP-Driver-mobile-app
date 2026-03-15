library;

import '../models/service_center_model.dart';

abstract class ServiceLocatorRemoteDataSource {
  Future<List<ServiceCenterModel>> getNearby({
    double? latitude,
    double? longitude,
  });
}
