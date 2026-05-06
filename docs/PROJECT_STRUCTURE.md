# Project structure (short)

## Top level

```
lib/
├── core/           # Shared: theme, constants, network, auth helpers, etc.
├── features/       # One folder per app area (see below)
├── injection/      # get_it setup (service_locator.dart)
└── main.dart       # App starts here (themes, routes, providers)
```

## `lib/core/` (shared)

Typical pieces:

- `constants/` — sizes, API paths  
- `theme/` — colors, text styles  
- `network/` — HTTP client  
- `navigation/` — shared navigation helpers  

(Add others as needed; keep them **generic**, not tied to one feature.)

## `lib/features/` (real folders in this repo)

Examples that exist today:

| Folder | Role |
|--------|------|
| `auth` | Login, signup, profile |
| `vehicles` | Vehicle list/detail/add |
| `maintenance` | Upcoming/history maintenance |
| `appointments` | Booking flow |
| `services` | Service locator / garages |
| `ai` | AI chat |
| `education` | Articles |
| `community` | Posts and comments |
| `notifications` | In-app notifications |
| `dashboard` | Home |
| `maps` | Places/directions helpers |
| `onboarding` | First-run screens |

Each feature usually has:

```
feature/
├── presentation/   # pages, bloc, widgets
├── domain/         # entities, repository ports, use cases
└── data/           # models, API implementations
```

## Docs vs code

If a doc lists a file path that you don’t see, trust the **repo** — this file stays short on purpose.
