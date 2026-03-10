import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../domain/entities/route_info.dart';

abstract class DirectionsEvent extends Equatable {
  const DirectionsEvent();

  @override
  List<Object?> get props => [];
}

class DirectionsRequested extends DirectionsEvent {
  final LatLng origin;
  final LatLng destination;
  final TravelMode mode;

  const DirectionsRequested({
    required this.origin,
    required this.destination,
    this.mode = TravelMode.driving,
  });

  @override
  List<Object?> get props => [origin, destination, mode];
}

class RouteAlternativeSelected extends DirectionsEvent {
  final int index;

  const RouteAlternativeSelected(this.index);

  @override
  List<Object?> get props => [index];
}

class DirectionsCleared extends DirectionsEvent {
  const DirectionsCleared();
}

class TravelModeChanged extends DirectionsEvent {
  final TravelMode mode;

  const TravelModeChanged(this.mode);

  @override
  List<Object?> get props => [mode];
}
