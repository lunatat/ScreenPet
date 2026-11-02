# Changelog

## Unreleased

- Added a Basketball Pet example that follows the Golden State Valkyries via ESPN's WNBA scoreboard.
- Added a San Francisco Weather Pet example: sunny is happy, fog (Karl) is neutral, rain is sad.
- `build-app.sh` now takes an example name: `baseball` (default), `valkyries`, or `weather`.
- Renamed the app to ScreenPet; Baseball Pet is now the included example.
- Renamed the entry point to `ScreenPetMain.swift` and the bundle identifier to `app.screenpet`.

## 1.0.1 — 2026-09-18

- Prevented a refresh from leaving the pet with an empty image.
- Added an automatic neutral-image and system-symbol fallback.
- Brings the pet back onscreen after every status refresh.
- Rechecks the pet position after display changes and computer wake.
- Keeps the floating panel alive if macOS attempts to close it.

## 1.0.0 — 2026-09-18

- Added the reusable Status Pet macOS framework.
- Included Baseball Pet as the default implementation.
- Added positive, negative, and neutral visual states.
- Added an MLB team-status provider configured for San Francisco.
- Added menu-bar controls, manual refresh, show, reset-position, and quit actions.
- Added support for reopening or recovering an off-screen pet.
- Added AI-agent customization instructions and provider/theme templates.
- Added a macOS GitHub Actions build workflow.
