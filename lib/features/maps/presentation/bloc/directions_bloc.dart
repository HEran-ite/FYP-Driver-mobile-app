import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/route_info.dart';
import '../../domain/repositories/directions_repository.dart';
import 'directions_event.dart';
import 'directions_state.dart';

class DirectionsBloc extends Bloc<DirectionsEvent, DirectionsState> {
  final DirectionsRepository _directionsRepository;

  DirectionsBloc(this._directionsRepository) : super(const DirectionsState()) {
    on<DirectionsRequested>(_onDirectionsRequested);
    on<RouteAlternativeSelected>(_onRouteSelected);
    on<DirectionsCleared>(_onCleared);
    on<TravelModeChanged>(_onTravelModeChanged);
  }

  Future<void> _onDirectionsRequested(
    DirectionsRequested event,
    Emitter<DirectionsState> emit,
  ) async {
    emit(state.copyWith(
      origin: event.origin,
      destination: event.destination,
      isLoading: true,
      clearError: true,
      routes: [],
      selectedRouteIndex: 0,
    ));

    final routes = await _directionsRepository.getDirections(
      origin: event.origin,
      destination: event.destination,
      mode: event.mode,
      alternatives: true,
    );

    if (routes.isEmpty) {
      emit(state.copyWith(
        isLoading: false,
        error: 'No route found',
      ));
    } else {
      emit(state.copyWith(
        routes: routes,
        isLoading: false,
      ));
    }
  }

  void _onRouteSelected(
    RouteAlternativeSelected event,
    Emitter<DirectionsState> emit,
  ) {
    if (event.index >= 0 && event.index < state.routes.length) {
      emit(state.copyWith(selectedRouteIndex: event.index));
    }
  }

  void _onCleared(
    DirectionsCleared event,
    Emitter<DirectionsState> emit,
  ) {
    emit(const DirectionsState());
  }

  Future<void> _onTravelModeChanged(
    TravelModeChanged event,
    Emitter<DirectionsState> emit,
  ) async {
    if (state.origin != null && state.destination != null) {
      emit(state.copyWith(travelMode: event.mode));
      add(DirectionsRequested(
        origin: state.origin!,
        destination: state.destination!,
        mode: event.mode,
      ));
    } else {
      emit(state.copyWith(travelMode: event.mode));
    }
  }
}
