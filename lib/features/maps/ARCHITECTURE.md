# Google Maps Integration Architecture

## Overview

This document outlines the scalable architecture for full Google Maps integration.

## Feature Support Matrix

### What `google_maps_flutter` Provides (Client-side)
- Map rendering, pan, zoom, tilt, rotate
- Satellite, terrain, hybrid, normal map types
- Traffic layer visualization
- Markers, polylines, polygons, circles
- Camera animations
- My location button and blue dot
- Custom map styling (JSON)
- Gesture controls

### What Requires Google Cloud APIs (via Backend or Direct)
- **Directions API**: Route calculation, turn-by-turn, ETAs
- **Places API**: Search, autocomplete, nearby places, photos
- **Geocoding API**: Address to coordinates and reverse
- **Distance Matrix API**: Multi-point distance/time calculations
- **Roads API**: Snap to roads, speed limits

---

## Project Structure

```
lib/
├── core/
│   ├── config/
│   │   └── maps_config.dart          # API keys, quotas, feature flags
│   ├── network/
│   │   ├── api_client.dart           # Dio client
│   │   └── google_api_client.dart    # Google APIs client
│   └── services/
│       └── location_service.dart     # Geolocator wrapper
│
├── features/
│   └── maps/
│       ├── domain/
│       │   ├── entities/
│       │   │   ├── place.dart
│       │   │   ├── route.dart
│       │   │   ├── route_step.dart
│       │   │   ├── saved_location.dart
│       │   │   └── traffic_info.dart
│       │   ├── repositories/
│       │   │   ├── directions_repository.dart
│       │   │   ├── places_repository.dart
│       │   │   ├── geocoding_repository.dart
│       │   │   └── saved_locations_repository.dart
│       │   └── errors/
│       │       └── maps_failure.dart
│       │
│       ├── data/
│       │   ├── datasources/
│       │   │   ├── directions_remote_datasource.dart
│       │   │   ├── places_remote_datasource.dart
│       │   │   ├── geocoding_remote_datasource.dart
│       │   │   └── saved_locations_local_datasource.dart
│       │   ├── models/
│       │   │   ├── directions_response.dart
│       │   │   ├── place_autocomplete_response.dart
│       │   │   ├── place_details_response.dart
│       │   │   ├── nearby_places_response.dart
│       │   │   └── geocoding_response.dart
│       │   └── repositories/
│       │       ├── directions_repository_impl.dart
│       │       ├── places_repository_impl.dart
│       │       └── geocoding_repository_impl.dart
│       │
│       ├── application/
│       │   ├── get_directions_usecase.dart
│       │   ├── search_places_usecase.dart
│       │   ├── get_place_details_usecase.dart
│       │   ├── get_nearby_places_usecase.dart
│       │   ├── geocode_address_usecase.dart
│       │   ├── reverse_geocode_usecase.dart
│       │   └── save_location_usecase.dart
│       │
│       └── presentation/
│           ├── bloc/
│           │   ├── map_bloc.dart           # Map state (type, camera, markers)
│           │   ├── location_bloc.dart      # User location tracking
│           │   ├── directions_bloc.dart    # Route calculation
│           │   ├── places_bloc.dart        # Search & autocomplete
│           │   └── navigation_bloc.dart    # Turn-by-turn state
│           ├── pages/
│           │   ├── map_page.dart
│           │   ├── search_page.dart
│           │   ├── navigation_page.dart
│           │   └── place_details_page.dart
│           └── widgets/
│               ├── map_controls.dart
│               ├── search_bar.dart
│               ├── route_summary.dart
│               ├── turn_instruction.dart
│               └── place_card.dart
```

---

## API Key Management

### Option 1: Direct Client-side (Simple, Less Secure)
```dart
// lib/core/config/maps_config.dart
class MapsConfig {
  static const String apiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '',
  );
}
```

Run with: `flutter run --dart-define=GOOGLE_MAPS_API_KEY=your_key`

### Option 2: Backend Proxy (Recommended for Production)
- Store API key on your backend
- Client calls your backend → backend calls Google APIs
- Benefits: rate limiting, caching, key protection, usage analytics

---

## Implementation Priorities

### Phase 1: Core Map (Current State) ✅
- [x] Map rendering
- [x] User location
- [x] Markers for garages
- [x] Map type switching
- [x] Zoom controls
- [x] Open in Google Maps for navigation

### Phase 2: Places & Search
- [ ] Place autocomplete search bar
- [ ] Nearby places (gas stations, garages, etc.)
- [ ] Place details (photos, reviews, hours)
- [ ] Reverse geocoding (tap map → get address)

