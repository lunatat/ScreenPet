import Foundation

/// Maps provider state IDs to PNG assets copied into the application bundle.
struct PetTheme: Sendable {
    let displayName: String
    let menuBarSymbol: String
    let fallbackStateID: String
    let assetNames: [String: String]
    let windowPositionKey: String

    func assetName(for stateID: String) -> String {
        assetNames[stateID] ?? assetNames[fallbackStateID] ?? "neutral"
    }

    static let baseball = PetTheme(
        displayName: "Baseball Pet",
        menuBarSymbol: "⚾️",
        fallbackStateID: "neutral",
        assetNames: [
            "positive": "positive",
            "negative": "negative",
            "neutral": "neutral"
        ],
        windowPositionKey: "BaseballPetPosition"
    )

    static let basketball = PetTheme(
        displayName: "Basketball Pet",
        menuBarSymbol: "🏀",
        fallbackStateID: "neutral",
        assetNames: [
            "positive": "positive",
            "negative": "negative",
            "neutral": "neutral"
        ],
        windowPositionKey: "BasketballPetPosition"
    )

    static let weather = PetTheme(
        displayName: "Weather Pet",
        menuBarSymbol: "🌁",
        fallbackStateID: "neutral",
        assetNames: [
            "positive": "positive",
            "negative": "negative",
            "neutral": "neutral"
        ],
        windowPositionKey: "WeatherPetPosition"
    )
}
