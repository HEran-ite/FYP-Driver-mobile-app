#!/usr/bin/env bash
# Injects GOOGLE_MAPS_API_KEY from .env into iOS Info.plist and Android local.properties
# so the native Google Maps SDK gets the key at launch. Run from project root:
#   ./scripts/inject_api_key.sh
# or: bash scripts/inject_api_key.sh

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT_DIR"

if [ ! -f .env ]; then
  echo "No .env file found. Copy .env.example to .env and set GOOGLE_MAPS_API_KEY."
  exit 1
fi

# Parse GOOGLE_MAPS_API_KEY from .env (allow optional quotes and spaces)
KEY=$(grep -E '^GOOGLE_MAPS_API_KEY=' .env | sed 's/^GOOGLE_MAPS_API_KEY=//' | sed 's/^[" ]*//;s/[" ]*$//' | tr -d '"' | head -1)
if [ -z "$KEY" ]; then
  echo "GOOGLE_MAPS_API_KEY not set in .env"
  exit 1
fi

# iOS: update Info.plist
PLIST="$ROOT_DIR/ios/Runner/Info.plist"
if [ -f "$PLIST" ]; then
  /usr/libexec/PlistBuddy -c "Set :GOOGLE_MAPS_API_KEY $KEY" "$PLIST" 2>/dev/null ||
    /usr/libexec/PlistBuddy -c "Add :GOOGLE_MAPS_API_KEY string $KEY" "$PLIST"
  echo "Updated iOS Info.plist with GOOGLE_MAPS_API_KEY"
fi

# Android: add or replace in local.properties
LPROP="$ROOT_DIR/android/local.properties"
if [ -f "$LPROP" ]; then
  if grep -q '^GOOGLE_MAPS_API_KEY=' "$LPROP" 2>/dev/null; then
    if sed --version 2>/dev/null | grep -q GNU; then
      sed -i "s|^GOOGLE_MAPS_API_KEY=.*|GOOGLE_MAPS_API_KEY=$KEY|" "$LPROP"
    else
      sed -i '' "s|^GOOGLE_MAPS_API_KEY=.*|GOOGLE_MAPS_API_KEY=$KEY|" "$LPROP"
    fi
  else
    echo "GOOGLE_MAPS_API_KEY=$KEY" >> "$LPROP"
  fi
  echo "Updated android/local.properties with GOOGLE_MAPS_API_KEY"
fi

echo "Done. Run 'flutter run' or rebuild."