### Phase 3: Directions & Routes
- [ ] In-app route calculation
- [ ] Draw route polylines on map
- [ ] Multiple route alternatives
- [ ] Traffic-aware routing
- [ ] ETA and distance display

### Phase 4: Navigation
- [ ] Turn-by-turn instructions
- [ ] Voice guidance (TTS)
- [ ] Rerouting on deviation
- [ ] Live traffic updates

### Phase 5: Advanced
- [ ] Saved/favorite locations
- [ ] Route history
- [ ] Offline maps (limited)
- [ ] Marker clustering

---

## Required Packages

```yaml
dependencies:
  # Map rendering
  google_maps_flutter: ^2.5.0
  
  # Location
  geolocator: ^10.1.0
  permission_handler: ^11.1.0
  
  # Places autocomplete (optional - uses Places API)
  google_places_flutter: ^2.0.8
  # OR build custom with Dio
  
  # Directions (build custom with Dio)
  # No dedicated package - use HTTP client
  
  # Polyline decoding (for routes)
  flutter_polyline_points: ^2.0.0
  
  # Geocoding
  geocoding: ^2.1.1
  
  # Marker clustering
  google_maps_cluster_manager: ^3.0.0+1
  
  # URL launcher (for external navigation)
  url_launcher: ^6.2.0
  
  # Local storage (for saved locations)
  hive: ^2.2.3
  hive_flutter: ^1.1.0
```

---

## API Endpoints Reference

### Directions API
```
GET https://maps.googleapis.com/maps/api/directions/json
  ?origin=lat,lng
  &destination=lat,lng
  &mode=driving|walking|bicycling|transit
  &alternatives=true
  &departure_time=now
  &traffic_model=best_guess
  &key=API_KEY
```

### Places Autocomplete
```
GET https://maps.googleapis.com/maps/api/place/autocomplete/json
  ?input=search_query
  &location=lat,lng
  &radius=50000
  &types=establishment
  &key=API_KEY
```

### Place Details
```
GET https://maps.googleapis.com/maps/api/place/details/json
  ?place_id=PLACE_ID
  &fields=name,rating,formatted_phone_number,opening_hours,photos
  &key=API_KEY
```

### Nearby Search
```
GET https://maps.googleapis.com/maps/api/place/nearbysearch/json
  ?location=lat,lng
  &radius=5000
  &type=gas_station|car_repair
  &key=API_KEY
```

### Geocoding
```
GET https://maps.googleapis.com/maps/api/geocode/json
  ?address=1600+Amphitheatre+Parkway
  &key=API_KEY
```

### Reverse Geocoding
```
GET https://maps.googleapis.com/maps/api/geocode/json
  ?latlng=40.714224,-73.961452
  &key=API_KEY
```

---

## Caching Strategy

| Data Type | Cache Duration | Storage |
|-----------|---------------|---------|
| Place autocomplete | No cache (real-time) | - |
| Place details | 24 hours | Hive/SQLite |
| Nearby places | 1 hour | Memory |
| Directions/routes | 5 minutes | Memory |
| Saved locations | Permanent | Hive/SQLite |
| Geocoding results | 7 days | Hive |

---

## Performance Optimization

1. **Debounce search input** (300-500ms) to reduce API calls
2. **Cache geocoding results** - addresses rarely change
3. **Limit marker count** - use clustering for 50+ markers
4. **Lazy load place photos** - only when visible
5. **Use session tokens** for Places Autocomplete (reduces billing)
6. **Batch requests** where possible (Distance Matrix)
7. **Precompute common routes** on backend

---

## Cost Estimation (Monthly)

| Feature | Requests/Month | Cost |
|---------|---------------|------|
| Maps SDK | Unlimited | Free (mobile) |
| Directions | 10,000 | ~$50 |
| Places Autocomplete | 20,000 | ~$54 |
| Place Details | 5,000 | ~$85 |
| Geocoding | 5,000 | ~$25 |
| **Total** | | **~$214/month** |

Google offers $200/month free credit, so small apps may pay nothing.

---

## Security Best Practices

1. **Restrict API keys** by app bundle ID (Android) and bundle identifier (iOS)
2. **Enable only required APIs** in Google Cloud Console
3. **Set quotas** to prevent runaway costs
4. **Use backend proxy** for sensitive operations
5. **Never commit API keys** to version control
6. **Monitor usage** in Google Cloud Console

---

## Alternative: Open Source Options

If cost is a concern, consider:

| Feature | Open Source Alternative |
|---------|------------------------|
| Map rendering | `flutter_map` + OpenStreetMap |
| Directions | OSRM or GraphHopper |
| Geocoding | Nominatim |
| Places search | Overpass API / Photon |

Trade-offs: Less accurate, no traffic data, self-hosted infrastructure needed.
