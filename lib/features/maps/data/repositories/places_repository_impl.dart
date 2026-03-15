import '../../domain/entities/place_details.dart';
import '../../domain/entities/place_prediction.dart';
import '../../domain/repositories/places_repository.dart';
import '../datasources/places_remote_datasource.dart';

/// Implementation of PlacesRepository using Google Places API.
class PlacesRepositoryImpl implements PlacesRepository {
  final PlacesRemoteDataSource _remoteDataSource;

  PlacesRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<PlacePrediction>> autocomplete({
    required String query,
    double? lat,
    double? lng,
    String? sessionToken,
  }) async {
    return await _remoteDataSource.autocomplete(
      query: query,
      lat: lat,
      lng: lng,
      sessionToken: sessionToken,
    );
  }

  @override
  Future<PlaceDetails?> getPlaceDetails({
    required String placeId,
    String? sessionToken,
  }) async {
    try {
      return await _remoteDataSource.getPlaceDetails(
        placeId: placeId,
        sessionToken: sessionToken,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<PlaceDetails>> getNearbyPlaces({
    required double lat,
    required double lng,
    int radius = 5000,
    String? type,
    String? keyword,
  }) async {
    try {
      return await _remoteDataSource.getNearbyPlaces(
        lat: lat,
        lng: lng,
        radius: radius,
        type: type,
        keyword: keyword,
      );
    } catch (e) {
      return [];
    }
  }
}
