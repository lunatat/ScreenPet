import Foundation

/// A provider-independent result that selects a visual state and supplies hover/menu text.
struct PetStatus: Equatable, Sendable {
    let stateID: String
    let message: String

    static func neutral(_ message: String) -> PetStatus {
        PetStatus(stateID: "neutral", message: message)
    }
}

/// Implement this protocol to drive the pet from games, weather, CPU, stocks, or another source.
protocol StatusProvider: Sendable {
    func fetchStatus(on date: Date) async throws -> PetStatus
}

extension StatusProvider {
    func fetchStatus() async throws -> PetStatus {
        try await fetchStatus(on: Date())
    }
}
