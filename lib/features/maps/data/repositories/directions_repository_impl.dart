import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../domain/entities/route_info.dart';
import '../../domain/repositories/directions_repository.dart';
import '../datasources/directions_remote_datasource.dart';

/// Implementation of DirectionsRepository using Google Directions API.
class DirectionsRepositoryImpl implements DirectionsRepository {
  final DirectionsRemoteDataSource _remoteDataSource;

  DirectionsRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<RouteInfo>> getDirections({
    required LatLng origin,
    required LatLng destination,
    TravelMode mode = TravelMode.driving,
    bool alternatives = true,
  }) async {
    try {
      return await _remoteDataSource.getDirections(
        origin: origin,
        destination: destination,
        mode: mode,
        alternatives: alternatives,
      );
    } catch (e) {
      return [];
    }
  }
}
