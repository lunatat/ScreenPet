import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Default example provider. Change the configuration in ScreenPetMain.swift
/// to follow another MLB team while preserving the framework.
struct MLBTeamStatusProvider: StatusProvider {
    let teamID: Int
    let teamDisplayName: String
    let timeZoneIdentifier: String

    init(
        teamID: Int,
        teamDisplayName: String,
        timeZoneIdentifier: String = "America/Los_Angeles"
    ) {
        self.teamID = teamID
        self.teamDisplayName = teamDisplayName
        self.timeZoneIdentifier = timeZoneIdentifier
    }

    func fetchStatus(on date: Date) async throws -> PetStatus {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone(identifier: timeZoneIdentifier)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"

        var components = URLComponents(string: "https://statsapi.mlb.com/api/v1/schedule")!
        components.queryItems = [
            URLQueryItem(name: "sportId", value: "1"),
            URLQueryItem(name: "teamId", value: String(teamID)),
            URLQueryItem(name: "date", value: formatter.string(from: date)),
            URLQueryItem(name: "hydrate", value: "linescore")
        ]

        var request = URLRequest(url: components.url!)
        request.timeoutInterval = 20
        request.setValue("ScreenPet/1.0.1", forHTTPHeaderField: "User-Agent")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse,
              (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }

        return try evaluate(data: data)
    }

    private func evaluate(data: Data) throws -> PetStatus {
        let response = try JSONDecoder().decode(ScheduleResponse.self, from: data)
        let games = response.dates.flatMap(\.games)

        guard !games.isEmpty else {
            return .neutral("No \(teamDisplayName) game today")
        }

        let completed = games.filter(\.isCompleted)
        if let latest = completed.last,
           let result = result(for: latest) {
            return result
        }

        if games.contains(where: { $0.status.abstractGameState.caseInsensitiveCompare("Live") == .orderedSame }) {
            return .neutral("\(teamDisplayName) game in progress")
        }

        let detail = games.last?.status.detailedState ?? "Scheduled"
        return .neutral("\(teamDisplayName) game: \(detail)")
    }

    private func result(for game: Game) -> PetStatus? {
        let teamIsHome = game.teams.home.team.id == teamID
        let selectedTeam = teamIsHome ? game.teams.home : game.teams.away
        let opponent = teamIsHome ? game.teams.away : game.teams.home

        guard selectedTeam.team.id == teamID,
              let teamScore = selectedTeam.score,
              let opponentScore = opponent.score else {
            return nil
        }

        let score = "\(teamDisplayName) \(teamScore), \(opponent.team.name) \(opponentScore)"
        if teamScore > opponentScore {
            return PetStatus(stateID: "positive", message: "\(teamDisplayName) won! \(score)")
        }
        if teamScore < opponentScore {
            return PetStatus(stateID: "negative", message: "\(teamDisplayName) lost. \(score)")
        }
        return .neutral("Final score: \(score)")
    }
}

private struct ScheduleResponse: Decodable {
    let dates: [ScheduleDate]
}

private struct ScheduleDate: Decodable {
    let games: [Game]
}

private struct Game: Decodable {
    let gamePk: Int
    let status: GameState
    let teams: Teams

    var isCompleted: Bool {
        status.abstractGameState.caseInsensitiveCompare("Final") == .orderedSame ||
        status.detailedState.localizedCaseInsensitiveContains("Final") ||
        status.detailedState.localizedCaseInsensitiveContains("Completed") ||
        status.detailedState.localizedCaseInsensitiveContains("Game Over")
    }
}

private struct GameState: Decodable {
    let abstractGameState: String
    let detailedState: String
}

private struct Teams: Decodable {
    let away: Side
    let home: Side
}

private struct Side: Decodable {
    let score: Int?
    let team: Team
}

private struct Team: Decodable {
    let id: Int
    let name: String
}
