# Core folder

Shared pieces **all features** can use.

## What goes here

- **constants** — spacing, radius, API URLs  
- **theme** — colors and text styles  
- **network** — HTTP client setup  
- **utils** — small helpers  

## What does *not* go here

- Screens that belong to one feature only  
- Feature-specific BLoCs  

## Rule

Avoid hardcoded colors/sizes in widgets — use `core` theme and constants when you can.
