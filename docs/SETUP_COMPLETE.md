# Setup checklist

Use this as a quick **done / todo** list.

## Before you code

- [ ] Flutter SDK installed (`flutter doctor` looks OK)
- [ ] `flutter pub get`
- [ ] `.env` created locally (**never** commit it)
  - Maps key, AI base URL, and any AI auth token your backend needs

## Run

- [ ] `flutter run` on a device or emulator

## If Maps fails on device

- [ ] Keys are in `.env` **and** native iOS/Android configs if your team uses `scripts/inject_api_key.sh`

## When you add a feature

- [ ] Domain → data → UI → register in `service_locator.dart`
- [ ] Add route in `main.dart` if it’s a new screen

More detail: [ARCHITECTURE.md](ARCHITECTURE.md) and [../README.md](../README.md).
