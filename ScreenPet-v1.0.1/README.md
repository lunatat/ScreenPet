# ScreenPet v1.0.1

ScreenPet is a small floating macOS companion that changes expression based on any data source you connect to it. Every ScreenPet has three states:

- **Positive:** something good happened
- **Negative:** something bad happened
- **Neutral:** nothing to report yet

The UI only knows about these states, so the same pet can react to sports scores, weather, CPU use, stock prices, or anything else you write a provider for.

## Examples

This repository ships with three example ScreenPets. Each one checks its source every 10 minutes.

| Example | Build argument | Positive | Neutral | Negative |
| --- | --- | --- | --- | --- |
| ⚾️ **Baseball Pet** (SF Giants) | `baseball` (default) | Giants won | No game, or game not final | Giants lost |
| 🏀 **Basketball Pet** (Golden State Valkyries) | `valkyries` | Valkyries won | No game, or game not final | Valkyries lost |
| 🌁 **Weather Pet** (San Francisco) | `weather` | Sunny or clear ☀️ | Fog or clouds (Karl the Fog) | Rain, snow, or storms 🌧️ |

- **Baseball Pet** uses MLB's public schedule feed, Pacific time, and the latest completed game during a doubleheader.
- **Basketball Pet** uses ESPN's public WNBA scoreboard feed and Pacific time.
- **Weather Pet** uses [Open-Meteo](https://open-meteo.com/)'s free current-weather API (no API key) for San Francisco.

The sports artwork shows generic characters with no official team marks.

> These examples are unofficial and are not affiliated with or endorsed by Major League Baseball, the San Francisco Giants, the WNBA, the Golden State Valkyries, or ESPN. The MLB and ESPN feeds are public but undocumented, so they may change without notice.

## Features

- Transparent floating pet that can be dragged around the desktop
- Positive, negative, and neutral image states
- Provider interface for games, weather, CPU, stocks, or another source
- Menu-bar status, manual refresh, show, reset-position, and quit actions
- Recovers automatically when its saved position is outside every connected screen
- Keeps a visible fallback image if a state asset cannot be loaded
- Brings the pet forward after refresh, display changes, and computer wake
- No Dock icon while running
- Direct `swiftc` build compatible with Apple Command Line Tools
- GitHub Actions workflow that builds the macOS app

## Build ScreenPet

Requirements:

- macOS 13 or later
- Apple Command Line Tools or Xcode with matching compiler and SDK versions

Open Terminal in this folder and run:

```bash
chmod +x build-app.sh
./build-app.sh
```

That builds the Baseball Pet example. To build a different example, pass its name:

```bash
./build-app.sh valkyries
```

```bash
./build-app.sh weather
```

Add `--no-open` to build without launching the app. Each build replaces the previous one, so only one example is installed at a time. The app is created at:

```text
dist/ScreenPet.app
```

Move it into `/Applications` for normal use. Click the pet's menu-bar item (⚾️, 🏀, or 🌁) to refresh, show, reset, or quit the pet. Right-clicking the pet provides the same controls.

## Repository architecture

| Path | Purpose |
| --- | --- |
| `Sources/Core` | Provider-independent status model, theme mapping, and refresh loop |
| `Sources/UI` | Floating macOS panel, pet rendering, menu-bar controls, and position recovery |
| `Sources/Providers` | Data-source implementations: MLB, WNBA, and weather examples |
| `Sources/App` | Pairs each example's provider and theme, and picks the one chosen at build time |
| `Assets/Baseball`, `Assets/Basketball`, `Assets/Weather` | Transparent positive, negative, and neutral PNG assets for each example |
| `Tools/draw-example-art.swift` | Redraws the Basketball and Weather artwork (`swift Tools/draw-example-art.swift Assets`) |
| `Templates` | Starting files for a new provider and theme |
| `docs/AI_CUSTOMIZATION_PROMPT.md` | Copy/paste prompt for a coding AI agent |

ScreenPet communicates through two small types:

```swift
protocol StatusProvider: Sendable {
    func fetchStatus(on date: Date) async throws -> PetStatus
}

struct PetStatus {
    let stateID: String
    let message: String
}
```

The UI does not know whether a state came from baseball, weather, CPU use, a stock price, or another source.

## Make your own ScreenPet

1. Copy `Templates/StatusProviderTemplate.swift.txt` into `Sources/Providers` and rename it with a `.swift` extension.
2. Implement the provider's positive, negative, and neutral rules.
3. Add the new provider file to the `swiftc` list in `build-app.sh`.
4. Create three consistent transparent 512×512 images named `positive.png`, `negative.png`, and `neutral.png`.
5. Put the images in a new folder under `Assets`.
6. Add a `PetTheme` in `Sources/Core/PetTheme.swift` with its own name, menu-bar symbol, and position key.
7. Add a case for your example in `configuration(for:)` in `Sources/App/ScreenPetMain.swift`.
8. Add the example name and its `Assets` folder to the two `case` blocks at the top of `build-app.sh`.
9. Run `./build-app.sh <your-example>` and test all states.

For AI-assisted customization, use the complete prompt in [`docs/AI_CUSTOMIZATION_PROMPT.md`](docs/AI_CUSTOMIZATION_PROMPT.md).

## Change an example's team or city

All three examples are configured in `Sources/App/ScreenPetMain.swift`. No UI changes are required.

- **Baseball:** change `teamID` (MLB Stats API team ID, `137` is the Giants), `teamDisplayName`, and `timeZoneIdentifier`.
- **Basketball:** change `teamID` (ESPN team ID, `"129689"` is the Valkyries; see `https://site.api.espn.com/apis/site/v2/sports/basketball/wnba/teams`), `teamDisplayName`, and `timeZoneIdentifier`.
- **Weather:** change `latitude`, `longitude`, and `placeName`.

## Upload to GitHub

Upload this unzipped folder as the repository—do not make the ZIP itself the repository.

With GitHub Desktop:

1. Select **File → Add Local Repository** and choose this folder.
2. If asked, create a repository here.
3. Commit the files.
4. Select **Publish repository** and choose public or private visibility.

Or with Git:

```bash
git init -b main
git add .
git commit -m "Release ScreenPet v1.0.1"
git remote add origin YOUR_GITHUB_REPOSITORY_URL
git push -u origin main
```

The included `.gitignore` excludes local build products. Create a GitHub Release tagged `v1.0.1` if you want a stable release page. A locally built, ad-hoc-signed `.app` may still trigger macOS security warnings on another person's Mac; public binary distribution normally requires an Apple Developer ID signature and notarization.

## Privacy and credentials

ScreenPet does not collect personal data. The examples only request public schedule, score, and weather information. Never commit API keys, tokens, passwords, or private company endpoints when adding a new provider.

## License

MIT. See `LICENSE`.
