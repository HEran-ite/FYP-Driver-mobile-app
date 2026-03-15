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
    this.customOriginLatLng,
    this.customOriginName,
  });

  final LatLng? userLocation;
  final MapType mapType;
  final bool locationResolved;
  final bool locationPermissionDenied;
  final bool liveTracking;
  /// Custom start for navigation; null means use [userLocation].
  final LatLng? customOriginLatLng;
  final String? customOriginName;

  /// Origin to use for directions: custom if set, otherwise user location.
  LatLng? get effectiveOrigin => customOriginLatLng ?? userLocation;

  /// True when user has set a custom start (so we show "Use my location" option).
  bool get hasCustomOrigin => customOriginLatLng != null;

  MapState copyWith({
    LatLng? userLocation,
    bool clearUserLocation = false,
    MapType? mapType,
    bool? locationResolved,
    bool? locationPermissionDenied,
    bool? liveTracking,
    LatLng? customOriginLatLng,
    String? customOriginName,
    bool clearCustomOrigin = false,
  }) {
    return MapState(
      userLocation: clearUserLocation ? null : (userLocation ?? this.userLocation),
      mapType: mapType ?? this.mapType,
      locationResolved: locationResolved ?? this.locationResolved,
      locationPermissionDenied:
          locationPermissionDenied ?? this.locationPermissionDenied,
      liveTracking: liveTracking ?? this.liveTracking,
      customOriginLatLng: clearCustomOrigin ? null : (customOriginLatLng ?? this.customOriginLatLng),
      customOriginName: clearCustomOrigin ? null : (customOriginName ?? this.customOriginName),
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
        customOriginLatLng?.latitude,
        customOriginLatLng?.longitude,
        customOriginName,
      ];
}
