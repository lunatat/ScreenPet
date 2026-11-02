#!/bin/bash
set -euo pipefail

# Usage: ./build-app.sh [baseball|valkyries|weather] [--no-open]
EXAMPLE="baseball"
OPEN_APP=true
for arg in "$@"; do
    case "$arg" in
        --no-open) OPEN_APP=false ;;
        baseball|valkyries|weather) EXAMPLE="$arg" ;;
        *) echo "Unknown option: $arg" >&2; echo "Usage: $0 [baseball|valkyries|weather] [--no-open]" >&2; exit 1 ;;
    esac
done

case "$EXAMPLE" in
    baseball) ASSET_DIR="Baseball" ;;
    valkyries) ASSET_DIR="Basketball" ;;
    weather) ASSET_DIR="Weather" ;;
esac

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_DIR="$PROJECT_DIR/dist/ScreenPet.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

rm -rf "$APP_DIR"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"

xcrun swiftc \
    -O \
    -framework AppKit \
    -framework SwiftUI \
    "$PROJECT_DIR/Sources/Core/PetStatus.swift" \
    "$PROJECT_DIR/Sources/Core/PetTheme.swift" \
    "$PROJECT_DIR/Sources/Core/PetModel.swift" \
    "$PROJECT_DIR/Sources/Providers/MLBTeamStatusProvider.swift" \
    "$PROJECT_DIR/Sources/Providers/WNBATeamStatusProvider.swift" \
    "$PROJECT_DIR/Sources/Providers/WeatherStatusProvider.swift" \
    "$PROJECT_DIR/Sources/UI/PetView.swift" \
    "$PROJECT_DIR/Sources/UI/StatusPetAppDelegate.swift" \
    "$PROJECT_DIR/Sources/App/ScreenPetMain.swift" \
    -o "$MACOS_DIR/ScreenPet"

cp "$PROJECT_DIR/Config/Info.plist" "$CONTENTS_DIR/Info.plist"
/usr/libexec/PlistBuddy -c "Add :ScreenPetExample string $EXAMPLE" "$CONTENTS_DIR/Info.plist"
cp "$PROJECT_DIR/Assets/$ASSET_DIR/"*.png "$RESOURCES_DIR/"

codesign --force --deep --sign - "$APP_DIR"
echo "Built $APP_DIR ($EXAMPLE example)"

if [[ "$OPEN_APP" == true ]]; then
    open "$APP_DIR"
fi
