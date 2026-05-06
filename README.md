# Driver app

Flutter app for drivers: vehicles, maintenance, garages map, AI chat, education, community, and alerts.

## What’s inside

- Login / sign up  
- Vehicles and maintenance  
- Find services (map) and appointments  
- AI assistant chat  
- Learning articles  
- Community feed  
- Notifications  
- Profile and settings  

## Tech (short)

- **UI state:** `flutter_bloc`  
- **HTTP:** `dio`  
- **DI:** `get_it`  
- **Storage:** `shared_preferences`, `flutter_secure_storage`  
- **Maps:** Google Maps (needs API keys)

Code layout: **feature folders**, each with `presentation`, `domain`, `data` (clean-style layers).

## Run the project

1. Install [Flutter](https://flutter.dev) (SDK matches `pubspec.yaml`).
2. Clone the repo and open the project folder.
3. `flutter pub get`
4. Add a `.env` file (do **not** commit it). You need at least:
   - `GOOGLE_MAPS_API_KEY`
   - `AI_API_BASE_URL` (for AI chat)
   - Optional: `AI_AUTH_BEARER_TOKEN` if your AI server uses its own JWT  
   Optional: see `.env.example` if the repo has one.
5. For native Maps builds, keys sometimes must be injected into iOS/Android config — use `./scripts/inject_api_key.sh` if your team uses that script.
6. `flutter run`

## Docs (short)

| File | What it is |
|------|------------|
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | How the code layers work |
| [docs/PROJECT_STRUCTURE.md](docs/PROJECT_STRUCTURE.md) | Where folders live |
| [docs/SETUP_COMPLETE.md](docs/SETUP_COMPLETE.md) | Setup checklist |
| [lib/core/README.md](lib/core/README.md) | Shared `core` code |
| [lib/features/README.md](lib/features/README.md) | Feature modules |

## Tests / builds

```bash
flutter test
flutter build apk    # Android
flutter build ios    # iOS (Mac + Xcode)
```

## Team

- Bethel Dereje, Soliyana Kewani — software  
- Elizabet Yonas, Heran Eshetu, Yordanos Melaku — AI  
- Advisor: Mr. Michael Sheleme  

## License

Add your license here.
