import AppKit

@main
struct ScreenPetMain {
    @MainActor
    static func main() {
        // build-app.sh records the chosen example in Info.plist as ScreenPetExample.
        let example = Bundle.main.object(forInfoDictionaryKey: "ScreenPetExample") as? String ?? "baseball"
        let (provider, theme) = configuration(for: example)

        let application = NSApplication.shared
        let delegate = StatusPetAppDelegate(provider: provider, theme: theme)
        application.delegate = delegate
        application.run()
    }

    /// Each example pairs a provider with a theme. Add a case here to create a different ScreenPet.
    private static func configuration(for example: String) -> (any StatusProvider, PetTheme) {
        switch example {
        case "valkyries":
            // Golden State Valkyries WNBA results.
            let provider = WNBATeamStatusProvider(
                teamID: "129689",
                teamDisplayName: "Valkyries",
                timeZoneIdentifier: "America/Los_Angeles"
            )
            return (provider, .basketball)
        case "weather":
            // San Francisco weather: sun is happy, fog is neutral, rain is sad.
            let provider = WeatherStatusProvider(
                latitude: 37.7749,
                longitude: -122.4194,
                placeName: "San Francisco"
            )
            return (provider, .weather)
        default:
            // San Francisco MLB baseball results.
            let provider = MLBTeamStatusProvider(
                teamID: 137,
                teamDisplayName: "Giants",
                timeZoneIdentifier: "America/Los_Angeles"
            )
            return (provider, .baseball)
        }
    }
}
