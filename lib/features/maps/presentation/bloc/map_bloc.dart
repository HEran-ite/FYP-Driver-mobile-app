library;

import 'package:bloc/bloc.dart';

import 'map_event.dart';
import 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  MapBloc() : super(const MapState()) {
    on<MapUserLocationUpdated>(_onUserLocationUpdated);
    on<MapUserLocationUnavailable>(_onUserLocationUnavailable);
    on<MapTypeChanged>(_onMapTypeChanged);
    on<MapLiveTrackingToggled>(_onLiveTrackingToggled);
    on<MapCustomOriginSet>(_onCustomOriginSet);
    on<MapCustomOriginCleared>(_onCustomOriginCleared);
  }

  void _onUserLocationUpdated(
    MapUserLocationUpdated event,
    Emitter<MapState> emit,
  ) {
    emit(state.copyWith(
      userLocation: event.position,
      locationResolved: true,
      locationPermissionDenied: false,
    ));
  }

  void _onUserLocationUnavailable(
    MapUserLocationUnavailable event,
    Emitter<MapState> emit,
  ) {
    emit(state.copyWith(
      locationResolved: true,
      locationPermissionDenied: event.permissionDenied,
    ));
  }

  void _onMapTypeChanged(MapTypeChanged event, Emitter<MapState> emit) {
    emit(state.copyWith(mapType: event.mapType));
  }

  void _onLiveTrackingToggled(MapLiveTrackingToggled event, Emitter<MapState> emit) {
    emit(state.copyWith(liveTracking: event.enabled));
  }

  void _onCustomOriginSet(MapCustomOriginSet event, Emitter<MapState> emit) {
    emit(state.copyWith(
      customOriginLatLng: event.position,
      customOriginName: event.displayName,
    ));
  }

  void _onCustomOriginCleared(MapCustomOriginCleared event, Emitter<MapState> emit) {
    emit(state.copyWith(clearCustomOrigin: true));
  }
}
