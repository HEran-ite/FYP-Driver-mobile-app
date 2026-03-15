import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../entities/route_info.dart';

/// Repository for Google Directions operations.
abstract class DirectionsRepository {
  /// Calculate route(s) between two points.
  Future<List<RouteInfo>> getDirections({
    required LatLng origin,
    required LatLng destination,
    TravelMode mode = TravelMode.driving,
    bool alternatives = true,
  });
}
