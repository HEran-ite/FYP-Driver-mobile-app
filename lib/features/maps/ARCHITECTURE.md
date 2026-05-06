# Maps (simple notes)

## What the Flutter map gives you

The map widget can show the map, markers, lines, and user location.  
**Search, routes, and geocoding** use Google Cloud APIs (Places, Directions, etc.) — those need keys and often HTTP calls.

## Keys

- Put `GOOGLE_MAPS_API_KEY` in `.env` (never commit `.env`).  
- Your team may run `scripts/inject_api_key.sh` so iOS/Android native builds see the key too.

## Code layout (this repo)

Map-related code lives under `lib/features/maps/` (repos, BLoC, etc.) and shared HTTP helpers under `lib/core/network/` (e.g. Google APIs client).

## Ideas for later (not all built yet)

- Search / autocomplete (Places)  
- Draw a route on the map (Directions)  
- Save favorite places  

## Costs / safety

Google billing can grow if APIs are open. Restrict keys to your app, enable only APIs you use, and watch quotas in Google Cloud.

For full URL formats and fields, use [Google Maps Platform docs](https://developers.google.com/maps/documentation).
