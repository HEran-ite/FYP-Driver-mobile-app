library;

import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapState extends Equatable {
  const MapState({
    this.userLocation,
    this.mapType = MapType.normal,
    this.locationResolved = false,
    this.locationPermissionDenied = false,
    this.liveTracking = false,
  });

  final LatLng? userLocation;
  final MapType mapType;
  final bool locationResolved;
  final bool locationPermissionDenied;
  final bool liveTracking;

  MapState copyWith({
    LatLng? userLocation,
    bool clearUserLocation = false,
    MapType? mapType,
    bool? locationResolved,
    bool? locationPermissionDenied,
    bool? liveTracking,
  }) {
    return MapState(
      userLocation: clearUserLocation ? null : (userLocation ?? this.userLocation),
      mapType: mapType ?? this.mapType,
      locationResolved: locationResolved ?? this.locationResolved,
      locationPermissionDenied:
          locationPermissionDenied ?? this.locationPermissionDenied,
      liveTracking: liveTracking ?? this.liveTracking,
    );
  }

  @override
  List<Object?> get props => [
        userLocation?.latitude,
        userLocation?.longitude,
        mapType,
        locationResolved,
        locationPermissionDenied,
        liveTracking,
      ];
}
