import 'package:equatable/equatable.dart';

abstract class PlacesEvent extends Equatable {
  const PlacesEvent();

  @override
  List<Object?> get props => [];
}

class PlacesSearchRequested extends PlacesEvent {
  final String query;
  final double? lat;
  final double? lng;

  const PlacesSearchRequested({
    required this.query,
    this.lat,
    this.lng,
  });

  @override
  List<Object?> get props => [query, lat, lng];
}

class PlaceSelected extends PlacesEvent {
  final String placeId;

  const PlaceSelected(this.placeId);

  @override
  List<Object?> get props => [placeId];
}

class PlacesCleared extends PlacesEvent {
  const PlacesCleared();
}

class NearbyPlacesRequested extends PlacesEvent {
  final double lat;
  final double lng;
  final String? type;
  final String? keyword;

  const NearbyPlacesRequested({
    required this.lat,
    required this.lng,
    this.type,
    this.keyword,
  });

  @override
  List<Object?> get props => [lat, lng, type, keyword];
}
