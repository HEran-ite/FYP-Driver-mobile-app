import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/place_prediction.dart';
import '../../domain/repositories/places_repository.dart';
import 'places_event.dart';
import 'places_state.dart';

class _SearchResultsReceived extends PlacesEvent {
  final List<PlacePrediction> predictions;

  const _SearchResultsReceived(this.predictions);

  @override
  List<Object?> get props => [predictions];
}

class _SearchFailed extends PlacesEvent {
  final String message;

  const _SearchFailed(this.message);

  @override
  List<Object?> get props => [message];
}

class PlacesBloc extends Bloc<PlacesEvent, PlacesState> {
  final PlacesRepository _placesRepository;
  final Uuid _uuid = const Uuid();

  String? _sessionToken;
  Timer? _debounce;

  PlacesBloc(this._placesRepository) : super(const PlacesState()) {
    on<PlacesSearchRequested>(_onSearchRequested);
    on<PlaceSelected>(_onPlaceSelected);
    on<PlacesCleared>(_onCleared);
    on<NearbyPlacesRequested>(_onNearbyRequested);
    on<_SearchResultsReceived>(_onSearchResultsReceived);
    on<_SearchFailed>(_onSearchFailed);
  }

  void _onSearchFailed(_SearchFailed event, Emitter<PlacesState> emit) {
    emit(state.copyWith(
      predictions: [],
      isSearching: false,
      error: event.message,
    ));
  }

  Future<void> _onSearchRequested(
    PlacesSearchRequested event,
    Emitter<PlacesState> emit,
  ) async {
    _debounce?.cancel();

    if (event.query.isEmpty) {
      emit(state.copyWith(predictions: [], clearError: true));
      return;
    }

    emit(state.copyWith(isSearching: true, clearError: true));

    _debounce = Timer(const Duration(milliseconds: 300), () async {
      _sessionToken ??= _uuid.v4();
      try {
        final predictions = await _placesRepository.autocomplete(
          query: event.query,
          lat: event.lat,
          lng: event.lng,
          sessionToken: _sessionToken,
        );
        if (!isClosed) {
          add(_SearchResultsReceived(predictions));
        }
      } catch (e, _) {
        if (!isClosed) {
          final message = e is Exception ? e.toString().replaceFirst('Exception: ', '') : 'Search failed';
          add(_SearchFailed(message));
        }
      }
    });
  }

  void _onSearchResultsReceived(
    _SearchResultsReceived event,
    Emitter<PlacesState> emit,
  ) {
    emit(state.copyWith(
      predictions: event.predictions,
      isSearching: false,
    ));
  }

  Future<void> _onPlaceSelected(
    PlaceSelected event,
    Emitter<PlacesState> emit,
  ) async {
    emit(state.copyWith(isLoadingDetails: true, clearError: true));

    final details = await _placesRepository.getPlaceDetails(
      placeId: event.placeId,
      sessionToken: _sessionToken,
    );

    _sessionToken = null;

    if (details != null) {
      emit(state.copyWith(
        selectedPlace: details,
        predictions: [],
        isLoadingDetails: false,
      ));
    } else {
      emit(state.copyWith(
        isLoadingDetails: false,
        error: 'Could not load place details',
      ));
    }
  }

  void _onCleared(
    PlacesCleared event,
    Emitter<PlacesState> emit,
  ) {
    _sessionToken = null;
    emit(state.copyWith(
      predictions: [],
      clearSelectedPlace: true,
      clearError: true,
    ));
  }

  Future<void> _onNearbyRequested(
    NearbyPlacesRequested event,
    Emitter<PlacesState> emit,
  ) async {
    emit(state.copyWith(isLoadingNearby: true, clearError: true));

    final places = await _placesRepository.getNearbyPlaces(
      lat: event.lat,
      lng: event.lng,
      type: event.type,
      keyword: event.keyword,
    );

    emit(state.copyWith(
      nearbyPlaces: places,
      isLoadingNearby: false,
    ));
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
