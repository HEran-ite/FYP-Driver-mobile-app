library;

import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object?> get props => [];
}

/// Fired when the user's location has been resolved (e.g. from Geolocator).
class MapUserLocationUpdated extends MapEvent {
  const MapUserLocationUpdated(this.position);

  final LatLng position;

  @override
  List<Object?> get props => [position.latitude, position.longitude];
}

/// User or app requested to refresh location (e.g. permission denied or unavailable).
class MapUserLocationUnavailable extends MapEvent {
  const MapUserLocationUnavailable({this.permissionDenied = false});

  final bool permissionDenied;

  @override
  List<Object?> get props => [permissionDenied];
}

/// Map type changed (normal, satellite, hybrid, terrain).
class MapTypeChanged extends MapEvent {
  const MapTypeChanged(this.mapType);

  final MapType mapType;

  @override
  List<Object?> get props => [mapType];
}

/// Toggle live tracking (camera follows user).
class MapLiveTrackingToggled extends MapEvent {
  const MapLiveTrackingToggled({required this.enabled});

  final bool enabled;

  @override
  List<Object?> get props => [enabled];
}

/// Set a custom start location for navigation (overrides user location as origin).
class MapCustomOriginSet extends MapEvent {
  const MapCustomOriginSet({required this.position, required this.displayName});

  final LatLng position;
  final String displayName;

  @override
  List<Object?> get props => [position.latitude, position.longitude, displayName];
}

/// Clear custom start; navigation will use user's current location again.
class MapCustomOriginCleared extends MapEvent {
  const MapCustomOriginCleared();
}
