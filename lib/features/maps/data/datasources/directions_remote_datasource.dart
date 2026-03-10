import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/network/google_api_client.dart';
import '../../domain/entities/route_info.dart';

/// Remote data source for Google Directions API.
class DirectionsRemoteDataSource {
  final GoogleApiClient _client;

  DirectionsRemoteDataSource(this._client);

  Future<List<RouteInfo>> getDirections({
    required LatLng origin,
    required LatLng destination,
    TravelMode mode = TravelMode.driving,
    bool alternatives = true,
  }) async {
    final response = await _client.getDirections(
      originLat: origin.latitude,
      originLng: origin.longitude,
      destLat: destination.latitude,
      destLng: destination.longitude,
      mode: mode.value,
      alternatives: alternatives,
    );

    final status = response['status'] as String?;
    if (status != 'OK') {
      if (status == 'ZERO_RESULTS') return [];
      throw Exception('Directions API error: $status');
    }

    final routes = response['routes'] as List<dynamic>? ?? [];
    return routes.map((r) => _parseRoute(r as Map<String, dynamic>)).toList();
  }

  RouteInfo _parseRoute(Map<String, dynamic> route) {
    final legs = route['legs'] as List<dynamic>;
    final leg = legs.first as Map<String, dynamic>;

    final distance = leg['distance'] as Map<String, dynamic>;
    final duration = leg['duration'] as Map<String, dynamic>;
    final durationInTraffic = leg['duration_in_traffic'] as Map<String, dynamic>?;

    final startLoc = leg['start_location'] as Map<String, dynamic>;
    final endLoc = leg['end_location'] as Map<String, dynamic>;

    final boundsData = route['bounds'] as Map<String, dynamic>;
    final ne = boundsData['northeast'] as Map<String, dynamic>;
    final sw = boundsData['southwest'] as Map<String, dynamic>;

    final overviewPolyline = route['overview_polyline'] as Map<String, dynamic>;

    final stepsData = leg['steps'] as List<dynamic>? ?? [];

    return RouteInfo(
      summary: route['summary'] as String? ?? '',
      distanceText: distance['text'] as String,
      distanceMeters: distance['value'] as int,
      durationText: duration['text'] as String,
      durationSeconds: duration['value'] as int,
      durationInTrafficText: durationInTraffic?['text'] as String?,
      durationInTrafficSeconds: durationInTraffic?['value'] as int?,
      startLocation: LatLng(
        (startLoc['lat'] as num).toDouble(),
        (startLoc['lng'] as num).toDouble(),
      ),
      endLocation: LatLng(
        (endLoc['lat'] as num).toDouble(),
        (endLoc['lng'] as num).toDouble(),
      ),
      encodedPolyline: overviewPolyline['points'] as String,
      bounds: LatLngBounds(
        northeast: LatLng(
          (ne['lat'] as num).toDouble(),
          (ne['lng'] as num).toDouble(),
        ),
        southwest: LatLng(
          (sw['lat'] as num).toDouble(),
          (sw['lng'] as num).toDouble(),
        ),
      ),
      steps: stepsData.map((s) => _parseStep(s as Map<String, dynamic>)).toList(),
    );
  }

  RouteStep _parseStep(Map<String, dynamic> step) {
    final distance = step['distance'] as Map<String, dynamic>;
    final duration = step['duration'] as Map<String, dynamic>;
    final startLoc = step['start_location'] as Map<String, dynamic>;
    final endLoc = step['end_location'] as Map<String, dynamic>;

    String instruction = step['html_instructions'] as String? ?? '';
    instruction = instruction.replaceAll(RegExp(r'<[^>]*>'), ' ').trim();

    return RouteStep(
      instruction: instruction,
      distanceText: distance['text'] as String,
      distanceMeters: distance['value'] as int,
      durationText: duration['text'] as String,
      durationSeconds: duration['value'] as int,
      startLocation: LatLng(
        (startLoc['lat'] as num).toDouble(),
        (startLoc['lng'] as num).toDouble(),
      ),
      endLocation: LatLng(
        (endLoc['lat'] as num).toDouble(),
        (endLoc['lng'] as num).toDouble(),
      ),
      maneuver: step['maneuver'] as String?,
      travelMode: step['travel_mode'] as String? ?? 'DRIVING',
    );
  }
}
