/// Google Maps API configuration.
///
/// Uses GOOGLE_MAPS_API_KEY from --dart-define if set; otherwise uses the default below.
/// For production, consider using --dart-define or a backend proxy to avoid exposing the key.
library;

class MapsConfig {
  static const String apiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: 'REPLACED_BY_ENV',
  );

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
