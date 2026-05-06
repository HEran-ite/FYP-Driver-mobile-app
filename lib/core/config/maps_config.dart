/// Google Maps API configuration.
///
/// Reads GOOGLE_MAPS_API_KEY from .env at runtime (no key in source).
/// Run ./scripts/inject_api_key.sh so iOS/Android native Maps SDK get the key from .env.
library;

import 'package:flutter_dotenv/flutter_dotenv.dart';

class MapsConfig {
  /// From .env (loaded in main); empty if not set.
  static String get apiKey => dotenv.env['GOOGLE_MAPS_API_KEY']?.trim() ?? '';

  static const String directionsBaseUrl =
      'https://maps.googleapis.com/maps/api/directions/json';
  static const String placesAutocompleteUrl =
      'https://maps.googleapis.com/maps/api/place/autocomplete/json';
  static const String placesDetailsUrl =
      'https://maps.googleapis.com/maps/api/place/details/json';
  static const String placesNearbyUrl =
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json';
  static const String geocodingUrl =
      'https://maps.googleapis.com/maps/api/geocode/json';

  MapsConfig._();
}
