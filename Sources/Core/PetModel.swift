import Combine
import Foundation

@MainActor
final class PetModel: ObservableObject {
    @Published private(set) var stateID: String
    @Published private(set) var message: String
    @Published private(set) var isRefreshing = false

    let theme: PetTheme
    var onStatusChanged: (@MainActor () -> Void)?
    private let provider: any StatusProvider
    private let refreshIntervalNanoseconds: UInt64
    private var refreshTask: Task<Void, Never>?

    init(
        provider: any StatusProvider,
        theme: PetTheme,
        refreshIntervalSeconds: UInt64 = 600
    ) {
        self.provider = provider
        self.theme = theme
        self.stateID = theme.fallbackStateID
        self.message = "Checking status…"
        self.refreshIntervalNanoseconds = refreshIntervalSeconds * 1_000_000_000
    }

    func start() {
        guard refreshTask == nil else { return }
        refreshTask = Task { [weak self] in
            while !Task.isCancelled {
                guard let self else { return }
                await self.refresh()
                try? await Task.sleep(nanoseconds: self.refreshIntervalNanoseconds)
            }
        }
    }

    func refresh() async {
        guard !isRefreshing else { return }
        isRefreshing = true
        defer { isRefreshing = false }

        do {
            let status = try await provider.fetchStatus()
            stateID = status.stateID
            message = status.message
        } catch {
            stateID = theme.fallbackStateID
            message = "Could not update status — will retry"
        }

        onStatusChanged?()
    }
}
