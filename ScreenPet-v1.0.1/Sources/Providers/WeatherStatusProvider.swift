import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Example provider for current weather, using Open-Meteo's free forecast API (no key required).
/// Sunny or clear is positive, cloud or fog is neutral, and rain, snow, or storms are negative.
struct WeatherStatusProvider: StatusProvider {
    let latitude: Double
    let longitude: Double
    let placeName: String

    func fetchStatus(on date: Date) async throws -> PetStatus {
        var components = URLComponents(string: "https://api.open-meteo.com/v1/forecast")!
        components.queryItems = [
            URLQueryItem(name: "latitude", value: String(latitude)),
            URLQueryItem(name: "longitude", value: String(longitude)),
            URLQueryItem(name: "current", value: "weather_code,temperature_2m"),
            URLQueryItem(name: "temperature_unit", value: "fahrenheit")
        ]

        var request = URLRequest(url: components.url!)
        request.timeoutInterval = 20
        request.setValue("ScreenPet/1.0.1", forHTTPHeaderField: "User-Agent")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse,
              (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let forecast = try JSONDecoder().decode(Forecast.self, from: data)
        return status(code: forecast.current.weather_code, temperature: forecast.current.temperature_2m)
    }

    /// Maps WMO weather codes: https://open-meteo.com/en/docs#weather_variable_documentation
    private func status(code: Int, temperature: Double) -> PetStatus {
        let temp = "\(Int(temperature.rounded()))°F"
        switch code {
        case 0, 1:
            return PetStatus(stateID: "positive", message: "Sunny in \(placeName), \(temp)")
        case 2:
            return .neutral("Partly cloudy in \(placeName), \(temp)")
        case 3:
            return .neutral("Overcast in \(placeName), \(temp)")
        case 45, 48:
            return .neutral("Karl the Fog is in \(placeName), \(temp)")
        case 51...67, 80...82:
            return PetStatus(stateID: "negative", message: "Raining in \(placeName), \(temp)")
        case 71...77, 85, 86:
            return PetStatus(stateID: "negative", message: "Snowing in \(placeName), \(temp)")
        case 95...99:
            return PetStatus(stateID: "negative", message: "Thunderstorms in \(placeName), \(temp)")
        default:
            return .neutral("Weather in \(placeName): \(temp)")
        }
    }
}

private struct Forecast: Decodable {
    let current: Current
}

private struct Current: Decodable {
    let weather_code: Int
    let temperature_2m: Double
}
