import 'package:equatable/equatable.dart';

import '../../domain/entities/place_details.dart';
import '../../domain/entities/place_prediction.dart';

class PlacesState extends Equatable {
  final List<PlacePrediction> predictions;
  final PlaceDetails? selectedPlace;
  final List<PlaceDetails> nearbyPlaces;
  final bool isSearching;
  final bool isLoadingDetails;
  final bool isLoadingNearby;
  final String? error;

  const PlacesState({
    this.predictions = const [],
    this.selectedPlace,
    this.nearbyPlaces = const [],
    this.isSearching = false,
    this.isLoadingDetails = false,
    this.isLoadingNearby = false,
    this.error,
  });

  PlacesState copyWith({
    List<PlacePrediction>? predictions,
    PlaceDetails? selectedPlace,
    bool clearSelectedPlace = false,
    List<PlaceDetails>? nearbyPlaces,
    bool? isSearching,
    bool? isLoadingDetails,
    bool? isLoadingNearby,
    String? error,
    bool clearError = false,
  }) {
    return PlacesState(
      predictions: predictions ?? this.predictions,
      selectedPlace: clearSelectedPlace ? null : (selectedPlace ?? this.selectedPlace),
      nearbyPlaces: nearbyPlaces ?? this.nearbyPlaces,
      isSearching: isSearching ?? this.isSearching,
      isLoadingDetails: isLoadingDetails ?? this.isLoadingDetails,
      isLoadingNearby: isLoadingNearby ?? this.isLoadingNearby,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
        predictions,
        selectedPlace,
        nearbyPlaces,
        isSearching,
        isLoadingDetails,
        isLoadingNearby,
        error,
      ];
}
