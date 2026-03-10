library;

import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Events for the navigation (start/destination) feature.
abstract class NavigationEvent extends Equatable {
  const NavigationEvent();

  @override
  List<Object?> get props => [];
}

/// User set a custom start location (from search or map tap).
class NavigationOriginSet extends NavigationEvent {
  const NavigationOriginSet(this.position, this.displayName);

  final LatLng position;
  final String displayName;

  @override
  List<Object?> get props => [position.latitude, position.longitude, displayName];
}

/// User chose to use current location as start (clear custom origin).
class NavigationOriginCleared extends NavigationEvent {
  const NavigationOriginCleared();
}

/// User tapped "Pick on map" – next map tap will set start point.
class NavigationStartSelectOnMap extends NavigationEvent {
  const NavigationStartSelectOnMap();
}

/// Cancel "pick on map" mode (e.g. user closed sheet or tapped elsewhere).
class NavigationCancelSelectOnMap extends NavigationEvent {
  const NavigationCancelSelectOnMap();
}
