# Architecture (simple)

The app splits code into **layers** so UI, rules, and data stay apart.

## Three layers (inside each feature)

1. **Presentation** — screens, widgets, BLoC (what the user sees and taps).
2. **Domain** — entities, repository interfaces, use cases (app rules in plain Dart).
3. **Data** — API/local calls, JSON models, repository implementations.

Folders: `lib/features/<name>/presentation|domain|data/`.

## Other choices

- **State:** BLoC per feature (`presentation/bloc/`).
- **DI:** types registered in `lib/injection/service_locator.dart`.
- **Shared UI/rules:** `lib/core/` (theme, colors, API paths, HTTP client helpers).

## Rules that help

- Put colors/spacing in `core`, not magic numbers in widgets.
- Don’t import one feature’s UI into another feature’s UI.
- After adding a repository/use case, wire it in `service_locator.dart`.

## Order to build a new screen (usual flow)

1. Domain: entity + repository interface + use case  
2. Data: model + remote/local source + repository impl  
3. Presentation: events/states/BLoC + page  
4. Register in DI and add a route if needed  
