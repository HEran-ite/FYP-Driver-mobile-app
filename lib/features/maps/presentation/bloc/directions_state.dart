import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../domain/entities/route_info.dart';

class DirectionsState extends Equatable {
  final LatLng? origin;
  final LatLng? destination;
  final List<RouteInfo> routes;
  final int selectedRouteIndex;
  final TravelMode travelMode;
  final bool isLoading;
  final String? error;

  const DirectionsState({
    this.origin,
    this.destination,
    this.routes = const [],
    this.selectedRouteIndex = 0,
    this.travelMode = TravelMode.driving,
    this.isLoading = false,
    this.error,
  });

  RouteInfo? get selectedRoute =>
      routes.isNotEmpty && selectedRouteIndex < routes.length
          ? routes[selectedRouteIndex]
          : null;

  bool get hasRoute => routes.isNotEmpty;

  DirectionsState copyWith({
    LatLng? origin,
    bool clearOrigin = false,
    LatLng? destination,
    bool clearDestination = false,
    List<RouteInfo>? routes,
    int? selectedRouteIndex,
    TravelMode? travelMode,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return DirectionsState(
      origin: clearOrigin ? null : (origin ?? this.origin),
      destination: clearDestination ? null : (destination ?? this.destination),
      routes: routes ?? this.routes,
      selectedRouteIndex: selectedRouteIndex ?? this.selectedRouteIndex,
      travelMode: travelMode ?? this.travelMode,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
        origin,
        destination,
        routes,
        selectedRouteIndex,
        travelMode,
        isLoading,
        error,
      ];
}
