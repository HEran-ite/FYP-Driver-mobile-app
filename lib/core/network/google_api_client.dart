import 'package:dio/dio.dart';

import '../config/maps_config.dart';

/// HTTP client for Google Maps Platform APIs.
class GoogleApiClient {
  final Dio _dio;

  GoogleApiClient({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ));

  String get _apiKey => MapsConfig.apiKey;

  Future<Map<String, dynamic>> getDirections({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    String mode = 'driving',
    bool alternatives = true,
    bool departureTimeNow = true,
  }) async {
    final response = await _dio.get(
      MapsConfig.directionsBaseUrl,
      queryParameters: {
        'origin': '$originLat,$originLng',
        'destination': '$destLat,$destLng',
        'mode': mode,
        'alternatives': alternatives,
        if (departureTimeNow && mode == 'driving') 'departure_time': 'now',
        'key': _apiKey,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getPlaceAutocomplete({
    required String input,
    double? lat,
    double? lng,
    int radius = 50000,
    String? sessionToken,
  }) async {
    final response = await _dio.get(
      MapsConfig.placesAutocompleteUrl,
      queryParameters: {
        'input': input,
        if (lat != null && lng != null) 'location': '$lat,$lng',
        if (lat != null && lng != null) 'radius': radius,
        if (sessionToken != null) 'sessiontoken': sessionToken,
        'key': _apiKey,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getPlaceDetails({
    required String placeId,
    String fields =
        'place_id,name,formatted_address,geometry,rating,user_ratings_total,opening_hours,photos,types',
    String? sessionToken,
  }) async {
    final response = await _dio.get(
      MapsConfig.placesDetailsUrl,
      queryParameters: {
        'place_id': placeId,
        'fields': fields,
        if (sessionToken != null) 'sessiontoken': sessionToken,
        'key': _apiKey,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getNearbyPlaces({
    required double lat,
    required double lng,
    int radius = 5000,
    String? type,
    String? keyword,
  }) async {
    final response = await _dio.get(
      MapsConfig.placesNearbyUrl,
      queryParameters: {
        'location': '$lat,$lng',
        'radius': radius,
        if (type != null) 'type': type,
        if (keyword != null) 'keyword': keyword,
        'key': _apiKey,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> reverseGeocode({
    required double lat,
    required double lng,
  }) async {
    final response = await _dio.get(
      MapsConfig.geocodingUrl,
      queryParameters: {
        'latlng': '$lat,$lng',
        'key': _apiKey,
      },
    );
    return response.data as Map<String, dynamic>;
  }
}
