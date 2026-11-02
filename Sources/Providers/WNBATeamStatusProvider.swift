import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Example provider for a WNBA team, using ESPN's public scoreboard feed.
/// Change the configuration in ScreenPetMain.swift to follow another team.
struct WNBATeamStatusProvider: StatusProvider {
    let teamID: String
    let teamDisplayName: String
    let timeZoneIdentifier: String

    init(
        teamID: String,
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
        formatter.dateFormat = "yyyyMMdd"

        var components = URLComponents(string: "https://site.api.espn.com/apis/site/v2/sports/basketball/wnba/scoreboard")!
        components.queryItems = [
            URLQueryItem(name: "dates", value: formatter.string(from: date))
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
        let response = try JSONDecoder().decode(Scoreboard.self, from: data)
        let games = response.events
            .compactMap(\.competitions.first)
            .filter { $0.competitors.contains { $0.team.id == teamID } }

        guard !games.isEmpty else {
            return .neutral("No \(teamDisplayName) game today")
        }

        if let latest = games.last(where: \.status.type.completed),
           let result = result(for: latest) {
            return result
        }

        if games.contains(where: { $0.status.type.state == "in" }) {
            return .neutral("\(teamDisplayName) game in progress")
        }

        let detail = games.last?.status.type.detail ?? "Scheduled"
        return .neutral("\(teamDisplayName) game: \(detail)")
    }

    private func result(for game: Competition) -> PetStatus? {
        guard let selectedTeam = game.competitors.first(where: { $0.team.id == teamID }),
              let opponent = game.competitors.first(where: { $0.team.id != teamID }),
              let teamScore = selectedTeam.score.flatMap(Int.init),
              let opponentScore = opponent.score.flatMap(Int.init) else {
            return nil
        }

        let score = "\(teamDisplayName) \(teamScore), \(opponent.team.shortDisplayName) \(opponentScore)"
        if teamScore > opponentScore {
            return PetStatus(stateID: "positive", message: "\(teamDisplayName) won! \(score)")
        }
        if teamScore < opponentScore {
            return PetStatus(stateID: "negative", message: "\(teamDisplayName) lost. \(score)")
        }
        return .neutral("Final score: \(score)")
    }
}

private struct Scoreboard: Decodable {
    let events: [Event]
}

private struct Event: Decodable {
    let competitions: [Competition]
}

private struct Competition: Decodable {
    let status: Status
    let competitors: [Competitor]
}

private struct Status: Decodable {
    let type: StatusType
}

private struct StatusType: Decodable {
    let state: String
    let completed: Bool
    let detail: String
}

private struct Competitor: Decodable {
    let score: String?
    let team: Team
}

private struct Team: Decodable {
    let id: String
    let shortDisplayName: String
}
