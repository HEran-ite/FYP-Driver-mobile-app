import '../../../../core/network/google_api_client.dart';
import '../../domain/entities/place_details.dart';
import '../../domain/entities/place_prediction.dart';

/// Remote data source for Google Places API.
class PlacesRemoteDataSource {
  final GoogleApiClient _client;

  PlacesRemoteDataSource(this._client);

  Future<List<PlacePrediction>> autocomplete({
    required String query,
    double? lat,
    double? lng,
    String? sessionToken,
  }) async {
    final response = await _client.getPlaceAutocomplete(
      input: query,
      lat: lat,
      lng: lng,
      sessionToken: sessionToken,
    );

    final status = response['status'] as String?;
    if (status != 'OK' && status != 'ZERO_RESULTS') {
      throw Exception('Places API error: $status');
    }

    final predictions = response['predictions'] as List<dynamic>? ?? [];
    return predictions.map((p) {
      final structured = p['structured_formatting'] as Map<String, dynamic>?;
      return PlacePrediction(
        placeId: p['place_id'] as String,
        description: p['description'] as String,
        mainText: structured?['main_text'] as String? ?? '',
        secondaryText: structured?['secondary_text'] as String? ?? '',
        types: (p['types'] as List<dynamic>?)?.cast<String>() ?? [],
      );
    }).toList();
  }

  Future<PlaceDetails?> getPlaceDetails({
    required String placeId,
    String? sessionToken,
  }) async {
    final response = await _client.getPlaceDetails(
      placeId: placeId,
      sessionToken: sessionToken,
    );

    final status = response['status'] as String?;
    if (status != 'OK') {
      if (status == 'NOT_FOUND') return null;
      throw Exception('Places API error: $status');
    }

    final result = response['result'] as Map<String, dynamic>;
    final geometry = result['geometry'] as Map<String, dynamic>?;
    final location = geometry?['location'] as Map<String, dynamic>?;
    final openingHours = result['opening_hours'] as Map<String, dynamic>?;
    final photos = result['photos'] as List<dynamic>? ?? [];

    return PlaceDetails(
      placeId: result['place_id'] as String,
      name: result['name'] as String? ?? '',
      formattedAddress: result['formatted_address'] as String? ?? '',
      latitude: (location?['lat'] as num?)?.toDouble() ?? 0,
      longitude: (location?['lng'] as num?)?.toDouble() ?? 0,
      rating: (result['rating'] as num?)?.toDouble(),
      userRatingsTotal: result['user_ratings_total'] as int?,
      isOpenNow: openingHours?['open_now'] as bool?,
      types: (result['types'] as List<dynamic>?)?.cast<String>() ?? [],
      photoReferences: photos
          .map((p) => p['photo_reference'] as String?)
          .whereType<String>()
          .toList(),
    );
  }

  Future<List<PlaceDetails>> getNearbyPlaces({
    required double lat,
    required double lng,
    int radius = 5000,
    String? type,
    String? keyword,
  }) async {
    final response = await _client.getNearbyPlaces(
      lat: lat,
      lng: lng,
      radius: radius,
      type: type,
      keyword: keyword,
    );

    final status = response['status'] as String?;
    if (status != 'OK' && status != 'ZERO_RESULTS') {
      throw Exception('Places API error: $status');
    }

    final results = response['results'] as List<dynamic>? ?? [];
    return results.map((r) {
      final geometry = r['geometry'] as Map<String, dynamic>?;
      final location = geometry?['location'] as Map<String, dynamic>?;
      final openingHours = r['opening_hours'] as Map<String, dynamic>?;
      final photos = r['photos'] as List<dynamic>? ?? [];

      return PlaceDetails(
        placeId: r['place_id'] as String,
        name: r['name'] as String? ?? '',
        formattedAddress: r['vicinity'] as String? ?? '',
        latitude: (location?['lat'] as num?)?.toDouble() ?? 0,
        longitude: (location?['lng'] as num?)?.toDouble() ?? 0,
        rating: (r['rating'] as num?)?.toDouble(),
        userRatingsTotal: r['user_ratings_total'] as int?,
        isOpenNow: openingHours?['open_now'] as bool?,
        types: (r['types'] as List<dynamic>?)?.cast<String>() ?? [],
        photoReferences: photos
            .map((p) => p['photo_reference'] as String?)
            .whereType<String>()
            .toList(),
      );
    }).toList();
  }
}
