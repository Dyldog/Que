import Foundation

/// A non-persistent `LeaderboardStore` for tests and SwiftUI previews.
final class InMemoryLeaderboardStore: LeaderboardStore {
    private var data: LeaderboardData

    init(data: LeaderboardData = LeaderboardData()) {
        self.data = data
    }

    func entries(for config: SprintConfig) -> [LeaderboardEntry] {
        data.entries(for: config)
    }

    func configs() -> [SprintConfig] {
        data.configs()
    }

    @discardableResult
    func add(_ entry: LeaderboardEntry, config: SprintConfig) -> Int? {
        data.add(entry, config: config)
    }

    var lastInitials: String? {
        data.lastInitials
    }
}
