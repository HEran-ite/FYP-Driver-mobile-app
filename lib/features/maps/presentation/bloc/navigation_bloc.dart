library;

import 'package:bloc/bloc.dart';

import 'navigation_event.dart';
import 'navigation_state.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(const NavigationState()) {
    on<NavigationOriginSet>(_onOriginSet);
    on<NavigationOriginCleared>(_onOriginCleared);
    on<NavigationStartSelectOnMap>(_onStartSelectOnMap);
    on<NavigationCancelSelectOnMap>(_onCancelSelectOnMap);
  }

  void _onOriginSet(
    NavigationOriginSet event,
    Emitter<NavigationState> emit,
  ) {
    emit(state.copyWith(
      customOrigin: event.position,
      customOriginName: event.displayName,
      selectingOriginOnMap: false,
    ));
  }

  void _onOriginCleared(
    NavigationOriginCleared event,
    Emitter<NavigationState> emit,
  ) {
    emit(state.copyWith(clearOrigin: true));
  }

  void _onStartSelectOnMap(
    NavigationStartSelectOnMap event,
    Emitter<NavigationState> emit,
  ) {
    emit(state.copyWith(selectingOriginOnMap: true));
  }

  void _onCancelSelectOnMap(
    NavigationCancelSelectOnMap event,
    Emitter<NavigationState> emit,
  ) {
    emit(state.copyWith(selectingOriginOnMap: false));
  }
}
