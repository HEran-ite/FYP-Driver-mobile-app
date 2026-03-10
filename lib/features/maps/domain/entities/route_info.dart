import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Information about a calculated route.
class RouteInfo {
  final String summary;
  final String distanceText;
  final int distanceMeters;
  final String durationText;
  final int durationSeconds;
  final String? durationInTrafficText;
  final int? durationInTrafficSeconds;
  final LatLng startLocation;
  final LatLng endLocation;
  final String encodedPolyline;
  final List<RouteStep> steps;
  final LatLngBounds bounds;

  const RouteInfo({
    required this.summary,
    required this.distanceText,
    required this.distanceMeters,
    required this.durationText,
    required this.durationSeconds,
    this.durationInTrafficText,
    this.durationInTrafficSeconds,
    required this.startLocation,
    required this.endLocation,
    required this.encodedPolyline,
    required this.steps,
    required this.bounds,
  });
}

/// A single step in navigation directions.
class RouteStep {
  final String instruction;
  final String distanceText;
  final int distanceMeters;
  final String durationText;
  final int durationSeconds;
  final LatLng startLocation;
  final LatLng endLocation;
  final String? maneuver;
  final String travelMode;

  const RouteStep({
    required this.instruction,
    required this.distanceText,
    required this.distanceMeters,
    required this.durationText,
    required this.durationSeconds,
    required this.startLocation,
    required this.endLocation,
    this.maneuver,
    required this.travelMode,
  });
}

/// Travel mode for directions.
enum TravelMode {
  driving,
  walking,
  bicycling,
  transit;

  String get value => name;
}
