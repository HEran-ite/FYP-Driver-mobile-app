# Features folder

Each subfolder is one **area** of the app. Inside you usually find:

- `presentation/` — pages, BLoC, widgets  
- `domain/` — entities, use cases, repository **interfaces**  
- `data/` — API models, repository **implementations**  

## Current modules (examples)

- `auth` — sign in, sign up, profile  
- `vehicles` — cars list / detail / add  
- `maintenance` — reminders and history  
- `appointments` — booking  
- `services` — find garages / services  
- `ai` — assistant chat  
- `education` — articles  
- `community` — feed  
- `notifications` — alerts  
- `dashboard` — home  
- `maps` — map-related helpers  
- `onboarding` — first launch  

Keep features from depending on each other’s UI. Share behavior through `core` or clear APIs.
