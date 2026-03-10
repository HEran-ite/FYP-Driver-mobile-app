import '../entities/place_details.dart';
import '../entities/place_prediction.dart';

/// Repository for Google Places operations.
abstract class PlacesRepository {
  /// Search for places with autocomplete.
  Future<List<PlacePrediction>> autocomplete({
    required String query,
    double? lat,
    double? lng,
    String? sessionToken,
  });

  /// Get detailed information about a place.
  Future<PlaceDetails?> getPlaceDetails({
    required String placeId,
    String? sessionToken,
  });

  /// Search for nearby places of a specific type.
  Future<List<PlaceDetails>> getNearbyPlaces({
    required double lat,
    required double lng,
    int radius = 5000,
    String? type,
    String? keyword,
  });
}
